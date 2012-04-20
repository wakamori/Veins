/**
 * Controller script.
 */

/* It must be called before veins package is loaded. */
include "/Users/chen_ji/Devel/git/Veins/aspen/settings.k";

using konoha.veins.*;

class Git
{
    String bin;
    String path;
    String cmd;

    Git(String path) {
        _bin = exec("which git").trim();
        _path = path;
        _cmd = "cd " + path + " && " + bin;
    }

    void init() {
        exec(cmd + " init");
    }

    void add(String file) {
        exec(cmd + " add " + file);
    }

    void commit(String msg) {
        exec(cmd + " commit -m '" + msg + "'");
    }

    void commitAll(String msg) {
        exec(cmd + " commit -a -m '" + msg + "'");
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

Template getDefaultTemplate(HttpRequest req)
{
    Template tpl = new Template();
    tpl.readFile("top.hdf");
    tpl["ID"] = req.session["id"];
    tpl["Username"] = req.session["username"];
    tpl["Password"] = req.session["password"];
    tpl["Remember"] = req.session["remember"];
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
    return word in? ["action", "about", "check", "contact"];
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
    }
    return redirect("/aspen/");
}

HttpResponse logout(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return null;
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
    TemplateContext ctx = new TemplateContext();
    if (req.session["id"] == args[0]) {
        if (|args| == 3) {
            ctx.parseFile("editor.cs");
            return new HttpResponse(tpl.render(ctx));
        }
        tpl["Myself"] = 1;
    }
    else {
        if (|args| == 3) {
            args.pop()
            return redirect("/aspen/" + args.join("/"));
        }
    }
    ctx.parseFile("viewer.cs");
    return new HttpResponse(tpl.render(ctx));
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
    String path = body.path;
    body.close();
    HttpResponse res = new HttpResponse();
    String k2jspath = "/usr/local/bin/konoha2js";
    if (requestedType == "js") {
        //res["Access-Control-Allow-Origin"] = "http://konohascript.org";
        res["Content-Type"] = "application/javascript";
        res.content = exec(k2jspath + " -j -r -i " + path);
    }
    else if (requestedType == "html") {
        //String ret = exec(k2jspath + " -j -r -i " + path);
        //ret = "<script type=\"text/javascript\">\n" + ret + "\n</script>\n</head>";
        //String replacetxt = "</head>";
        InputStream html = FileStorage.openHTML(user, id);
        //res.content += html.read().decode().replace(replacetxt, ret);
        res.content += html.read().decode();
        html.close();
    }
    else if (requestedType == "compile") {
        //res["Access-Control-Allow-Origin"] = "http://konohascript.org";
        res["Content-Type"] = "application/json; charset=UTF-8";
        String[] result = exec(k2jspath + " -c -i " + path + " 2>&1").split("\n");
        result.pop()
        Json j = new Json();
        String[] stderrs = [];
        Regex r = new Regex(" - \\(\\w+\\.k\\:\\d+\\) \\(\\w+\\) .+");
        foreach (String line in result) {
            if (line.search(r) >= 0) {
                if (not line.startsWith(" - (compiler.k")) {
                    stderrs.add(line.substring(3));
                }
            }
        }
        if (|stderrs| > 0) {
            j["error"] = true;
        }
        j["stderr"] = stderrs;
        res.content = j.stringify();
    }
    else {
        args.pop()
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
        if (args[2] == "edit") {
            return viewer(req, args);
        }
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
    foreach (Map m in scripts.get("*", {"user": user})) {
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
    Regex r2 = new Regex("^[a-zA-Z0-9_]{1,20}$");
    if (isReservedWord(username)) {
        Map error = {
            "Title": "Username is invalid.",
            "Contents": "You cannot use '" + username + "' as a username."
        }
        tpl["Form.Inputs.0.Input.Value"] = username;
        tpl["Form.Inputs.1.Input.Value"] = email;
        tpl["Error"] = error;
        ctx.parseFile("form.cs");
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
        return new HttpResponse(tpl.render(ctx));
    }
    Model userinfo = defineUserinfo();
    userinfo.add({
        "id": user.id,
        "email": email
    });
    FileStorage.mkdir(username, 0755);
    req.session["id"] = user.name;
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
        Regex r = new Regex("^[a-zA-Z0-9_]{1,20}$");
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
    if (user != req.session["id"]) {
        j["error"] = true;
        j["message"] = "Parameter 'user' is invalid.";
        res.content = j.stringify();
        return res;
    }
    Model scripts = defineScripts();
    Map m = {};
    OutputStream ous_readme = FileStorage.newReadme(user, id);
    OutputStream ous_js = FileStorage.newJS(user, id);
    OutputStream ous_ks = FileStorage.newKS(user, id);
    OutputStream ous_html = FileStorage.newHTML(user, id);
    String git_path = (to String)ous_readme.path;
    git_path = git_path.substring(0, git_path.lastIndexOf("/"));
    Git g = new Git(git_path);
    ous_readme.print(readme);
    ous_js.print(js);
    ous_ks.print(ks);
    ous_html.print(html);
    ous_readme.close();
    ous_js.close();
    ous_ks.close();
    ous_html.close();
    g.commitAll("save commit");
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
    scripts.update(m, {
        "user": user,
        "id": id
    });
    j["message"] = "Script saved successfully.";
    res.content = j.stringify();
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
<script src="/aspen/static/js/libs/jquery-1.7.1.min.js"></script>
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
    if (req.method == "POST") {
        String codename = req.params_post["codename"];
        if (|codename| == 0) {
            Map error = {};
            error["Title"] = "Name is empty.";
            Template tpl = getDefaultTemplate(req);
            tpl.readFile("create.hdf");
            tpl["Form.Inputs.0.Input.Value"] = codename;
            tpl["Error"] = error;
            TemplateContext ctx = new TemplateContext();
            ctx.parseFile("form.cs");
            return new HttpResponse(tpl.render(ctx));
        }
        HttpResponse res = new HttpResponse();
        Date d = new Date();
        String id = (to String)d.year;
        id += (to String)d.month;
        id += (to String)d.day;
        id += (to String)d.hour;
        id += (to String)d.sec;
        Model scripts = defineScripts();
        String sessionid = req.session["id"];
        FileStorage.mkdir(sessionid + "/" + id, 0755);
        OutputStream ous_readme = FileStorage.newReadme(sessionid, id);
        OutputStream ous_js = FileStorage.newJS(sessionid, id);
        OutputStream ous_ks = FileStorage.newKS(sessionid, id);
        OutputStream ous_html = FileStorage.newHTML(sessionid, id);
        String git_path = (to String)ous_readme.path;
        git_path = git_path.substring(0, git_path.lastIndexOf("/"));
        Git g = new Git(git_path);
        html_tpl = html_tpl.replace("%src%", "/aspen/" + sessionid + "/" + id + "/js");
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
        return redirect("/aspen/" + sessionid + "/" + id + "/edit");
    }
    Template tpl = getDefaultTemplate(req);
    tpl.readFile("create.hdf");
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("form.cs");
    return new HttpResponse(tpl.render(ctx));
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
            String name = record["name"].convert(to:durl);
            if (name.indexOf(searchtext) >= 0) {
                record["name"] = name;
                matched_scripts.add(record);
            }
        }
    }
    tpl["Result.Users"] = matched_names;
    tpl["Result.Codes"] = matched_scripts;
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("search.cs");
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
            topic["Title"] = m[0]["title"];
            topic["Name"] = m[0]["name"];
            topic["Contents"] = m[0]["contents"];
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
        String title = m["title"];
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

Url.patterns = [
    (new Regex("^aspen/$"), top),
    (new Regex("^aspen/about/$"), about),
    (new Regex("^aspen/contact/.*$"), contact),
    (new Regex("^aspen/check/.+$"), check),
    (new Regex("^aspen/action/create$"), create),
    (new Regex("^aspen/action/delete$"), delete),
    (new Regex("^aspen/action/login$"), login),
    (new Regex("^aspen/action/logout$"), logout),
    (new Regex("^aspen/action/save$"), save),
    (new Regex("^aspen/action/search$"), search),
    (new Regex("^aspen/action/signup$"), signup),
    (new Regex("^aspen/.+$"), user)
];
