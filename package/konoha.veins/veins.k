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
using konoha.io.*;
using konoha.json.*;
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
        if (!path.startsWith("/")) {
            path = $VIEW_DIR + path;
        }
        _file = path;
    }

    void loadHdf(Hdf hdf) {
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
    }

    void readFile(Path path) {
        if (!path.startsWith("/")) {
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
    Map<String> get_params;
    Map<String> post_params;
    Map<String> cookies;

    HttpRequest(String path, String method, String query, String cookie) {
        _path = path;
        _method = method;
        Map<String> m = {};
        foreach (String param in query.split("&")) {
            String[] k_v = param.split("=");
            m[k_v[0]] = k_v[1].convert(to:durl);
        }
        if (method == "GET") {
            _get_params = m;
        }
        else if (method == "POST") {
            _post_params = m;
        }
        m = {};
        foreach (String ck in cookie.replace($/ /, "").split(";")) {
            String[] k_v = ck.split("=");
            m[k_v[0]] = k_v[1];
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

    Session(String name) {
        if (name != null) {
            _fname = name.convert(to:md5);
        }
        else {
            _fname = Uuid.getUuid4().convert(to:md5);
        }
        if ($TMP_DIR != null) {
            _path = $TMP_DIR + fname;
        }
        else {
            _path = "/tmp/" + fname;
        }
    }

    dynamic get(String key) {
        InputStream ins = new InputStream(path);
        Map m = ins.readJson();
        ins.close();
        return m[key];
    }

    void set(String key, dynamic val) {
        switch (val.class) {
        case String: case Int: case Float:
            InputStream ins = new InputStream(path);
            Map m = ins.readJson();
            ins.close();
            m[key] = val;
            OutputStream ous = new OutputStream(path);
            ous.writeJson(m);
            ous.close();
            break;
        default:
            if (isDebug()) {
                ERR << "unsupported type: " << val.class << EOL;
            }
            break;
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
            ERR << "hook response: " << req << res << EOL;
        }
        if (req.cookies["SESSION"] == null) {
            String cookie = "SESSION=" + req.session.fname + "; ";
            cookie += "expires=" + 
        }
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
    String path = environ["PATH_INFO"];
    if (|path| >= 1) {
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
    start_response("200 OK", [("Content-Type", "text/plain")]);
    return "Hello, world";
}
