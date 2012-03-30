/****************************************************************************
 * KONOHA COPYRIGHT, LICENSE NOTICE, AND DISCRIMER
 *
 * Copyright (c)  2010-      Konoha Team konohaken@googlegroups.com
 * All rights reserved.
 *
 * You may choose one of the following two licenses when you use konoha.
 * See www.konohaware.org/license.html for further information.
 *
 * (1) GNU Lesser General Public License 3.0 (with KONOHA_UNDER_LGPL3)
 * (2) Konoha Software Foundation License 1.0
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ****************************************************************************/

#define K_INTERNAL
#include <konoha1.h>
#include <konoha1/inlinelibs.h>
#include <time.h>
#include <uuid/uuid.h>
#include <openssl/sha.h>
#include <openssl/hmac.h>
#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/buffer.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ------------------------------------------------------------------------ */

static time_t kdate_totime(kdate_t dt)
{
    struct tm t = {
        .tm_sec = dt.sec,
        .tm_min = dt.min,
        .tm_hour = dt.hour,
        .tm_mday = dt.day,
        .tm_mon = dt.month - 1,
        .tm_year = dt.year - 1900,
        .tm_isdst = -1
    };
    return mktime(&t);
}

static kbool_t tourl(CTX ctx, knh_conv_t *cv, const char *text, size_t len, kBytes *tobuf)
{
    int i;
    for (i = 0; i < len; i++) {
        unsigned char c = text[i];
        if (isalnum(c) || c == '.' || c == '-' || c == '_') {
            knh_Bytes_putc(ctx, tobuf, c);
        } else if (c == ' ') { // ' ' => '+'
            knh_Bytes_putc(ctx, tobuf, '+');
        } else { // '\0ff' => "%ff"
            knh_Bytes_putc(ctx, tobuf, '%');
            char buf[3] = {0};
            snprintf(buf, 3, "%02X", c);
            knh_Bytes_write2(ctx, tobuf, (const char *)buf, 2);
        }
    }
    return 1;
}

static kbool_t fromurl(CTX ctx, knh_conv_t *cv, const char *text, size_t len, kBytes *tobuf)
{
    int i = 0;
    while (i < len) {
        unsigned char c = text[i];
        switch (c) {
        case '+': // '+' => ' '
            knh_Bytes_putc(ctx, tobuf, ' ');
            i++;
            break;
        case '%':
            if (i + 2 < len) {
                // "%ff" => '\0ff'
                char hex[3] = {
                    text[i + 1],
                    text[i + 2],
                    '\0'
                };
                long decval = 0x20;
                char *endptr = NULL;
                decval = strtol(hex, &endptr, 16);
                if (endptr != NULL && 0 <= decval && decval <= UCHAR_MAX) {
                    knh_Bytes_putc(ctx, tobuf, (int)decval);
                } else {
                    knh_Bytes_putc(ctx, tobuf, '%');
                    knh_Bytes_write2(ctx, tobuf, (const char *)hex, 2);
                }
                i += 3;
                break;
            }
            // fall through
        default:
            knh_Bytes_putc(ctx, tobuf, c);
            i++;
            break;
        }
    }
    return 1;
}

static const knh_ConverterDPI_t TO_url = {
    K_DSPI_CONVTO, // type
    "url",         // name
    NULL,          // open
    tourl,         // conv
    tourl,         // enc
    tourl,         // dec
    tourl,         // sconv
    NULL,          // close
    NULL           // setparam
};

static const knh_ConverterDPI_t FROM_url = {
    K_DSPI_CONVFROM,  // type
    "durl",           // name
    NULL,             // open
    fromurl,          // conv
    fromurl,          // enc
    fromurl,          // dec
    fromurl,          // sconv
    NULL,             // close
    NULL              // setparam
};

static kbool_t xorConvert(CTX ctx, knh_conv_t *cv, const char *text, size_t len, kBytes *tobuf)
{
    int i, key;
    kInt *ki = (kInt *)knh_getPropertyNULL(ctx, STEXT("SEED"));
    if (ki != NULL) {
        key = N_toint(ki);
    }
    else {
        key = knh_rand();
        knh_setProperty(ctx, new_String(ctx, "SEED"), (dynamic *)new_Int(ctx, key));
    }
    for (i = 0; i < len; i++) {
        unsigned char c = text[i];
        knh_Bytes_putc(ctx, tobuf, c ^ key);
    }
    return 1;
}

