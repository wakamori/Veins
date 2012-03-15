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

using konoha.conv.*;
using konoha.wsgi.*;
using konoha.clearsilver.*;

class TemplateContext {
    Cs cs;
    String str;
    Path file;

    TemplateContext(String context) {
        _str = context;
    }

    void parseFile(Path path) {
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

class Template {
    Hdf hdf;
    String buf;

    Template(String template) {
        _hdf = new Hdf();
        if (template != null) {
            hdf.readString(template);
        }
    }

    void readFile(Path path) {
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

class HttpRequest
{
    String path;
    String method;
    Map<String> get_params;
    Map<String> post_params;

    HttpRequest(String path, String method, String query) {
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
    }
}

class HttpResponse
{
    String content;
    Map<String> _h;

    HttpResponse(String content) {
        _content = content;
        _h = {};
    }

    void set(String header, String value) {
        _h[header] = value;
    }

    String get(String header) {
        return _h[header];
    }

    String[] keys(void) {
        return _h.keys();
    }
}

@Singleton class Url
{
    Tuple<Regex,Func<HttpRequest=>HttpResponse>>[] getPatterns() {
        if ($veins.defurlpatterns == null) {
            $veins.defurlpatterns = "Urlpatterns";
            $veins.urlpatterns = new Tuple<Regex,Func<HttpRequest=>HttpResponse>>[0];
        }
        return $veins.urlpatterns;
    }

    void setPatterns(Tuple<Regex,Func<HttpRequest=>HttpResponse>>[] patterns) {
        $veins.defurlpatterns = "Urlpatterns";
        $veins.urlpatterns = patterns;
    }
}

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

boolean isDebug() {
    if ($DEBUG == "true") {
        return true;
    }
    return false;
}

@Public String Wsgi.application(Map<String> environ,
        Func<String,Tuple<String,String>[]> start_response)
{
    String path = environ["PATH_INFO"];
    if (isDebug()) {
        foreach (String e in environ.keys()) {
            ERR << "env[" + e + "]=" + environ[e] << EOL;
        }
        ERR << "path: " + path << EOL;
    }
    HttpResponse res = null;
    if ($veins.defurlpatterns != null) {
        foreach (Tuple<Regex,Func<HttpRequest=>HttpResponse>> t in $veins.urlpatterns) {
            if (|path.match(t[0])| > 0) {
                String method = environ["REQUEST_METHOD"];
                String query = environ["QUERY_STRING"];
                HttpRequest req = new HttpRequest(path, method, query);
                res = t[1](req);
                break;
            }
        }
    }
    if (res != null) {
        Tuple<String,String>[] headers = [];
        foreach (String header in res.keys()) {
            headers.add((header, res[header]));
        }
        start_response("200 OK", headers);
        return res.content;
    }
    start_response("200 OK", [("Content-Type", "text/plain")]);
    return "Hello, world";
}
