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

using konoha.clearsilver.*;
using konoha.conv.*;
using konoha.cookie.*;
using konoha.io.*;
using konoha.json.*;
using konoha.posix.*;
using konoha.uuid.*;
using konoha.wsgi.*;

/* ------------------------------------------------------------------------ */
/* Private methods. */

boolean isDebug()
{
    if ($DEBUG == "true") {
        return true;
    }
    return false;
}

/* ------------------------------------------------------------------------ */
/* Utilities. */

@Public void System.includeScript(String name)
{
    if ($veins.root == null) {
        script_name = $script.name;
        if (script_name.indexOf("/") >= 0) {
            $veins.root = script_name.substring(0, script_name.lastIndexOf("/"));
        }
    }
    if ($veins.root != null && !name.startsWith("/")) {
        eval("include \"" + $veins.root + "/" + name + "\";");
    }
}

/* ------------------------------------------------------------------------ */
/* Classes. */

class TemplateContext
{
    Cs cs;
    String str;
    Path file;

    TemplateContext(String context) {
        _str = context;
    }

    void parseFile(Path path) {
        if (!((to String)path).startsWith("/")) {
            path = $VIEW_DIR + path;
        }
        _file = path;
    }

    void loadSettingValues(Hdf hdf) {
        String static_url = $STATIC_URL;
        if (static_url != null) {
            if (isDebug()) {
                ERR << "$STATIC_URL=" << static_url << EOL;
            }
            hdf.setValue("STATIC_URL", static_url);
        }
        String base_url = $BASE_URL;
        if (base_url != null) {
            if (isDebug()) {
                ERR << "$BASE_URL=" << base_url << EOL;
            }
            hdf.setValue("BASE_URL", base_url);
        }
        String view_dir = $VIEW_DIR;
        if (view_dir != null) {
            if (isDebug()) {
                ERR << "$VIEW_DIR=" << view_dir << EOL;
            }
            hdf.setValue("hdf.loadpaths.0", view_dir);
        }
        String model_dir = $MODEL_DIR;
        if (model_dir != null) {
            if (isDebug()) {
                ERR << "$MODEL_DIR=" << model_dir << EOL;
            }
            if (view_dir == null) {
                hdf.setValue("hdf.loadpaths.0", model_dir);
            }
            else {
                hdf.setValue("hdf.loadpaths.1", model_dir);
            }
        }
    }

    void loadHdf(Hdf hdf) {
        loadSettingValues(hdf);
        if (isDebug()) {
            hdf.writeFile("/tmp/hdf");
        }
        _cs = new Cs(hdf);
        if (str != null) {
            cs.parseString(str);
        }
        if (file != null) {
            cs.parseFile(file);
        }
    }
}

class Template
{
    Hdf hdf;
    String buf;

    Template(String template) {
        _hdf = new Hdf();
        if (template != null) {
            hdf.readString(template);
        }
        _count = 0;
    }

    void set(String key, dynamic value) {
        if (value.class == int) {
            int ival = value;
            hdf.setIntValue(key, ival);
        }
        else if (value.class == String) {
            String sval = value;
            hdf.setValue(key, sval);
        }
        else if (value.class == Array) {
            int i = 0;
            for (; i < |value|; i++) {
                this[key + "." + (to String)i] = value[i];
            }
        }
        else if (value.class == Map) {
            String[] mkeys = value.keys();
            for (int i = 0; i < |mkeys|; i++) {
                this[key + "." + mkeys[i]] = value[mkeys[i]];
            }
        }
        else {
            if (isDebug()) {
                ERR << "unsupported type: " << value.class << EOL;
            }
        }
    }

    int getInt(String key) {
        return hdf.getIntValue(key);
    }

    String get(String key) {
        return hdf.getValue(key);
    }

    void readFile(Path path) {
        if (!((to String)path).startsWith("/")) {
            path = $MODEL_DIR + path;
        }
        hdf.readFile(path);
    }

    int render_cb(String s) {
        buf += s;
        return Cs.STATUS_OK;
    }

    String render(TemplateContext context) {
        _buf = "";
        context.loadHdf(hdf);
        context.cs.render(delegate(this, render_cb));
        return buf;
    }
}

@Expando class HttpRequest
{
    String path;
    String method;
    Map<String> params_get;
    Map<String> params_post;
    Map<String> cookies;

    HttpRequest(String path, String method, String query, String cookie) {
        _path = path;
        _method = method;
        Map<String> m = {};
        foreach (String param in query.split("&")) {
            String[] k_v = param.split("=");
            if (|k_v| == 2 && k_v[1] != null) {
                m[k_v[0]] = k_v[1].convert(to:durl);
            }
            else {
                m[k_v[0]] = "";
            }
        }
        if (method == "GET") {
            _params_get = m;
        }
        else if (method == "POST") {
            _params_post = m;
        }
        m = {};
        if (cookie != null) {
            foreach (String ck in cookie.replace($/ /, "").split(";")) {
                String[] k_v = ck.split("=");
                m[k_v[0]] = k_v[1];
            }
        }
        _cookies = m;
    }
}

