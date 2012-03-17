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
#include <time.h>

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
    RETURN_PKGINFO("konoha.cookie");
}

#endif /* _SETUP */

#ifdef __cplusplus
}
#endif
