/**
 * Controller script.
 */

/* It must be called before veins package is loaded. */
include "/Users/chen_ji/Devel/git/Veins/aspen/settings.k";

using konoha.veins.*;

if (not defined TRACE_USER) {
    TRACE_USER = true;
}

if (not defined Git) {
    class Git
    {
        String path;
        String cmd;

        Git(String path) {
            _path = path;
            _cmd = "/Users/chen_ji/Devel/git/Veins/aspen/subproc-git.sh -d \"" + path + "\"";
        }

        void init() {
            exec(cmd + " -c init");
        }

        void add(String file) {
            exec(cmd + " -c add -a \"" + file + "\"");
        }

        void commit(String msg) {
            exec(cmd + " -c commit -a \"-m '" + msg + "'\"");
        }

        void commitAll(String msg) {
            exec(cmd + " -c commit -a \"-a -m '" + msg + "'\"");
        }
    }
}

HttpResponse redirect(String location)
{
    HttpResponse res = new HttpResponse();
    res["Location"] = location;
    res.status = 302;
    return res;
}

Model defineScripts()
{
    return new Model("scripts", {
        "user": String,
        "id": String,
        "name": String,
        "readme": String,
        "js": String,
        "ks": String,
        "html": String,
        "date": String
    }, ["user", "id"]);
}

Model defineInquiries()
{
    return new Model("inquiries", {
        "id": AutoIncrementInt,
        "title": String,
        "name": String,
        "contents": String,
        "date": String
    }, ["id"]);
}

Model defineUserinfo()
{
    return new Model("userinfo", {
        "id": int,
        "email": String
    }, ["id"]);
}

Model defineCounter()
{
    return new Model("counter", {
        "page": String,
        "count": int
    }, ["page"]);
}

Template getDefaultTemplate(HttpRequest req)
{
    Template tpl = new Template();
    tpl.readFile("top.hdf");
    tpl["ID"] = req.session["id"];
    //tpl["Username"] = req.session["username"];
    //tpl["Password"] = req.session["password"];
    //tpl["Remember"] = req.session["remember"];
    //tpl["Practice"] = "on";
    return tpl;
}

@Public InputStream FileStorage.openReadme(String user, String id)
{
    return FileStorage.open(user + "/" + id + "/readme.txt");
}

@Public InputStream FileStorage.openJS(String user, String id)
{
    return FileStorage.open(user + "/" + id + "/k2js.k");
}

@Public InputStream FileStorage.openKS(String user, String id)
{
    return FileStorage.open(user + "/" + id + "/ks.k");
}

@Public InputStream FileStorage.openHTML(String user, String id)
{
    return FileStorage.open(user + "/" + id + "/index.html");
}

@Public OutputStream FileStorage.newReadme(String user, String id)
{
    return FileStorage.newFile(user + "/" + id + "/readme.txt");
}

@Public OutputStream FileStorage.newJS(String user, String id)
{
    return FileStorage.newFile(user + "/" + id + "/k2js.k");
}

@Public OutputStream FileStorage.newKS(String user, String id)
{
    return FileStorage.newFile(user + "/" + id + "/ks.k");
}

@Public OutputStream FileStorage.newHTML(String user, String id)
{
    return FileStorage.newFile(user + "/" + id + "/index.html");
}

@Public OutputStream FileStorage.newHistory(String user, String id)
{
    return FileStorage.newFile(user + "/" + id + "/history.txt");
}

@Public String Array.join(String separator)
{
    if (separator == null) {
        separator = ",";
    }
    String ret = "";
    for (int i = 0; i < this.size - 1; i++) {
        ret += (to String)this[i] + separator;
    }
    if (this.size > 0) {
        ret += this[this.size - 1];
    }
    return ret;
}

boolean isReservedWord(String word)
{
    return word in? ["action", "about", "check", "contact", "BUGS", "help"];
}

/* ------------------------------------------------------------------------ */

