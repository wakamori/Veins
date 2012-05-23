/* 
**  mod_konoha.c -- Apache sample konoha module
**  [Autogenerated via ``apxs -n konoha -g'']
**
**  To play with this sample module first compile it into a
**  DSO file and install it into Apache's modules directory 
**  by running:
**
**    $ apxs -c -i mod_konoha.c
**
**  Then activate it in Apache's httpd.conf file for instance
**  for the URL /konoha in as follows:
**
**    #   httpd.conf
**    LoadModule konoha_module modules/mod_konoha.so
**    <Location /konoha>
**    SetHandler konoha
**    </Location>
**
**  Then after restarting Apache via
**
**    $ apachectl restart
**
**  you immediately can request the URL /konoha and watch for the
**  output of this module. This can be achieved for instance via:
**
**    $ lynx -mime_header http://localhost/konoha 
**
**  The output should be similar to the following one:
**
**    HTTP/1.1 200 OK
**    Date: Tue, 31 Mar 1998 14:42:22 GMT
**    Server: Apache/1.3.4 (Unix)
**    Connection: close
**    Content-Type: text/html
**  
**    The sample page from mod_konoha.c
*/ 
#include "httpd.h"
#include "http_config.h"
#include "http_protocol.h"
#include "ap_config.h"

#include "apr_strings.h"
#include "http_log.h"
#include <konoha1.h>
#include <konoha1/inlinelibs.h>
#include <sys/types.h>
#include <sys/stat.h>