class HttpResponse
{
    String content;
    Map<String> h;

    HttpResponse(String content) {
        _content = content;
        _h = {};
    }

    void set(String header, String value) {
        h[header] = value;
    }

    String get(String header) {
        return h[header];
    }

    String[] keys(void) {
        return h.keys();
    }
}

@Singleton class Url
{
    Tuple<Regex,Func<HttpRequest,String[]=>HttpResponse>>[] getPatterns() {
        if ($veins.defurlpatterns == null) {
            $veins.defurlpatterns = "Urlpatterns";
            $veins.urlpatterns = new Tuple<Regex,Func<HttpRequest,String[]=>HttpResponse>>[0];
        }
        return $veins.urlpatterns;
    }

    void setPatterns(Tuple<Regex,Func<HttpRequest,String[]=>HttpResponse>>[] patterns) {
        $veins.defurlpatterns = "Urlpatterns";
        $veins.urlpatterns = patterns;
        if (isDebug()) {
            ERR << "urlpatterns: " << ($veins.urlpatterns).class << EOL;
        }
    }
}

@Singleton class Middleware
{
    @Virtual HttpResponse hookRequest(HttpRequest req);
    @Virtual HttpResponse hookHandler(HttpRequest req,
            Func<HttpRequest,String[]=>HttpResponse> callback, String[] args);
    @Virtual HttpResponse hookResponse(HttpRequest req, HttpResponse res);
    //@Virtual HttpResponse hookException(HttpRequest req, Exception e);
}

class Session
{
    Path path;
    String fname;
    String origname;
    Map m;

    Session(String name) {
        if (name != null) {
            _origname = name;
            _fname = name.convert(to:md5);
        }
        else {
            _origname = Uuid.getUuid4();
            _fname = origname.convert(to:md5);
        }
        String tmp_dir = $TMP_DIR;
        if (tmp_dir != null) {
            _path = tmp_dir + fname;
        }
        else {
            _path = "/tmp/" + fname;
        }
        load();
    }

    Session renew(String name) {
        if (System.unlink(path)) {
            if (isDebug()) {
                ERR << "unlink: " << path << EOL;
            }
        }
        else {
            if (isDebug()) {
                ERR << "unlink failed: " << path << EOL;
            }
        }
        return new Session(name);
    }

    void load() {
        InputStream ins = new InputStream(path);
        if (ins == null) {
            _m = {};
        }
        else {
            _m = ins.readJson();
            ins.close();
        }
    }

    dynamic get(String key) {
        return m[key];
    }

    String[] keys() {
        return m.keys();
    }

    void remove(String key) {
        m.remove(key);
    }

    void set(String key, dynamic val) {
        Class[] classes = [String, Int, Float];
        if (val.class in? classes) {
            m[key] = val;
        }
        else {
            if (isDebug()) {
                ERR << "unsupported type: " << val.class << EOL;
            }
        }
    }

    void store() {
        OutputStream ous = new OutputStream(path);
        ous.writeJson(m);
        ous.close();
    }
}

/* ------------------------------------------------------------------------ */
/* matsu */

@Singleton class FileStorage
{
    String checkName(String name) {
        if(name.indexOf("/") != -1) return null;
        if(name.indexOf("..") != -1) return null;
        String storage_root;
        if ($USER_DIR != null) {
            storage_root = $USER_DIR
        }
        else {
            storage_root = $TMP_DIR;
            if (storage_root == null) {
                storage_root = "/tmp/";
            }
        }
        return STORAGE_ROOT + name;
    }

    InputStream open(String name) {
        name = checkName(name);
        if(name != null) {
            return new InputStream(name);
        }
        return null;
    }

    OutputStream newFile(String name) {
        name = checkName(name);
        if (isDebug()) {
            ERR << "newFile: " << name << EOL;
        }
        if(name != null) {
            return new OutputStream(name);
        }
        return null;
    }
}

class Permission
{
    String name;
    Permission(String name) { _name = name; }
}

class Group
{
    String name;
    Group(String name) { _name = name; }

    boolean hasPermission(Permission perm) {
        Connection c = new(user_db);
        try {
            r = c.query("select * from group_perms");
            while(r.next()) {
                if(r.getString("name") == name) {
                    foreach(String p in r.getString("permissions").split(",")) {
                        if(p == perm.name) return true;
                    }
                }
            }
        } finally {
            c.close();
        }
        return false;
    }
}

class User
{
    String name;
    String[] perms;
    String[] groups;

    User(String name, String[] perms, String[] groups) {
        _name = name;
        _perms = perms;
        _groups = groups;
    }