static const knh_ConverterDPI_t xorConverter = {
    K_DSPI_CONVTO,    // type
    "xor",            // name
    NULL,             // open
    xorConvert,       // conv
    xorConvert,       // enc
    xorConvert,       // dec
    xorConvert,       // sconv
    NULL,             // close
    NULL              // setparam
};

static kbool_t base64encode(CTX ctx, knh_conv_t *cv, const char *text, size_t len, kBytes *tobuf)
{
    BIO *bmem, *b64;
    BUF_MEM *bptr;

    b64 = BIO_new(BIO_f_base64());
    bmem = BIO_new(BIO_s_mem());
    b64 = BIO_push(b64, bmem);
    BIO_write(b64, text, len);
    (void)BIO_flush(b64);
    BIO_get_mem_ptr(b64, &bptr);

    knh_Bytes_write2(ctx, tobuf, (const char *)bptr->data, bptr->length);
    knh_Bytes_putc(ctx, tobuf, 0);
    BIO_free_all(b64);

    return 1;
}

static kbool_t base64decode(CTX ctx, knh_conv_t *cv, const char *text, size_t len, kBytes *tobuf)
{
    BIO *bmem, *b64;

    char *buffer = (char *)malloc(len);
    memset(buffer, 0, len);

    b64 = BIO_new(BIO_f_base64());
    BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    bmem = BIO_new_mem_buf((char *)text, len);
    b64 = BIO_push(b64, bmem);

    BIO_read(b64, buffer, len);
    BIO_free_all(b64);

    knh_Bytes_write2(ctx, tobuf, (const char *)buffer, len);

    return 1;
}

static const knh_ConverterDPI_t base64Encoder = {
    K_DSPI_CONVTO,    // type
    "base64",         // name
    NULL,             // open
    base64encode,     // conv
    base64encode,     // enc
    base64encode,     // dec
    base64encode,     // sconv
    NULL,             // close
    NULL              // setparam
};

static const knh_ConverterDPI_t base64Decoder = {
    K_DSPI_CONVTO,    // type
    "dbase64",        // name
    NULL,             // open
    base64decode,     // conv
    base64decode,     // enc
    base64decode,     // dec
    base64decode,     // sconv
    NULL,             // close
    NULL              // setparam
};

static kbool_t SHA256Digest(CTX ctx, knh_conv_t *cv, const char *text, size_t len, kBytes *tobuf)
{
    SHA256_CTX context;
    unsigned char md[SHA256_DIGEST_LENGTH];

    SHA256_Init(&context);
    SHA256_Update(&context, text, len);
    SHA256_Final(md, &context);

    knh_Bytes_write2(ctx, tobuf, (const char *)md, SHA256_DIGEST_LENGTH);
    return 1;
}

static kbool_t SHA256String(CTX ctx, knh_conv_t *cv, const char *text, size_t len, kBytes *tobuf)
{
    SHA256_CTX context;
    unsigned char md[SHA256_DIGEST_LENGTH];

    SHA256_Init(&context);
    SHA256_Update(&context, text, len);
    SHA256_Final(md, &context);

    char dbuf[4];
    size_t i;
    for (i = 0; i < SHA256_DIGEST_LENGTH; i++) {
        knh_snprintf(dbuf, sizeof(dbuf), "%02x", md[i]);
        knh_Bytes_write2(ctx, tobuf, dbuf, 2);
    }

    return 1;
}

static const knh_ConverterDPI_t SHA256Converter = {
    K_DSPI_CONVTO,    // type
    "SHA256",         // name
    NULL,             // open
    SHA256Digest,     // conv
    SHA256Digest,     // enc
    SHA256String,     // dec
    SHA256String,     // sconv
    NULL,             // close
    NULL              // setparam
};

/* ------------------------------------------------------------------------ */

DEFAPI(void) defUuid(CTX ctx, kclass_t cid, kclassdef_t *cdef)
{
    cdef->name = "Uuid";
}

/* ------------------------------------------------------------------------ */

//## @Native String Uuid.getUuid4();
KMETHOD Uuid_getUuid4(CTX ctx, ksfp_t *sfp _RIX)
{
    uuid_t u;
    char buf[37];
    uuid_generate(u);
    uuid_unparse(u, buf);
    RETURN_(new_String(ctx, buf));
}