HttpResponse login(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return null;
    }
    String username = req.params_post["username"];
    String password = req.params_post["password"];
    String remember = req.params_post["remember"];
    if (remember == "on") {
        req.session["username"] = username;
        req.session["password"] = password;
        req.session["remember"] = remember;
    }
    else {
        req.session.remove("username");
        req.session.remove("password");
        req.session.remove("remember");
    }
    User user = User.authenticate(username, password);
    if (user != null) {
        req.session["id"] = user.name;
        if (TRACE_USER) {
            Map m = {};
            m["id"] = user.name;
            System.ntraceNotice("Aspen:SignIn", m);
        }
    }
    return redirect("/aspen/");
}

HttpResponse logout(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return null;
    }
    if (TRACE_USER) {
        Map m = {};
        m["id"] = req.session["id"];
        System.ntraceNotice("Aspen:SignOut", m);
    }
    req.session.remove("id");
    return redirect("/aspen/");
}

HttpResponse viewer(HttpRequest req, String[] args)
{
    Template tpl = getDefaultTemplate(req);
    tpl["User.Name"] = args[0];
    tpl["User.Id"] = args[1];
    Model scripts = defineScripts();
    Map[] m = scripts.get("name", {
        "user": args[0],
        "id": args[1]
    });
    if (|m| == 0) {
        return null;
    }
    String name = m[0]["name"];
    String readme = FileStorage.openReadme(args[0], args[1]).read().decode();
    String js = FileStorage.openJS(args[0], args[1]).read().decode();
    String ks = FileStorage.openKS(args[0], args[1]).read().decode();
    String html = FileStorage.openHTML(args[0], args[1]).read().decode();
    if (name != null && name != "") {
        tpl["Code.Name"] = name.convert(to:durl);
    }
    tpl["Code.Body.Readme"] = readme;
    tpl["Code.Body.Js"] = js;
    tpl["Code.Body.Ks"] = ks;
    tpl["Code.Body.Html"] = html;
    Model counter = defineCounter();
    String page = args[0] + "/" + args[1];
    m = counter.get("count", {
        "page": page
    });
    int count = 0;
    if (|m| == 0) {
        counter.set({
            "page": page,
            "count": 0
        });
    }
    else {
        count = m[0]["count"];
        counter.update({
            "count": count + 1
        }, {"page": page});
    }
    tpl["Code.Viewcount"] = count;
    TemplateContext ctx = new TemplateContext();
    if (req.session["id"] == args[0]) {
        tpl["Myself"] = 1;
    }
    else {
        if (|args| == 3) {
            args.pop()
            return redirect("/aspen/" + args.join("/"));
        }
    }
    ctx.parseFile("viewer.cs");
    if (TRACE_USER) {
        Map m = {};
        m["id"] = req.session["id"];
        m["target"] = args[0];
        m["watching"] = args[1];
        System.ntraceNotice("Aspen:Viewer", m);
    }
    return new HttpResponse(tpl.render(ctx));
}

void reportBug(String user, String id) {
    FileStorage.mkdir("BUGS", 0755);
    Date d = new Date();
    String fname = (to String)d.year + (to String)d.month + (to String)d.day;
    fname += (to String)d.hour + (to String)d.min + (to String)d.sec;
    fname += "_" + user + "_" + id + ".k";
    OutputStream ous = FileStorage.newFile("BUGS/" + fname);
    InputStream ins = FileStorage.openJS(user, id);
    ous.write(ins.read());
    ous.close();
    ins.close();
}

