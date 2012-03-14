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
#include <ClearSilver/ClearSilver.h>

#ifdef __cplusplus
extern "C" {
#endif

static void Default_init(CTX ctx, kRawPtr *po)
{
    po->rawptr = NULL;
}

static void kHdf_free(CTX ctx, kRawPtr *po)
{
    if (po->rawptr != NULL) {
        HDF *hdf = (HDF *)po->rawptr;
        hdf_destroy(&hdf);
        po->rawptr = NULL;
    }
}

DEFAPI(void) defHdf(CTX ctx, kclass_t cid, kclassdef_t *cdef)
{
    cdef->name = "Hdf";
    cdef->init = Default_init;
    cdef->free = kHdf_free;
}

static void kCs_free(CTX ctx, kRawPtr *po)
{
    if (po->rawptr != NULL) {
        CSPARSE *cs = (CSPARSE *)po->rawptr;
        cs_destroy(&cs);
        po->rawptr = NULL;
    }
}

DEFAPI(void) defCs(CTX ctx, kclass_t cid, kclassdef_t *cdef)
{
    cdef->name = "Cs";
    cdef->init = Default_init;
    cdef->free = kCs_free;
}

static knh_IntData_t CsConstInt[] = {
	{"STATUS_OK", STATUS_OK_INT},
	{"INTERNAL_ERR", INTERNAL_ERR_INT},
	{NULL}
};

DEFAPI(void) constCs(CTX ctx, kclass_t cid, const knh_LoaderAPI_t *kapi)
{
	kapi->loadClassIntConst(ctx, cid, CsConstInt);
}

/* ------------------------------------------------------------------------ */

//## @Native Hdf Hdf.new();
KMETHOD Hdf_new(CTX ctx, ksfp_t *sfp _RIX)
{
    HDF *hdf;
    hdf_init(&hdf);
    RETURN_(new_ReturnRawPtr(ctx, sfp, hdf));
}

//## @Native void Hdf.value(String name, String value);
KMETHOD Hdf_value(CTX ctx, ksfp_t *sfp _RIX)
{
    HDF *hdf = RawPtr_to(HDF *, sfp[0]);
    const char *name = S_totext(sfp[1].s);
    const char *value = S_totext(sfp[2].s);
    hdf_set_value(hdf, name, value);
    RETURNvoid_();
}

/* ------------------------------------------------------------------------ */

//## @Native Cs Cs.new(Hdf hdf);
KMETHOD Cs_new(CTX ctx, ksfp_t *sfp _RIX)
{
    HDF *hdf = RawPtr_to(HDF *, sfp[1]);
    CSPARSE *cs;
    cs_init(&cs, hdf);
    RETURN_(new_ReturnRawPtr(ctx, sfp, cs));
}

//## @Native void Cs.parseFile(Path path);
KMETHOD Cs_parseFile(CTX ctx, ksfp_t *sfp _RIX)
{
    CSPARSE *cs = RawPtr_to(CSPARSE *, sfp[0]);
    const char *path = sfp[1].pth->ospath;
    cs_parse_file(cs, path);
    RETURNvoid_();
}

typedef struct _render_arg {
    CTX ctx;
    kFunc *fo;
} render_arg_t;

static NEOERR *render_cb(void *v, char *s)
{
    render_arg_t *arg = (render_arg_t *)v;
    CTX ctx = arg->ctx;
    kFunc *fo = arg->fo;
    BEGIN_LOCAL(ctx, lsfp, K_CALLDELTA + 2);
    KNH_SETv(ctx, lsfp[K_CALLDELTA + 1].o, new_String(ctx, s));
    knh_Func_invoke(ctx, fo, lsfp, 1/* argc */);
    END_LOCAL(ctx, lsfp);
    switch (lsfp[0].ivalue) {
    case STATUS_OK_INT:
        return STATUS_OK;
    case INTERNAL_ERR_INT:
        return INTERNAL_ERR;
    default:
        /* unknow return value */
        return STATUS_OK;
    }
}

//## @Native void Cs.render(Func<String=>int> cb);
KMETHOD Cs_render(CTX ctx, ksfp_t *sfp _RIX)
{
    CSPARSE *cs = RawPtr_to(CSPARSE *, sfp[0]);
    kFunc *fo = sfp[1].fo;
    render_arg_t arg = {
        .ctx = ctx,
        .fo = fo
    };
    cs_render(cs, &arg, render_cb);
    RETURNvoid_();
}

/* ------------------------------------------------------------------------ */

#ifdef _SETUP

DEFAPI(const knh_PackageDef_t*) init(CTX ctx, knh_LoaderAPI_t *kapi)
{
    RETURN_PKGINFO("konoha.clearsilver");
}

#endif /* _SETUP */

#ifdef __cplusplus
}
#endif