/* ------------------------------------------------------------------------ */

//## @Native @Public int Date.getYear();
KMETHOD Date_getYear(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    RETURNi_(date->dt.year);
}

//## @Native @Public void Date.setYear(int year);
KMETHOD Date_setYear(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    kshort_t year = Int_to(kshort_t, sfp[1]);
    date->dt.year = year;
    RETURNvoid_();
}

//## @Native @Public int Date.getMonth();
KMETHOD Date_getMonth(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    RETURNi_(date->dt.month);
}

//## @Native @Public void Date.setMonth(int month);
KMETHOD Date_setMonth(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    kshort_t month = Int_to(kshort_t, sfp[1]);
    date->dt.month = month;
    RETURNvoid_();
}

//## @Native @Public int Date.getDay();
KMETHOD Date_getDay(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    RETURNi_(date->dt.day);
}

//## @Native @Public void Date.setDay(int day);
KMETHOD Date_setDay(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    kshort_t day = Int_to(kshort_t, sfp[1]);
    date->dt.day = day;
    RETURNvoid_();
}

//## @Native @Public int Date.getHour();
KMETHOD Date_getHour(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    RETURNi_(date->dt.hour);
}

//## @Native @Public void Date.setHour(int hour);
KMETHOD Date_setHour(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    kshort_t hour = Int_to(kshort_t, sfp[1]);
    date->dt.hour = hour;
    RETURNvoid_();
}

//## @Native @Public int Date.getMin();
KMETHOD Date_getMin(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    RETURNi_(date->dt.min);
}

//## @Native @Public void Date.setMin(int min);
KMETHOD Date_setMin(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    kshort_t min = Int_to(kshort_t, sfp[1]);
    date->dt.min = min;
    RETURNvoid_();
}

//## @Native @Public int Date.getSec();
KMETHOD Date_getSec(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    RETURNi_(date->dt.sec);
}

//## @Native @Public void Date.setSec(int sec);
KMETHOD Date_setSec(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    kshort_t sec = Int_to(kshort_t, sfp[1]);
    date->dt.sec = sec;
    RETURNvoid_();
}

//## @Native @Public int Date.getGmtoff();
KMETHOD Date_getGmtoff(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    RETURNi_(date->dt.gmtoff);
}

//## @Native @Public void Date.setGmtoff(int gmtoff);
KMETHOD Date_setGmtoff(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    kshort_t gmtoff = Int_to(kshort_t, sfp[1]);
    date->dt.gmtoff = gmtoff;
    RETURNvoid_();
}

//## @Native @Public String Date.toRFC1123();
KMETHOD Date_toRFC1123(CTX ctx, ksfp_t *sfp _RIX)
{
    kDate *date = sfp[0].dt;
    kdate_t dt = date->dt;
    time_t time = kdate_totime(dt);
    if (time < 0) {
        RETURN_(KNH_TNULL(String));
    }
    char buf[64];
    struct tm tm;
    gmtime_r(&time, &tm);
    const char *wdaystr[] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
    const char *monstr[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
    knh_snprintf(buf, sizeof(buf), "%s, %02d %s %04d %02d:%02d:%02d GMT",
            wdaystr[tm.tm_wday], tm.tm_mday, monstr[tm.tm_mon], tm.tm_year + 1900,
            tm.tm_hour, tm.tm_min, tm.tm_sec);
    RETURN_(new_String(ctx, buf));
}

/* ------------------------------------------------------------------------ */

#ifdef _SETUP

DEFAPI(const knh_PackageDef_t*) init(CTX ctx, knh_LoaderAPI_t *kapi)
{
    kapi->addConverterDPI(ctx, "url", &TO_url, NULL);
    kapi->addConverterDPI(ctx, "durl", &FROM_url, NULL);
    kapi->addConverterDPI(ctx, "xor", &xorConverter, NULL);
    kapi->addConverterDPI(ctx, "base64",  &base64Encoder, NULL);
    kapi->addConverterDPI(ctx, "dbase64", &base64Decoder, NULL);
    kapi->addConverterDPI(ctx, "SHA256", &SHA256Converter, NULL);
    RETURN_PKGINFO("konoha.veins");
}

#endif /* _SETUP */

#ifdef __cplusplus
}
#endif