#define PATHSIZE 1024
#define AP_LOG_DEBUG(fmt, ...) \
    do { \
        if (debug) { \
            ap_log_rerror(APLOG_MARK, APLOG_CRIT, 0, r, fmt, ## __VA_ARGS__); \
        } \
    } while (0)
#define AP_LOG_CRIT(fmt, ...) \
    ap_log_rerror(APLOG_MARK, APLOG_CRIT, 0, r, fmt, ## __VA_ARGS__)
#define GET_PROP(name) \
    (kString*)knh_getPropertyNULL(ctx, STEXT(name))
#define CLEAR_PROP(name) \
    knh_setProperty(ctx, new_String(ctx, name), KNH_NULL)
#define IS_KNULL(val) \
    ((val) == NULL || (kObject *)(val) == KNH_NULL)

typedef struct _konoha_config {
    int debug;
    const char *handler;
    const char *package_dir;
} konoha_config_t;

typedef struct _wsgi_config {
    const char *status;
    const char *content_type;
} wsgi_config_t;

static int konoha_initialized = 0;
static konoha_t konoha;

module AP_MODULE_DECLARE_DATA konoha_module;

/* utility of read from POST body */
static int util_read(request_rec *r, const char **rbuf)
{
    int rc;

    if (r->method_number != M_POST) {
        return DECLINED;
    }

    if ((rc = ap_setup_client_block(r, REQUEST_CHUNKED_ERROR)) != OK) {
        return rc;
    }

    if (ap_should_client_block(r)) {
        char argsbuffer[HUGE_STRING_LEN];
        int rsize, len_read, rpos=0;
        long length = r->remaining;
        *rbuf = apr_pcalloc(r->pool, length + 1);

        while ((len_read = ap_get_client_block(r, argsbuffer,
                        sizeof(argsbuffer))) > 0 ) {
            if ((rpos + len_read) > length) {
                rsize = length - rpos;
            }
            else {
                rsize = len_read;
            }
            memcpy((char *)*rbuf + rpos, argsbuffer, rsize);
            rpos += rsize;
        }
    }

    return rc;
}

/* call Script.application() */
static int start_application(request_rec *r, CTX ctx, int debug, const char **content)
{
    KONOHA_BEGIN(ctx);
    extern char **environ;
    char **env_p;
    kmethodn_t mn = knh_getmn(ctx, STEXT("application"), MN_NONAME);
    kclass_t cid = knh_getcid(ctx, STEXT("konoha.wsgi.Wsgi"));
    //AP_LOG_CRIT("mn=%d,cid=%d", mn, cid);
    kMethod *mtd = knh_NameSpace_getMethodNULL(ctx, NULL, cid, mn);
    if (mtd == NULL) {
        AP_LOG_CRIT("function 'application' is not defined.");
        return -1;
    }
    BEGIN_LOCAL(ctx, lsfp, K_CALLDELTA+3);

    /* set args */
    kMap *env_map = new_DataMap(ctx);
    char key[128] = {0};
    for (env_p = environ; *env_p != NULL; env_p++) {
        AP_LOG_DEBUG("env: %s", *env_p);
        char *val = strchr(*env_p, '=');
        if (val != NULL) {
            val += 1;
            size_t keylen = val - *env_p - 1;
            strncpy(key, *env_p, keylen);
            knh_DataMap_setString(ctx, env_map, key, val);
        }
    }
    /* other variables */
    if (r->method != NULL) {
        knh_DataMap_setString(ctx, env_map, "REQUEST_METHOD", r->method);
        if (!strcmp(r->method, "POST")) {
            const char *readbody = NULL;
            util_read(r, &readbody);
            if (readbody != NULL) {
                knh_DataMap_setString(ctx, env_map, "QUERY_STRING", readbody);
                //fputs(readbody, stdin);
            }
        }
        else {
            if (r->args != NULL) {
                knh_DataMap_setString(ctx, env_map, "QUERY_STRING", r->args);
            }
        }
    }
    if (r->uri != NULL) {
        knh_DataMap_setString(ctx, env_map, "URI", r->uri);
    }
    if (r->path_info != NULL) {
        knh_DataMap_setString(ctx, env_map, "PATH_INFO", r->path_info);
    }
    const apr_array_header_t *arr = apr_table_elts(r->headers_in);
    apr_table_entry_t *elts = (apr_table_entry_t *)arr->elts;
    int i;
    for (i = 0; i < arr->nelts; i++) {
        knh_DataMap_setString(ctx, env_map, elts[i].key, elts[i].val);
        AP_LOG_DEBUG("elts[%s]=%s", elts[i].key, elts[i].val);
    }

    mn = knh_getmn(ctx, STEXT("startResponse"), MN_NONAME);
    cid = knh_getcid(ctx, STEXT("konoha.wsgi.Wsgi"));
    //AP_LOG_CRIT("mn=%d,cid=%d", mn, cid);
    AP_LOG_DEBUG("call method");
    kMethod *callback = knh_NameSpace_getMethodNULL(ctx, NULL, cid, mn);
    AP_LOG_DEBUG("call method end");
    if (callback == NULL) {
        AP_LOG_CRIT("callback is null");
        return -1;
    }
    kFunc *fo = new_H(Func);
    KNH_INITv(fo->mtd, callback);
    fo->baseNULL = NULL;

    KNH_SETv(ctx, lsfp[K_CALLDELTA+1].m, env_map);
    KNH_SETv(ctx, lsfp[K_CALLDELTA+2].fo, fo);
    KNH_SCALL(ctx, lsfp, 0, mtd, 2);
    END_LOCAL(ctx, lsfp);
    *content = S_totext(lsfp[0].s);
    KONOHA_END(ctx);
    return 0;
}

/* get config */
static int get_config(request_rec *r, CTX ctx, wsgi_config_t *conf, int debug)
{
    kString *status = GET_PROP("wsgi.status");
    kString *content_type = GET_PROP("wsgi.content_type");
    if (IS_KNULL(status) || IS_KNULL(content_type)) {
        AP_LOG_CRIT("status=%p, content_type=%p", status, content_type);
        return -1;
    }
    conf->status = apr_pstrdup(r->pool, S_totext(status));
    conf->content_type = apr_pstrdup(r->pool, S_totext(content_type));
    AP_LOG_DEBUG("status=%s", S_totext(status));
    AP_LOG_DEBUG("content_type=%s", S_totext(content_type));
    CLEAR_PROP("wsgi.status"); CLEAR_PROP("wsgi.content_type");
    return 0;
}

/* set headers */
static int set_headers(request_rec *r, CTX ctx, int debug, int rcode)
{
    kArray *cookies = (kArray *)knh_getPropertyNULL(ctx, STEXT("wsgi.cookie"));
    if (cookies != NULL) {
        size_t i;
        for (i = 0; i < knh_Array_size(cookies); i++) {
            kString *cookie = (kString *)knh_Array_n(cookies, i);
            if (cookie != NULL) {
                if (rcode == OK) {
                    apr_table_add(r->headers_out, "Set-Cookie", S_totext(cookie));
                    AP_LOG_DEBUG("Set-Cookie: %s", S_totext(cookie));
                }
                else {
                    apr_table_add(r->err_headers_out, "Set-Cookie", S_totext(cookie));
                    AP_LOG_DEBUG("Set-Cookie: %s", S_totext(cookie));
                }
            }
        }
    }
    CLEAR_PROP("wsgi.cookie");
    kString *location = GET_PROP("wsgi.location");
    if (!IS_KNULL(location)) {
        apr_table_set(r->headers_out, "Location", S_totext(location));
        AP_LOG_DEBUG("Location: %s", S_totext(location));
    }
    CLEAR_PROP("wsgi.location");
    return 0;
}

/* konoha handler */
static int konoha_handler(request_rec *r)
{
    if (strcmp(r->handler, "konoha")) {
        return DECLINED;
    }
    r->content_encoding = "utf-8";

    /* get config */
    konoha_config_t *kconf = (konoha_config_t *)ap_get_module_config(r->per_dir_config, &konoha_module);
    int debug = kconf->debug;
    const char *handler = kconf->handler;
    const char *package_dir = kconf->package_dir;
    int ret;

    /* check file existence */
    if (handler == NULL) {
        AP_LOG_CRIT("handler is null");
        return OK;
    }
    struct stat st;
    ret = stat(handler, &st);
    if (ret != 0) {
        AP_LOG_CRIT("KonohaHandler does not exists at %s.", handler);
        return OK;
    }

    if (package_dir != NULL) {
        setenv("KONOHA_PACKAGE", package_dir, 0);
    }

    /* call konoha main */
    int argc = 3;
    const char *argv[] = {
        "/usr/local/bin/konoha",
        handler,
        "-a"
    };
    if (!konoha_initialized) {
        konoha_initialized = 1;
        konoha_ginit(argc, argv);
        konoha = konoha_open();
        ret = konoha_main(konoha, argc, argv);
        if (ret != 0) goto TAIL;
    }
    const char *content = NULL;
    ret = start_application(r, konoha, debug, &content);
    if (ret != 0) goto TAIL;
    wsgi_config_t wconf;
    ret = get_config(r, konoha, &wconf, debug);
    if (ret != 0) goto TAIL;
    int rcode;
    switch (atoi(wconf.status)) {
    case 301:
        rcode = HTTP_MOVED_PERMANENTLY;
        break;
    case 302:
        rcode = HTTP_MOVED_TEMPORARILY;
        break;
    case 404:
        rcode = HTTP_NOT_FOUND;
        break;
    case 200:
    default:
        rcode = OK;
        break;
    }
    r->content_type = wconf.content_type;
    ret = set_headers(r, konoha, debug, rcode);
    ap_rputs(content, r);
    if (ret != 0) goto TAIL;
    //if (debug) {
    //    konoha_close(konoha);
    //    konoha_initialized = 0;
    //}
    return rcode;

TAIL:
    AP_LOG_CRIT("Konoha closed with error: %d", ret);
    return OK;
}

/* copy .conf arguments */
static const char *set_handler(cmd_parms *cmd, void *vp, const char *arg)
{
    (void)cmd;
    konoha_config_t *conf = (konoha_config_t *)vp;
    strncpy((char *)conf->handler, arg, PATHSIZE - 1);
    return NULL;
}

/* copy KonohaHandler to set KONOHA_PACKAGE environment variable */
static const char *set_package_dir(cmd_parms *cmd, void *vp, const char *arg)
{
    (void)cmd;
    konoha_config_t *conf = (konoha_config_t *)vp;
    strncpy((char *)conf->package_dir, arg, PATHSIZE - 1);
    return NULL;
}

/* copy .conf arguments */
static const char *set_debug(cmd_parms *cmd, void *vp, const char *arg)
{
    (void)cmd;
    konoha_config_t *conf = (konoha_config_t *)vp;
    if (!strcmp(arg, "on")) {
        conf->debug = 1;
    }
    return NULL;
}

/* configure konoha create dir */
static void *konoha_cdir_cfg(apr_pool_t *pool, char *arg)
{
    (void)arg;
    konoha_config_t *conf;
    conf = (konoha_config_t *)apr_palloc(pool, sizeof(konoha_config_t));
    conf->debug = 0;
    conf->handler = (const char *)apr_palloc(pool, sizeof(char) * PATHSIZE);
    conf->package_dir = (const char *)apr_palloc(pool, sizeof(char) * PATHSIZE);
    return (void *)conf;
}

/* konoha commands */
static const command_rec konoha_cmds[] = {
    AP_INIT_TAKE1("KonohaHandler",
        set_handler,
        NULL,
        OR_ALL,
        "set konoha handler"),
    AP_INIT_TAKE1("PackageDir",
        set_package_dir,
        NULL,
        OR_ALL,
        "set konoha package path"),
    AP_INIT_TAKE1("Debug",
        set_debug,
        NULL,
        OR_ALL,
        "set debug mode"),
    { NULL, {NULL}, NULL, 0, RAW_ARGS, NULL }
};

/* konoha register hooks */
static void konoha_register_hooks(apr_pool_t *p)
{
    (void)p;
    ap_hook_handler(konoha_handler, NULL, NULL, APR_HOOK_MIDDLE);
}

/* Dispatch list for API hooks */
module AP_MODULE_DECLARE_DATA konoha_module = {
    STANDARD20_MODULE_STUFF,
    konoha_cdir_cfg,       /* create per-dir    config structures */
    NULL,                  /* merge  per-dir    config structures */
    NULL,                  /* create per-server config structures */
    NULL,                  /* merge  per-server config structures */
    konoha_cmds,           /* table of config file commands       */
    konoha_register_hooks  /* register hooks                      */
};

