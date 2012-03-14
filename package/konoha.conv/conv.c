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

#ifdef __cplusplus
extern "C" {
#endif

/* ------------------------------------------------------------------------ */
// [private functions]

#ifdef _SETUP

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
			snprintf(buf, 3, "%X", c);
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

#endif /* _SETUP */

/* ------------------------------------------------------------------------ */
// [DEFAPI]

#ifdef _SETUP

DEFAPI(const knh_PackageDef_t*) init(CTX ctx, knh_LoaderAPI_t *kapi)
{
	kapi->addConverterDPI(ctx, "url", &TO_url, NULL);
	kapi->addConverterDPI(ctx, "durl", &FROM_url, NULL);
	RETURN_PKGINFO("konoha.conv");
}

#endif /* _SETUP */

#ifdef __cplusplus
}
#endif