HttpResponse konoha2js(HttpRequest req, String[] args)
{
    if (req.method == "POST") {
        return null;
    }
    String user = args[0];
    String id = args[1];
    String requestedType = args[2];
    if (requestedType == null) {
        requestedType = "js";
    }
    Model scripts = defineScripts();
    Map[] m = scripts.get("name", {
        "user": user,
        "id": id
    });
    if (|m| != 1) {
        return null;
    }
    InputStream body = FileStorage.openJS(user, id);
    String scriptpath = body.path;
    HttpResponse res = new HttpResponse();
    String k2jspath = "/usr/local/bin/konoha2js";
    if (requestedType == "js") {
        body.close();
        //res["Access-Control-Allow-Origin"] = "http://konohascript.org";
        res["Content-Type"] = "application/javascript";
        int max_loop_count = 1000000000;
        res.content = exec(k2jspath + " -j -r -l " + max_loop_count + " -i " + scriptpath);
        if (res.content == "") {
            // a SEGV may occurred on konoha2js
            reportBug(user, id);
            res.content = """
function konoha() {
    this.ERR = "";
    this.printOUT = function() {};
    this.printERR = function() {
        if (this.ERR == "") return;
        var strings = this.ERR.split("\\n");
        var body = document.getElementsByTagName('body').item(0);
        for (var i = 0; i < strings.length; i++) {
            body.appendChild(document.createTextNode(strings[i]));
            body.appendChild(document.createElement('br'));
        }
    };
}
konoha = new konoha();
function konoha_main() {
    throw("Compile Error!!: Your script is reported as a reproducible code. Sorry.");
}""";
        }
    }
    else if (requestedType == "html") {
        body.close();
        //String ret = exec(k2jspath + " -j -r -i " + path);
        //ret = "<script type=\"text/javascript\">\n" + ret + "\n</script>\n</head>";
        //String replacetxt = "</head>";
        InputStream html = FileStorage.openHTML(user, id);
        //res.content += html.read().decode().replace(replacetxt, ret);
        res.content += html.read().decode();
        html.close();
        if (TRACE_USER) {
            Map m = {};
            m["id"] = req.session["id"];
            m["target"] = user;
            m["running"] = id;
            System.ntraceNotice("Aspen:Konoha2JS", m);
        }
    }
    else if (requestedType == "compile") {
        body.close();
        //res["Access-Control-Allow-Origin"] = "http://konohascript.org";
        res["Content-Type"] = "application/json; charset=UTF-8";
        String[] result = exec(k2jspath + " -c -i " + scriptpath + " 2>&1").split("\n");
        result.pop()
        Json j = new Json();
        Json[] errs = [];
        Json[] infos = [];
        Json[] warns = [];
        Regex r = new Regex(" - \\((\\w+\\.k)\\:(\\d+)\\) \\((\\w+)\\) (.+)");
        foreach (String line in result) {
            String[] reg = line.match(r);
            if (|reg| > 0) {
                Json j2 = new Json();
                j2["line"] = reg[2];
                j2["message"] = reg[4];
                if (not reg[1] == "compiler.k") {
                    switch (reg[3]) {
                    case "error":
                        errs.add(j2);
                        break;
                    case "warning":
                        warns.add(j2);
                        break;
                    case "info":
                        infos.add(j2);
                        break;
                    }
                }
            }
        }
        if (|errs| > 0) {
            j["error"] = true;
            j["errormsg"] = errs;
        }
        if (|infos| > 0) {
            j["info"] = true;
            j["infomsg"] = infos;
        }
        if (|warns| > 0) {
            j["warning"] = true;
            j["warningmsg"] = warns;
        }
        res.content = j.stringify();
        if (TRACE_USER) {
            Map m = {};
            m["id"] = req.session["id"];
            m["target"] = user;
            m["compiling"] = id;
            System.ntraceNotice("Aspen:Konoha2JS", m);
        }
    }
    else if (requestedType == "javac") {
        body.close();
        Model scripts = defineScripts();
        String scriptname;
        Map[] m = scripts.get("name", {
            "user": user,
            "id": id
        });
        if (|m| == 1) {
            scriptname = m[0]["name"];
        }
        else {
            return null;
        }
        String javacpath = "/usr/bin/javac -encoding UTF8";
        res["Content-Type"] = "application/json; charset=UTF-8";
        if (System.stat(FileStorage.root + user + "/javac") == null) {
            FileStorage.mkdir(user + "/javac", 0755);
        }
        if (System.stat(FileStorage.root + user + "/javac" + id) == null) {
            FileStorage.mkdir(user + "/javac/" + id, 0755);
        }
        String javapath = FileStorage.root + user + "/javac/" + id + "/" + scriptname;
        System.symlink(scriptpath, javapath);
        String result = exec(javacpath + " -d " + $TMP_DIR + " " + javapath + " 2>&1");
        Json j = new Json();
        if (result != "") {
            j["error"] = true;
            j["errormsg"] = result.replace(javapath, scriptname);
        }
        res.content = j.stringify();
        if (TRACE_USER) {
            Map m = {};
            m["id"] = req.session["id"];
            m["target"] = user;
            m["javacompiling"] = id;
            System.ntraceNotice("Aspen:Konoha2JS", m);
        }
    }
    else if (requestedType == "ks") {
        res["Content-Type"] = "text/plain; charset=UTF-8";
        res.content = body.read().decode();
        body.close();
    }
    else if (requestedType == "memview") {
        body.close();
        Template tpl = getDefaultTemplate(req);
        tpl["User"] = user;
        tpl["Script"] = id;
        TemplateContext ctx = new TemplateContext();
        ctx.parseFile("canvas.cs");
        return new HttpResponse(tpl.render(ctx));
    }
    else {
        args.pop();
        return redirect("/aspen/" + args.join("/"));
    }
    return res;
}

