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
using konoha.posix.*;
using konoha.sql.*;
using konoha.uuid.*;
using konoha.wsgi.*;

/* ======================================================================== */
/* Native methods. */

include "lib:gluelink";

@Native @Singleton class Uuid;

@Native String Uuid.getUuid4();

@Native @Public int Date.getYear();
@Native @Public void Date.setYear(int year);
@Native @Public int Date.getMonth();
@Native @Public void Date.setMonth(int month);
@Native @Public int Date.getDay();
@Native @Public void Date.setDay(int day);
@Native @Public int Date.getHour();
@Native @Public void Date.setHour(int hour);
@Native @Public int Date.getMin();
@Native @Public void Date.setMin(int min);
@Native @Public int Date.getSec();
@Native @Public void Date.setSec(int sec);
@Native @Public int Date.getGmtoff();
@Native @Public void Date.setGmtoff(int gmtoff);
@Native @Public String Date.toRFC1123();

/* ======================================================================== */
/* Utilities. */

@Public String String.escapeHtml()
{
    return Cgi.htmlEscape(this);
}

@Public String String.escapeSql()
{
    if (this.indexOf(";") >= 0) {
        throw new Script!!("Invalid sql.");
    }
    return this.replace($/'/, "''").replace($/\\/, "\\\\");
}

/* ======================================================================== */
/* Private methods. */

boolean isDebug()
{
    String debug = $DEBUG;
    if (debug == "true" || debug == "on") {
        return true;
    }
    return false;
}

String getDatabase(String dbname)
{
    if (dbname == null) {
        dbname = "default";
    }
    Map dbs = $DATABASES;
    if (dbs == null) {
        throw new Script!!("$DATABASES is null");
    }
    if (dbs[dbname] == null) {
        if (isDebug()) {
            ERR << "$DATABASES['" + dbname + "'] is null" << EOL;
        }
        dbname = "default";
        if (dbs[dbname] == null) {
            throw new Script!!("$DATABASES['default'] is null");
        }
    }
    if (dbs[dbname]["name"] == null) {
        throw new Script!!("$DATABASES['" + dbname + "']['name'] is null");
    }
    return dbs[dbname]["name"];
}

String getMediaDir()
{
    String mediadir = $MEDIA_DIR;
    if (mediadir == null) {
        throw new Script!!("$MEDIA_DIR is null");
    }
    return mediadir;
}

String getModelDir()
{
    String modeldir = $MODEL_DIR;
    if (modeldir == null) {
        throw new Script!!("$MODEL_DIR is null");
    }
    return modeldir;
}

String getViewDir()
{
    String viewdir = $VIEW_DIR;
    if (viewdir == null) {
        throw new Script!!("$VIEW_DIR is null");
    }
    return viewdir;
}

String getTmpDir()
{
    String tmpdir = $TMP_DIR;
    if (tmpdir == null) {
        if (isDebug()) {
            ERR << "$TMP_DIR is null" << EOL;
        }
        tmpdir = "/tmp/";
    }
    return tmpdir;
}

String getBaseUrl()
{
    String baseurl = $BASE_URL;
    if (baseurl == null) {
        throw new Script!!("$BASE_URL is null");
    }
    return baseurl;
}

String getStaticUrl()
{
    String staticurl = $STATIC_URL;
    if (staticurl == null) {
        throw new Script!!("$STATIC_URL is null");
    }
    return staticurl;
}

String[] getMiddlewares()
{
    String[] middlewares = $MIDDLEWARES;
    if (middlewares == null) {
        if (isDebug()) {
            ERR << "$MIDDLEWARES is null" << EOL;
        }
        middlewares = [];
    }
    return middlewares;
}

String escapeSqlValue(dynamic sql)
{
    Class c = sql.class;
    if (c == String) {
        return "'" + sql.escapeSql() + "'";
    }
    else if (c == int) {
        int i = sql;
        return ((to String)i).escapeSql();
    }
    else {
        throw new Script!!("sql: Unsupported type is included.");
    }
}

/* ======================================================================== */
/* Classes. */

class Model
{
    String db_path;
    String name;

    Model(String name, Map<Class> scheme, String[] primary_keys) {
        name = name.escapeSql();
        String query = "create table if not exists " + name + "(";
        String[] keys = scheme.keys();
        for (int i = 0; i < |keys|; i++) {
            String key = keys[i];
            String column = key.escapeSql();
            String type = "";
            Class c = scheme[key];
            if (c == String) {
                type = "text";
            }
            else if (c == int) {
                type = "integer";
            }
            else {
                throw new Script!!("scheme['" + key + "']: Unsupported type is given.");
            }
            if (i < |keys| - 1) {
                query += column + " " + type + ", ";
            }
            else {
                query += column + " " + type;
                if (|primary_keys| > 0) {
                    query += ", primary key(";
                    for (int j = 0; j < |primary_keys|; j++) {
                        if (j < |primary_keys| - 1) {
                            query += primary_keys[j].escapeSql() + ", ";
                        }
                        else {
                            query += primary_keys[j].escapeSql() + ")";
                        }
                    }
                }
                query += ")";
            }
        }
        if (isDebug()) {
            ERR << "model query: " << query << EOL;
        }
        _db_path = getDatabase(name);
        _name = name;
        Connection con = new Connection(db_path);
        con.exec(query);
        con.close();
    }

    Map[] get(String column, Map param) {
        column = column.escapeSql();
        String query = "select " + column + " from " + name;
        if (param != null && |param| > 0) {
            query += " where ";
            String[] keys = param.keys();
            for (int i = 0; i < |keys|; i++) {
                String key = keys[i];
                String value = escapeSqlValue(param[key]);
                if (i < |keys| - 1) {
                    query += key + " = " + value + " and ";
                }
                else {
                    query += key + " = " + value;
                }
            }
        }
        if (isDebug()) {
            ERR << "get query: " << query << EOL;
        }
        Connection con = new Connection(db_path);
        ResultSet r = con.query(query);
        Map[] results = [];
        while (r.next()) {
            Map record = {};
            for (int i = 0; i < |r|; i++) {
                String name = r.getName(i);
                record[name] = r[name];
                if (isDebug()) {
                    ERR << "record[" << name << "]=" << r[name] << EOL;
                }
            }
            results.add(record);
        }
        con.close();
        return results;
    }

    void set(Map record) {
        String query = "insert or replace into " + name + "(";
        String[] values = [];
        String[] keys = record.keys();
        for (int i = 0; i < |keys|; i++) {
            String key = keys[i];
            values.add(escapeSqlValue(record[key]));
            if (i < |keys| - 1) {
                query += key.escapeSql() + ", ";
            }
            else {
                query += key.escapeSql() + ") values(";
            }
        }
        for (int i = 0; i < |values|; i++) {
            if (i < |values| - 1) {
                query += values[i] + ", ";
            }
            else {
                query += values[i] + ")";
            }
        }
        if (isDebug()) {
            ERR << "set query: " << query << EOL;
        }
        Connection con = new Connection(db_path);
        con.exec(query);
        con.close();
    }

    void add(Map record) {
        String query = "insert into " + name + "(";
        String[] values = [];
        String[] keys = record.keys();
        for (int i = 0; i < |keys|; i++) {
            String key = keys[i];
            values.add(escapeSqlValue(record[key]));
            if (i < |keys| - 1) {
                query += key.escapeSql() + ", ";
            }
            else {
                query += key.escapeSql() + ") values(";
            }
        }
        for (int i = 0; i < |values|; i++) {
            if (i < |values| - 1) {
                query += values[i] + ", ";
            }
            else {
                query += values[i] + ")";
            }
        }
        if (isDebug()) {
            ERR << "add query: " << query << EOL;
        }
        Connection con = new Connection(db_path);
        con.exec(query);
        con.close();
    }

    void remove(Map record) {
        String query = "delete from " + name + " where ";
        String[] keys = record.keys();
        for (int i = 0; i < |keys|; i++) {
            String key = keys[i];
            if (i < |keys| - 1) {
                query += key.escapeSql() + " = " + escapeSqlValue(record[key]) + " and ";
            }
            else {
                query += key.escapeSql() + " = " + escapeSqlValue(record[key]);
            }
        }
        if (isDebug()) {
            ERR << "remove query: " << query << EOL;
        }
        Connection con = new Connection(db_path);
        con.exec(query);
        con.close();
    }

    void update(Map record, Map param) {
        String query = "update " + name + " set ";
        String[] keys = record.keys();
        int i;
        for (i = 0; i < |keys|; i++) {
            String key = keys[i];
            if (i < |keys| - 1) {
                query += key.escapeSql() + " = " + escapeSqlValue(record[key]) + ", ";
            }
            else {
                query += key.escapeSql() + " = " + escapeSqlValue(record[key]);
            }
        }
        if (param != null && |param| > 0) {
            query += " where ";
            keys = param.keys();
            for (i = 0; i < |keys|; i++) {
                String key = keys[i];
                if (i < |keys| - 1) {
                    query += key.escapeSql() + " = " + escapeSqlValue(param[key]) + " and ";
                }
                else {
                    query += key.escapeSql() + " = " + escapeSqlValue(param[key]);
                }
            }
        }
        if (isDebug()) {
            ERR << "update query: " << query << EOL;
        }
        Connection con = new Connection(db_path);
        con.exec(query);
        con.close();
    }
}

/* ------------------------------------------------------------------------ */
/* matsu */

@Singleton class FileStorage
{
    String checkName(String name) {
        if(name.indexOf("/") != -1) return null;
        if(name.indexOf("..") != -1) return null;
        return getMediaDir() + name;
    }

    InputStream open(String name, String mode) {
        name = checkName(name);
        if(name != null) {
            return new InputStream(name, mode);
        }
        return null;
    }

    OutputStream newFile(String name, String mode) {
        name = checkName(name);
        if (isDebug()) {
            ERR << "newFile: " << name << EOL;
        }
        if(name != null) {
            return new OutputStream(name, mode);
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
    Model group;

    Group(String name) {
        _name = name;
        _group = new Model("group_perms", {
            "name": String,
            "permissions": String
        });
    }

    boolean hasPermission(Permission perm) {
        Map[] m = group.get("*", {"name": name});
        if (|m| == 1) {
            String perms = (m[0]["permissions"] == null) ? "" : m[0]["permissions"];
            foreach (String p in perms.split(",")) {
                if (p == perm.name) return true;
            }
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
        Model user = new Model("users", {
            "id": int,
            "name": String,
            "password": String,
            "permissions": String,
            "groups": String
        }, ["id", "name"]);
        Map[] m = user.get("*", {
            "name": name,
            "password": password.convert(to:md5)
        });
        if (|m| == 1) {
            String perms = (m[0]["permissions"] == null) ? "" : m[0]["permissions"];
            String groups = (m[0]["groups"] == null) ? "" : m[0]["permissions"];
            String[] p = perms.split(",");
            String[] g = groups.split(",");
            return new User(name, p, g);
        }
        if (isDebug()) {
            ERR << "authenticate result: " << m << EOL;
        }
        return null;
    }

    @Static boolean hasUser(String name) {
        Model user = new Model("users", {
            "id": int,
            "name": String,
            "password": String,
            "permissions": String,
            "groups": String
        }, ["id", "name"]);
        Map[] m = user.get("*", {
            "name": name
        });
        if (|m| == 1) {
            if (isDebug()) {
                ERR << "user '" + name + "' exists" << EOL;
            }
            return true;
        }
        if (isDebug()) {
            ERR << "user '" + name + "' does not exist" << EOL;
        }
        return false;
    }

    @Static User addUser(String name, String password) {
        if (User.hasUser(name) || |name| > 20) {
            return null;
        }
        Model user = new Model("users", {
            "id": int,
            "name": String,
            "password": String,
            "permissions": String,
            "groups": String
        }, ["id", "name"]);
        user.add({
            "name": name,
            "password": password.convert(to:md5)
        });
        return new User(name, [], []);
    }

    @Static String[] getList() {
        Model user = new Model("users", {
            "id": int,
            "name": String,
            "password": String,
            "permissions": String,
            "groups": String
        }, ["id", "name"]);
        Map[] maps = user.get("name");
        String[] list = [];
        foreach (Map m in maps) {
            list.add(m["name"]);
        }
        return list;
    }
}

/* ------------------------------------------------------------------------ */

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
            path = getViewDir() + path;
        }
        _file = path;
    }

    void loadSettingValues(Hdf hdf) {
        hdf.setValue("STATIC_URL", getStaticUrl());
        hdf.setValue("BASE_URL", getBaseUrl());
        hdf.setValue("hdf.loadpaths.0", getViewDir());
        hdf.setValue("hdf.loadpaths.1", getModelDir());
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
    }

    void set(String key, dynamic value) {
        if (value.class == int) {
            int ival = value;
            hdf.setIntValue(key, ival);
        }
        else if (value.class == String) {
            String sval = value;
            hdf.setValue(key, sval.escapeHtml());
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
        else if (value == null) {
            if (isDebug()) {
                ERR << "Template['" + key + "']: value is null. ignored." << EOL;
            }
        }
        else {
            throw new Script!!("Template['" + key + "']: Unsupported type is given.");
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
            path = getModelDir() + path;
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

    boolean save(String name) {
        String path = FileStorage.checkName(name);
        if (path == null) return false;
        hdf.writeFileAtomic(path);
        return true;
    }

    boolean load(String name) {
        String path = FileStorage.checkName(name);
        if (path == null) return false;
        InputStream ins = new InputStream(path);
        if (ins == null) {
            return false;
        }
        ins.close();
        hdf.readFile(path);
        return true;
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
    int status;
    Tuple<String,String>[] h;

    HttpResponse(String content, Tuple<String,String>[] headers) {
        _content = content;
        _h = headers;
        if (h == null) {
            _h = [];
        }
    }

    void set(String header, String value) {
        h.add((header, value));
    }

    String[] get(String header) {
        String[] ret = [];
        foreach (Tuple<String,String> t in _h) {
            if (t[0] == header) {
                ret.add(t[1]);
            }
        }
        return ret;
    }

    String[] keys(void) {
        String[] keys = []
        foreach (Tuple<String,String> t in _h) {
            if (not (t[0] in? keys)) {
                keys.add(t[0]);
            }
        }
        return keys;
    }

    void setCookie(String key, String value, String expires, String path) {
        path = (path == null) ? "/" : path;
        String cookie = key + "=" + value + "; ";
        if (expires != null && expires != "") {
            cookie += "expires=" + expires + "; ";
        }
        cookie += "path=" + path ;
        this["Set-Cookie"] = cookie;
        if (isDebug()) {
            ERR << "Set-Cookie: " << cookie << EOL;
        }
    }

    void deleteCookie(String key, String path) {
        path = (path == null) ? "/" : path;
        String cookie = key + "=dummy; ";
        Date past = new Date();
        past.year = 1970;
        cookie += "expires=" + past.toRFC1123() + "; ";
        this["Set-Cookie"] = cookie;
        if (isDebug()) {
            ERR << "Delete-Cookie: " << cookie << EOL;
        }
    }
}

@Singleton class Url
{
    Tuple<Regex,Func<HttpRequest,String[]=>HttpResponse>>[] getPatterns() {
        Tuple<Regex,Func<HttpRequest,String[]=>HttpResponse>>[] patterns = $veins.urlpatterns;
        if (patterns == null) {
            $veins.urlpatterns = new Tuple<Regex,Func<HttpRequest,String[]=>HttpResponse>>[0];
        }
        return $veins.urlpatterns;
    }

    void setPatterns(Tuple<Regex,Func<HttpRequest,String[]=>HttpResponse>>[] patterns) {
        $veins.urlpatterns = patterns;
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
        _path = getTmpDir() + fname;
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
            throw new Script!!("Session['" + key + "']: Unsupported type is given.");
        }
    }

    void store() {
        OutputStream ous = new OutputStream(path);
        ous.writeJson(m);
        ous.close();
    }
}


/* ======================================================================== */
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
            res.setCookie("SESSION", req.session.fname, now.toRFC1123());
        }
        req.session.store();
        return res;
    }
}

/* ======================================================================== */

HttpRequest g_req;
HttpResponse g_res;
Func<HttpRequest,String[]=>HttpResponse> g_handler;
String[] g_args;

@Public String Wsgi.application(Map<String> environ,
        Func<String,Tuple<String,String>[]> start_response)
{
    String[] middlewares = getMiddlewares();
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
        foreach (Tuple<Regex,Func<HttpRequest,String[]=>HttpResponse>> t in Url.getPatterns()) {
            if (path.search(t[0]) >= 0) {
                g_args = path.split("/");
                if (|g_args| > 0) {
                    g_args.remove(0);
                }
                g_handler = t[1];
                if (isDebug()) {
                    ERR << "handler: " << g_handler << EOL;
                    ERR << "args: " << g_args << EOL;
                }
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
    if (g_res != null) {
        foreach (String middleware in middlewares) {
            eval("g_res = " + middleware + ".hookResponse(g_req, g_res);");
        }
        Tuple<String,String>[] headers = g_res.h;
        if (not "Content-Type" in? headers) {
            headers.add(("Content-Type", "text/html"));
        }
        String status = "";
        switch (g_res.status) {
        case 301:
            status = "301 Moved Permanently";
            break;
        case 404:
            status = "404 Not Found";
            break;
        case 200:
        default:
            status = "200 OK";
            break;
        }
        start_response(status, headers);
        return g_res.content;
    }
    if (not path.endsWith("/")) {
        String redirect_url = environ["URI"] + "/";
        start_response("301 Moved Permanently", [
            ("Content-Type", "text/html"),
            ("Location", redirect_url)
        ]);
        return "";
    }
    start_response("404 Not Found", [("Content-Type", "text/html")]);
    return "";
}