    boolean hasPermission(Permission perm) {
        foreach(String p in perms) {
            if(p == perm.name) return true;
        }
        foreach(String g in groups) {
            if(new Group(g).hasPermission(perm)) return true;
        }
        return false;
    }

    @Static User authenticate(String name, String password) {
        Connection c = new(user_db);
        try {
            r = c.query("select * from users");
            while(r.next()) {
                if(r.getString("name") == name && r.getString("password") == password) {
                    String[] p = r.getString("permissions").split(",");
                    String[] g = r.getString("groups").split(",");
                    return new User(name, p, g);
                }
            }
            return null;
        } finally {
            c.close();
        }
    }
}

/* ------------------------------------------------------------------------ */
/* Builtin middlwares. */

class SessionMiddleware extends Middleware
{
    HttpResponse hookRequest(HttpRequest req) {
        if (isDebug()) {
            ERR << "hook request: " << req << EOL;
        }
        if (req.cookies["SESSION"] != null) {
            if (isDebug()) {
                ERR << "SESSION: " << req.cookies["SESSION"] << EOL;
            }
            req.session = new Session(req.cookies["SESSION"]);
        }
        else {
            req.session = new Session();
        }
        return null;
    }

    HttpResponse hookHandler(HttpRequest req,
            Func<HttpRequest,String[]=>HttpResponse> callback, String[] args) {
        if (isDebug()) {
            ERR << "hook handler: " << req << callback << args << EOL;
        }
        return null;
    }

    HttpResponse hookResponse(HttpRequest req, HttpResponse res) {
        if (isDebug()) {
            ERR << "hook response" << EOL;
        }
        if (req.cookies["SESSION"] == null ||
                req.cookies["SESSION"] != req.session.origname) {
            if (isDebug()) {
                ERR << "old session: " << req.cookies["SESSION"] << EOL;
                ERR << "new session: " << req.session.fname.convert(to:md5) << EOL;
            }
            Date now = new Date();
            if (now.day < 15) {
                now.day += 14;
            }
            else if (now.month < 12) {
                now.day -= 14;
                now.month += 1;
            }
            else {
                now.year += 1;
                now.day -= 14;
                now.month -= 11;
            }
            String cookie = "SESSION=" + req.session.fname + "; ";
            cookie += "expires=" + now.toRFC1123() + "; ";
            cookie += "path=/";
            res["Set-Cookie"] = cookie;
            if (isDebug()) {
                ERR << "Set-Cookie: " << cookie << EOL;
            }
        }
        req.session.store();
        return res;
    }
}

/* ------------------------------------------------------------------------ */

HttpRequest g_req;
HttpResponse g_res;
Func<HttpRequest,String[]=>HttpResponse> g_handler;
String[] g_args;

@Public String Wsgi.application(Map<String> environ,
        Func<String,Tuple<String,String>[]> start_response)
{
    String[] middlewares = $MIDDLEWARES;
    String path = environ["URI"];
    if (|path| >= 1 && path != "/") {
        path = path.substring(1);
    }
    if (isDebug()) {
        foreach (String e in environ.keys()) {
            ERR << "env[" + e + "]=" + environ[e] << EOL;
        }
        ERR << "path: " + path << EOL;
    }
    String method = environ["REQUEST_METHOD"];
    String query = environ["QUERY_STRING"];
    String cookie = environ["Cookie"];
    g_req = new HttpRequest(path, method, query, cookie);
    g_res = null;
    foreach (String middleware in middlewares) {
        eval("g_res = " + middleware + ".hookRequest(g_req);");
        if (g_res != null) {
            break;
        }
    }
    if (g_res == null) {
        if ($veins.defurlpatterns != null) {
            foreach (Tuple<Regex,Func<HttpRequest,String[]=>HttpResponse>> t in $veins.urlpatterns) {
                if (isDebug()) {
                    ERR << "tuple: " << t << EOL;
                }
                if (path.search(t[0]) >= 0) {
                    g_args = path.split("/");
                    if (|g_args| > 0) {
                        g_args.remove(0);
                    }
                    g_handler = t[1];
                    foreach (String middleware in middlewares) {
                        eval("g_res = " + middleware + ".hookHandler(g_req, g_handler, g_args);");
                    }
                    if (g_res != null) {
                        break;
                    }
                    g_res = g_handler(g_req, g_args);
                    break;
                }
            }
        }
    }
    if (g_res != null) {
        foreach (String middleware in middlewares) {
            eval("g_res = " + middleware + ".hookResponse(g_req, g_res);");
        }
        Tuple<String,String>[] headers = [];
        foreach (String header in g_res.keys()) {
            headers.add((header, g_res[header]));
        }
        start_response("200 OK", headers);
        return g_res.content;
    }
    start_response("404 Not Found", [("Content-Type", "text/html")]);
    return "";
}
