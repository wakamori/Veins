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
#include "konoha_wsgi.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAXLEN 256

//static int config_initialized = 0;

static void kWsgi_init(CTX ctx, kRawPtr *po)
{
    wsgi_config_t *conf = (wsgi_config_t *)KNH_MALLOC(ctx, sizeof(wsgi_config_t));
    conf->status = (char *)KNH_MALLOC(ctx, sizeof(char) * MAXLEN);
    conf->content_type = (char *)KNH_MALLOC(ctx, sizeof(char) * MAXLEN);
    conf->content_encoding = (char *)KNH_MALLOC(ctx, sizeof(char) * MAXLEN);
    po->rawptr = conf;
}

static void kWsgi_free(CTX ctx, kRawPtr *po)
{
    if (po->rawptr != NULL) {
        wsgi_config_t *conf = po->rawptr;
        KNH_FREE(ctx, conf->status, sizeof(char) * MAXLEN);
        KNH_FREE(ctx, conf->content_type, sizeof(char) * MAXLEN);
        KNH_FREE(ctx, conf->content_encoding, sizeof(char) * MAXLEN);
        KNH_FREE(ctx, po->rawptr, sizeof(wsgi_config_t));
        po->rawptr = NULL;
    }
}

DEFAPI(void) defWsgi(CTX ctx, kclass_t cid, kclassdef_t *cdef)
{
    cdef->name = "Wsgi";
    cdef->free = kWsgi_free;
}

/* ------------------------------------------------------------------------ */

//## @Native Wsgi Wsgi.new();
KMETHOD Wsgi_new(CTX ctx, ksfp_t *sfp _RIX)
{
    kWsgi_init(ctx, sfp[0].p);
    RETURN_(sfp[0].o);
}

//## @Native void Wsgi.startResponse(String status, Tuple<String,String>[] header);
KMETHOD Wsgi_startResponse(CTX ctx, ksfp_t *sfp _RIX)
{
    //if (config_initialized) {
    //    kWsgi_free(ctx, sfp[0].p);
    //}
    //config_initialized = 1;
    //kWsgi_init(ctx, sfp[0].p);

    wsgi_config_t *conf = RawPtr_to(wsgi_config_t *, sfp[0]);

    const char *status = String_to(const char *, sfp[1]);
    kArray *header = sfp[2].a;

    strncpy(conf->status, status, MAXLEN);
    size_t i;
    for (i = 0; i < knh_Array_size(header); i++) {
        kTuple *t = (kTuple *)knh_Array_n(header, i);
        const char *key = S_totext((kString *)t->fields[0]);
        const char *val = S_totext((kString *)t->fields[1]);
        if (strcmp(key, "content_type") == 0) {
            strncpy(conf->content_type, val, MAXLEN);
        }
        else if (strcmp(key, "content_encoding") == 0) {
            strncpy(conf->content_encoding, val, MAXLEN);
        }
    }

    RETURNvoid_();
}

//## @Native @Hidden void Wsgi.config(void);
KMETHOD Wsgi_config(CTX ctx, ksfp_t *sfp _RIX)
{
    RETURN_(sfp[0].p);
}

/* ------------------------------------------------------------------------ */

#ifdef _SETUP

DEFAPI(const knh_PackageDef_t*) init(CTX ctx, knh_LoaderAPI_t *kapi)
{
    RETURN_PKGINFO("konoha.wsgi");
}

#endif /* _SETUP */

#ifdef __cplusplus
}
#endif