HttpResponse user(HttpRequest req, String[] args)
{
    String user = args[0];
    if (not User.hasUser(user)) {
        if (req.session["id"] == user) {
            req.session.remove("id");
        }
        return redirect("/aspen/");
    }
    if (|args| == 2) {
        return viewer(req, args);
    }
    else if (|args| == 3) {
        return konoha2js(req, args);
    }
    Template tpl = getDefaultTemplate(req);
    tpl["Info.0.key"] = "ID";
    tpl["Info.0.value"] = user;
    if (req.session["id"] == user) {
        tpl["Myself"] = 1;
    }
    Array codelist = [];
    Model scripts = defineScripts();
    foreach (Map m in scripts.get("id, name, date", {"user": user})) {
        String id = m["id"];
        String name = m["name"];
        codelist.add({
            "Id": id,
            "Name": name.convert(to:durl),
            "Date": m["date"]
        });
    }
    tpl["User"] = user;
    tpl["Code"] = codelist;
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("user.cs");
    if (TRACE_USER) {
        Map m = {};
        m["id"] = req.session["id"];
        m["watching"] = user;
        System.ntraceNotice("Aspen:User", m);
    }
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse top(HttpRequest req, String[] args)
{
    if (req.session["id"] != null) {
        return redirect("/aspen/" + req.session["id"]);
    }
    Template tpl = getDefaultTemplate(req);
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("top.cs");
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse about(HttpRequest req, String[] args)
{
    Template tpl = getDefaultTemplate(req);
    tpl.readFile("about.hdf");
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("about.cs");
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse signup(HttpRequest req, String[] args)
{
    Template tpl = getDefaultTemplate(req);
    tpl.readFile("signup.hdf");
    TemplateContext ctx = new TemplateContext();
    if (req.method != "POST") {
        ctx.parseFile("form.cs");
        return new HttpResponse(tpl.render(ctx));
    }
    String username = req.params_post["username"];
    String password = req.params_post["password"];
    String email = req.params_post["email"];
    Regex r = new Regex("^([\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4})?$");
    Regex r2 = new Regex("^[a-zA-Z0-9_]{1,48}$");
    if (isReservedWord(username)) {
        Map error = {
            "Title": "Username is invalid.",
            "Contents": "You cannot use '" + username + "' as a username."
        }
        tpl["Form.Inputs.0.Input.Value"] = username;
        tpl["Form.Inputs.1.Input.Value"] = email;
        tpl["Error"] = error;
        ctx.parseFile("form.cs");
        if (TRACE_USER) {
            Map m = {}
            m["username"] = username;
            m["email"] = email;
            System.ntraceFailed("Aspen:SignUp", m);
        }
        return new HttpResponse(tpl.render(ctx));
    }
    if (username.search(r2) < 0) {
        Map error = {
            "Title": "Username is invalid.",
            "Contents": "Username can only contain letters, numbers and '_'."
        }
        tpl["Form.Inputs.0.Input.Value"] = username;
        tpl["Form.Inputs.1.Input.Value"] = email;
        tpl["Error"] = error;
        ctx.parseFile("form.cs");
        if (TRACE_USER) {
            Map m = {}
            m["username"] = username;
            m["email"] = email;
            System.ntraceFailed("Aspen:SignUp", m);
        }
        return new HttpResponse(tpl.render(ctx));
    }
    if (email.search(r) < 0) {
        Map error = {
            "Title": "email is invalid.",
            "Contents": "Cannot create user '" + username + "'. Please retry."
        }
        tpl["Form.Inputs.0.Input.Value"] = username;
        tpl["Form.Inputs.1.Input.Value"] = email;
        tpl["Error"] = error;
        ctx.parseFile("form.cs");
        if (TRACE_USER) {
            Map m = {}
            m["username"] = username;
            m["email"] = email;
            System.ntraceFailed("Aspen:SignUp", m);
        }
        return new HttpResponse(tpl.render(ctx));
    }
    User user = User.addUser(username, password);
    if (user == null) {
        Map error = {
            "Title": "Username is invalid.",
            "Contents": "Cannot create user '" + username + "'. Please retry."
        }
        tpl["Form.Inputs.0.Input.Value"] = username;
        tpl["Form.Inputs.1.Input.Value"] = email;
        tpl["Error"] = error;
        ctx.parseFile("form.cs");
        if (TRACE_USER) {
            Map m = {}
            m["username"] = username;
            m["email"] = email;
            System.ntraceFailed("Aspen:SignUp", m);
        }
        return new HttpResponse(tpl.render(ctx));
    }
    Model userinfo = defineUserinfo();
    userinfo.add({
        "id": user.id,
        "email": email
    });
    FileStorage.mkdir(username, 0755);
    req.session["id"] = user.name;
    if (TRACE_USER) {
        Map m = {}
        m["newid"] = user.name;
        m["email"] = email;
        System.ntraceNotice("Aspen:SignUp", m);
    }
    return redirect("/aspen/");
}

HttpResponse check(HttpRequest req, String[] args)
{
    if (req.method == "POST") {
        return null;
    }
    HttpResponse res = new HttpResponse();
    res["Content-Type"] = "application/json; charset=utf-8";
    Json j = new Json();
    switch (args[1]) {
    case "username":
        Regex r = new Regex("^[a-zA-Z0-9_]{1,48}$");
        String username = req.params_get["username"];
        if (User.hasUser(username) ||
                isReservedWord(username)) {
            j["exists"] = true;
        }
        else {
            j["exists"] = false;
        }
        if (username.search(r) < 0) {
            j["error"] = true;
        }
        else {
            j["error"] = false;
        }
        break;
    case "email":
        Regex r = new Regex("^([\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4})?$");
        String email = req.params_get["email"];
        if (email.search(r) < 0) {
            j["error"] = true;
        }
        else {
            j["error"] = false;
        }
        break;
    default:
        return null;
        break;
    }
    res.content = j.stringify();
    return res;
}

HttpResponse save(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return null;
    }
    HttpResponse res = new HttpResponse();
    res["Content-Type"] = "application/json; charset=utf-8";
    Json j = new Json();
    String user = req.params_post["user"];
    String id = req.params_post["id"];
    String readme = req.params_post["readme"];
    String js = req.params_post["js"];
    String ks = req.params_post["ks"];
    String html = req.params_post["html"];
    String history = req.params_post["history"];
    if (user != req.session["id"]) {
        j["error"] = true;
        j["message"] = "Parameter 'user' is invalid.";
        res.content = j.stringify();
        if (TRACE_USER) {
            Map m = {}
            m["id"] = req.session["id"];
            m["target"] = user;
            m["saving"] = id;
            System.ntraceFailed("Aspen:Save", m);
        }
        return res;
    }
    Map m = {};
    OutputStream ous_readme = FileStorage.newReadme(user, id);
    OutputStream ous_js = FileStorage.newJS(user, id);
    OutputStream ous_ks = FileStorage.newKS(user, id);
    OutputStream ous_html = FileStorage.newHTML(user, id);
    OutputStream ous_history = FileStorage.newHistory(user, id);
    String git_path = (to String)ous_readme.path;
    git_path = git_path.substring(0, git_path.lastIndexOf("/"));
    Git g = new Git(git_path);
    ous_readme.print(readme);
    ous_js.print(js);
    ous_ks.print(ks);
    ous_html.print(html);
    ous_history.print(history);
    ous_readme.close();
    ous_js.close();
    ous_ks.close();
    ous_html.close();
    ous_history.close();
    g.add("*");
    g.commit("save commit");
    if (readme != "" && readme != null) {
        m["readme"] = readme.convert(to:url);
    }
    if (js != "" && js != null) {
        m["js"] = js.convert(to:url);
    }
    if (ks != "" && ks != null) {
        m["ks"] = ks.convert(to:url);
    }
    if (html != "" && html != null) {
        m["html"] = html.convert(to:url);
    }
    m["date"] = (to String)new Date();
    j["message"] = "Script saved successfully.";
    res.content = j.stringify();
    if (TRACE_USER) {
        Map m = {}
        m["id"] = req.session["id"];
        m["saving"] = id;
        System.ntraceNotice("Aspen:Save", m);
    }
    return res;
}

HttpResponse create(HttpRequest req, String[] args)
{
    String js_tpl = "// your code goes here.";
    String html_tpl = """
<!DOCTYPE html>
<html>
<head>
<title>sample</title>
<!-- konoha2js code goes here -->
<script src="%src%"></script>
<!-- include this if you use js.jquery package -->
<script src="%static%/js/libs/jquery-1.7.1.min.js"></script>
<script>
function runmain() {
  try {
    konoha_main();
  } catch (e) {
    if (typeof(e) == "string") {
      konoha.ERR = e;
    }
    else {
      throw e;
    }
  }
  konoha.printERR();
  konoha.printOUT();
}
</script>
</head>
<body onload="runmain();">
</body>
</html>
""";
    if (req.session["id"] == null) {
        return null;
    }
    if (req.method == "GET") {
        Template tpl = getDefaultTemplate(req);
        tpl.readFile("create.hdf");
        TemplateContext ctx = new TemplateContext();
        ctx.parseFile("form.cs");
        return new HttpResponse(tpl.render(ctx));
    }
    String codename = req.params_post["codename"];
    if (|codename.trim()| == 0 || |codename| >= 128) {
        Map error = {};
        if (|codename.trim()| == 0) {
            error["Title"] = "Name is empty.";
        }
        else {
            error["Title"] = "Name is too long (should be no longer than 128).";
        }
        Template tpl = getDefaultTemplate(req);
        tpl.readFile("create.hdf");
        tpl["Form.Inputs.0.Input.Value"] = codename;
        tpl["Error"] = error;
        TemplateContext ctx = new TemplateContext();
        ctx.parseFile("form.cs");
        if (TRACE_USER) {
            Map m = {};
            m["id"] = req.session["id"];
            m["creating"] = codename;
            System.ntraceFailed("Aspen:Create", m);
        }
        return new HttpResponse(tpl.render(ctx));
    }
    HttpResponse res = new HttpResponse();
    Date d = new Date();
    String id = (to String)d.year;
    id += (to String)d.month;
    id += (to String)d.day;
    id += (to String)d.hour;
    id += (to String)d.sec;
    String sessionid = req.session["id"];
    if (!FileStorage.mkdir(sessionid + "/" + id, 0755)) {
        if (TRACE_USER) {
            Map m = {};
            m["id"] = req.session["id"];
            m["creating"] = codename;
            System.ntraceFailed("Aspen:Create", m);
        }
        return redirect("/aspen/");
    }
    Model scripts = defineScripts();
    OutputStream ous_readme = FileStorage.newReadme(sessionid, id);
    OutputStream ous_js = FileStorage.newJS(sessionid, id);
    OutputStream ous_ks = FileStorage.newKS(sessionid, id);
    OutputStream ous_html = FileStorage.newHTML(sessionid, id);
    String git_path = (to String)ous_readme.path;
    git_path = git_path.substring(0, git_path.lastIndexOf("/"));
    Git g = new Git(git_path);
    html_tpl = html_tpl.replace("%src%", "/aspen/" + sessionid + "/" + id + "/js");
    html_tpl = html_tpl.replace("%static%", $STATIC_URL);
    ous_js.print(js_tpl);
    ous_html.print(html_tpl);
    ous_readme.close();
    ous_js.close();
    ous_ks.close();
    ous_html.close();
    g.init();
    g.add("*");
    g.commit("initial commit");
    scripts.set({
        "user": sessionid,
        "id": id,
        "name": codename.convert(to:url),
        "js": js_tpl.convert(to:url),
        "html": html_tpl.convert(to:url),
        "date": (to String)d
    });
    Model counter = defineCounter();
    counter.set({
        "page": sessionid + "/" + id,
        "count": 0
    });
    if (TRACE_USER) {
        Map m = {};
        m["id"] = req.session["id"];
        m["creating"] = codename;
        System.ntraceNotice("Aspen:Create", m);
    }
    return redirect("/aspen/" + sessionid + "/" + id);
}

HttpResponse delete(HttpRequest req, String[] args)
{
    if (req.session["id"] == null || req.method == "GET") {
        return null;
    }
    HttpResponse res = new HttpResponse();
    res["Content-Type"] = "application/json; charset=utf-8";
    Json j = new Json();
    String id = req.params_post["id"];
    if (id == "" || id == null) {
        j["error"] = true;
        j["message"] = "Invalid id or user.";
        res.content = j.stringify();
        return res;
    }
    Model scripts = defineScripts();
    scripts.remove({
        "user": req.session["id"],
        "id": id
    });
    j["message"] = "Script deleted successfully.";
    res.content = j.stringify();
    if (TRACE_USER) {
        Map m = {};
        m["id"] = req.session["id"];
        m["deleting"] = id;
        System.ntraceFailed("Aspen:Delete", m);
    }
    return res;
}

HttpResponse search(HttpRequest req, String[] args)
{
    if (req.method == "POST") {
        return null;
    }
    Template tpl = getDefaultTemplate(req);
    String searchtext = req.params_get["text"];
    tpl["Search.Text"] = searchtext;
    Array matched_names = [];
    Array matched_scripts = [];
    //Array matched_contents = [];
    if (searchtext != null && searchtext != "") {
        String[] names = User.getList();
        Model scripts = defineScripts();
        foreach (String name in names) {
            name = name.convert(to:durl);
            if (name.indexOf(searchtext) >= 0) {
                matched_names.add(name);
            }
        }
        Map[] records = scripts.get("user, id, name");
        foreach (Map record in records) {
            record["name"] = ((to String)record["name"]).convert(to:durl);
            String content = "";
            if (record["name"].indexOf(searchtext) >= 0) {
                record.remove("js");
                matched_scripts.add(record);
            }
        }
        //Map[] records = scripts.get("user, id, name, js");
        //foreach (Map record in records) {
        //    record["name"] = ((to String)record["name"]).convert(to:durl);
        //    String content = "";
        //    if (record["js"] != null) {
        //        content = ((to String)record["js"]).convert(to:durl);
        //        int index = content.indexOf(searchtext);
        //        if (index >= 0) {
        //            if (index <= 30) {
        //                record["js"] = content.substring(0, 120) + " ...";
        //            }
        //            else {
        //                record["js"] = "... " + content.substring(index - 30, 120) + " ...";
        //            }
        //            matched_contents.add(record);
        //        }
        //    }
        //    if (record["name"].indexOf(searchtext) >= 0) {
        //        record.remove("js");
        //        matched_scripts.add(record);
        //    }
        //}
    }
    tpl["Result.Users"] = matched_names;
    tpl["Result.Codes"] = matched_scripts;
    //tpl["Result.Contents"] = matched_contents;
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("search.cs");
    if (TRACE_USER) {
        Map m = {};
        m["id"] = req.session["id"];
        m["searching"] = searchtext;
        m["UserNum"] = |matched_names|;
        m["CodeNum"] = |matched_scripts|;
        System.ntraceFailed("Aspen:Search", m);
    }
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse inquire(HttpRequest req, String[] args)
{
    if (req.session["id"] == null) {
        return redirect("/aspen/");
    }
    Template tpl = getDefaultTemplate(req);
    if (req.method != "POST") {
        TemplateContext ctx = new TemplateContext();
        ctx.parseFile("inquire.cs");
        return new HttpResponse(tpl.render(ctx));
    }
    Model inquiries = defineInquiries();
    inquiries.set({
        "title": req.params_post["title"].convert(to:url),
        "name": req.session["id"],
        "contents": req.params_post["contents"].convert(to:url),
        "date": (to String)new Date()
    });
    return redirect("/aspen/contact/" + inquiries.id);
}

HttpResponse contact(HttpRequest req, String[] args)
{
    if (args[1] == "new") {
        return inquire(req, args);
    }
    Template tpl = getDefaultTemplate(req);
    Model inquiries = defineInquiries();
    if ((to int)args[1] != 0) {
        Map[] m = inquiries.get("*", {
            "id": (to int)args[1]
        });
        if (|m| == 1) {
            Map topic = {};
            topic["Title"] = ((to String)m[0]["title"]).convert(to:durl);
            topic["Name"] = m[0]["name"];
            topic["Contents"] = ((to String)m[0]["contents"]).convert(to:durl);
            topic["Date"] = m[0]["date"];
            tpl["Topic"] = topic;
            TemplateContext ctx = new TemplateContext();
            ctx.parseFile("topic.cs");
            return new HttpResponse(tpl.render(ctx));
        }
        else {
            return null;
        }
    }
    Array threadlist = [];
    foreach (Map m in inquiries.get("id, title, name, date")) {
        int id = m["id"];
        String title = ((to String)m["title"]).convert(to:durl);
        String name = m["name"];
        String date = m["date"];
        threadlist.add({
            "Id": (to String)id,
            "Title": title,
            "Name": name,
            "Date": date
        });
    }
    tpl["Threads"] = threadlist;
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("contact.cs");
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse update(HttpRequest req, String[] args)
{
    if (req.method != "POST" || req.session["id"] == null) {
        return null;
    }
    String update_value = req.params_post["update_value"];
    String script_id = req.params_post["script_id"];
    String original_value = req.params_post["original_value"];
    Json j = new Json();
    if (|update_value.trim()| == 0) {
        j["error"] = true;
        j["errormsg"] = "Name is empty.";
        j["value"] = original_value;
        return new HttpResponse(j.stringify());
    }
    else if (|update_value| >= 128) {
        j["error"] = true;
        j["errormsg"] = "Name is too long (should be no longer than 128).";
        j["value"] = original_value;
        return new HttpResponse(j.stringify());
    }
    Model scripts = defineScripts();
    scripts.update({"name": update_value.convert(to:url)}, {"user": req.session["id"], "id": script_id});
    if (TRACE_USER) {
        Map m = {};
        m["id"] = req.session["id"];
        m["script"] = script_id;
        m["oldname"] = original_value;
        m["newname"] = update_value;
        System.ntraceNotice("Aspen:Update", m);
    }
    j["value"] = update_value;
    return new HttpResponse(j.stringify());
}

//HttpResponse preference(HttpRequest req, String[] args)
//{
//    Template tpl = getDefaultTemplate(req);
//    Model userinfo = defineUserinfo();
//    String userid = req.session["id"];
//    int id = User.getUserId(userid);
//    Map[] m = userinfo.get("email", {"id": id});
//    String email = m[0]["email"];
//    tpl.readFile("setting.hdf");
//    tpl["Form.Inputs.0.Input.Value"] = email;
//    TemplateContext ctx = new TemplateContext();
//    ctx.parseFile("form.cs");
//    return new HttpResponse(tpl.render(ctx));
//}

HttpResponse help(HttpRequest req, String[] args)
{
    Template tpl = getDefaultTemplate(req);
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("help.cs");
    return new HttpResponse(tpl.render(ctx));
}

Url.patterns = [
    (new Regex("^aspen/$"), top),
    (new Regex("^aspen/about/$"), about),
    (new Regex("^aspen/contact/.*$"), contact),
    (new Regex("^aspen/check/.+$"), check),
    (new Regex("^aspen/help/$"), help),
    (new Regex("^aspen/action/create$"), create),
    (new Regex("^aspen/action/delete$"), delete),
    (new Regex("^aspen/action/login$"), login),
    (new Regex("^aspen/action/logout$"), logout),
    (new Regex("^aspen/action/save$"), save),
    (new Regex("^aspen/action/search$"), search),
    (new Regex("^aspen/action/signup$"), signup),
    (new Regex("^aspen/action/update$"), update),
    //(new Regex("^aspen/action/setting$"), preference),
    (new Regex("^aspen/.+$"), user)
];
