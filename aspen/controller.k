/**
 * Controller script.
 */

/* It must be called before veins package is loaded. */
include "/Users/chen_ji/Devel/git/Veins/aspen/settings.k";

using konoha.veins.*;

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
        "description": String,
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

@Public InputStream FileStorage.openJS(String user, String id)
{
    return FileStorage.open(user + "_" + id + "_js.k");
}

@Public InputStream FileStorage.openKS(String user, String id)
{
    return FileStorage.open(user + "_" + id + ".k");
}

@Public InputStream FileStorage.openHTML(String user, String id)
{
    return FileStorage.open(user + "_" + id + ".html");
}

@Public OutputStream FileStorage.newJS(String user, String id)
{
    return FileStorage.newFile(user + "_" + id + "_js.k");
}

@Public OutputStream FileStorage.newKS(String user, String id)
{
    return FileStorage.newFile(user + "_" + id + ".k");
}

@Public OutputStream FileStorage.newHTML(String user, String id)
{
    return FileStorage.newFile(user + "_" + id + ".html");
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
    return new HttpResponse("OK");
}

HttpResponse logout(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return null;
    }
    req.session.remove("id");
    return redirect("../../");
}

HttpResponse editor(HttpRequest req, String[] args)
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
    String js = FileStorage.openJS(args[0], args[1]).read().decode();
    String ks = FileStorage.openKS(args[0], args[1]).read().decode();
    String html = FileStorage.openHTML(args[0], args[1]).read().decode();
    if (name != null && name != "") {
        tpl["Code.Name"] = name.convert(to:durl);
    }
    tpl["Code.Body.Js"] = js;
    tpl["Code.Body.Ks"] = ks;
    tpl["Code.Body.Html"] = html;
    TemplateContext ctx = new TemplateContext();
    if (req.session["id"] == args[0]) {
        ctx.parseFile("editor.cs");
    }
    else {
        ctx.parseFile("viewer.cs");
    }
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
        res["Access-Control-Allow-Origin"] = "http://konohascript.org";
        res["Content-Type"] = "application/javascript";
        res.content = exec(k2jspath + " -j -r -i " + path);
    }
    else if (requestedType == "html") {
        String ret = exec(k2jspath + " -j -r -i " + path);
        ret = "<script type=\"text/javascript\">\n" + ret + "\n</script>\n</head>";
        String replacetxt = "</head>";
        InputStream html = FileStorage.openHTML(user, id);
        res.content = "<!DOCTYPE html>\n";
        res.content += html.read().decode().replace(replacetxt, ret);
        html.close();
    }
    else if (requestedType == "compile") {
        res["Access-Control-Allow-Origin"] = "http://konohascript.org";
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
        return null;
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
        return redirect("../");
    }
    if (|args| == 2) {
        return editor(req, args);
    }
    else if (|args| == 3) {
        return konoha2js(req, args);
    }
    Template tpl = getDefaultTemplate(req);
    tpl.load(user + ".hdf");
    if (req.session["id"] == user) {
        tpl["Myself"] = 1;
    }
    Array codelist = [];
    Model scripts = defineScripts();
    foreach (Map m in scripts.get("*", {"user": user})) {
        String id = m["id"];
        String name = m["name"];
        String description = m["description"];
        codelist.add({
            "Id": id,
            "Name": name.convert(to:durl),
            "Description": description.convert(to:durl),
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
        return redirect("./" + req.session["id"]);
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
    Template usertpl = new Template();
    Array info = [
        {"key": "ID", "value": user.name},
        {"key": "email", "value": email},
    ];
    usertpl["Info"] = info;
    usertpl.save(user.name + ".hdf");
    req.session["id"] = user.name;
    return redirect("./");
}

HttpResponse check(HttpRequest req, String[] args)
{
    if (req.method != "POST" || args[1] != "username") {
        return null;
    }
    HttpResponse res = new HttpResponse();
    res["Content-Type"] = "application/json; charset=utf-8";
    Json j = new Json();
    if (User.hasUser(req.params_post["username"]) ||
            isReservedWord(req.params_post["username"])) {
        j["exists"] = true;
    }
    else {
        j["exists"] = false;
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
    String name = req.params_post["name"];
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
    if (name != null) {
        m["name"] = name.convert(to:url);
    }
    OutputStream ous_js = FileStorage.newJS(user, id);
    OutputStream ous_ks = FileStorage.newKS(user, id);
    OutputStream ous_html = FileStorage.newHTML(user, id);
    ous_js.print(js);
    ous_ks.print(ks);
    ous_html.print(html);
    ous_js.close();
    ous_ks.close();
    ous_html.close();
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
    if (req.session["id"] == null) {
        return redirect("../");
    }
    if (req.method == "POST") {
        String codename = req.params_post["codename"];
        String description = req.params_post["description"];
        if (|codename| == 0 || |description| == 0) {
            Map error = {};
            if (|codename| == 0) {
                error["Title"] = "Name is empty.";
            }
            else {
                error["Title"] = "Description is empty.";
            }
            Template tpl = getDefaultTemplate(req);
            tpl.readFile("create.hdf");
            tpl["Form.Inputs.0.Input.Value"] = codename;
            tpl["Form.Inputs.1.Input.Value"] = description;
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
        OutputStream ous_js = FileStorage.newJS(req.session["id"], id);
        OutputStream ous_ks = FileStorage.newKS(req.session["id"], id);
        OutputStream ous_html = FileStorage.newHTML(req.session["id"], id);
        ous_js.print("""
// your code goes here.
print \"hello, world\";
""");
        ous_html.print("""
<html>
<head>
<title>sample</title>
<script type="text/javascript">
function runmain() {
  konoha_main();
  konoha.printERR();
  konoha.printOUT();
}
</script>
</head>
<body onload="runmain()">
</body>
</html>
""");
        ous_js.close();
        ous_ks.close();
        ous_html.close();
        scripts.set({
            "user": req.session["id"],
            "id": id,
            "name": codename.convert(to:url),
            "description": description.convert(to:url),
            "date": (to String)d
        });
        return redirect("../" + req.session["id"] + "/" + id);
    }
    Template tpl = getDefaultTemplate(req);
    tpl.readFile("create.hdf");
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("form.cs");
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse delete(HttpRequest req, String[] args)
{
    if (req.session["id"] == null) {
        return redirect("../");
    }
    HttpResponse res = new HttpResponse();
    res["Content-Type"] = "application/json; charset=utf-8";
    Json j = new Json();
    if (req.method == "POST") {
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
    return redirect("../");
}

HttpResponse search(HttpRequest req, String[] args)
{
    if (req.method == "POST") {
        return redirect("../");
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
        return redirect("./");
    }
    Template tpl = getDefaultTemplate(req);
    if (req.method != "POST") {
        TemplateContext ctx = new TemplateContext();
        ctx.parseFile("inquire.cs");
        return new HttpResponse(tpl.render(ctx));
    }
    Model inquiries = defineInquiries();
    inquiries.set({
        "title": req.params_post["title"],
        "name": req.session["id"],
        "contents": req.params_post["contents"],
        "date": (to String)new Date()
    });
    return redirect("./" + inquiries.id);
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
