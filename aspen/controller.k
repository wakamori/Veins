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
    res.status = 301;
    return res;
}

Model getScripts()
{
    return new Model("scripts", {
        "user": String,
        "id": int,
        "name": String,
        "body": String,
        "date": String
    }, ["user", "id"]);
}

HttpResponse login(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return redirect("./");
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
    else {
        return redirect("./");
    }
    return redirect("./");
}

HttpResponse logout(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return redirect("./");
    }
    req.session.remove("id");
    return redirect("./");
}

HttpResponse editor(HttpRequest req, String[] args)
{
    Template tpl = new Template();
    tpl.readFile("top.hdf");
    tpl["ID"] = req.session["id"];
    tpl["User.Name"] = args[0];
    Model scripts = getScripts();
    Map[] m = scripts.get("*", {
        "user": args[0],
        "id": (to int)args[1]
    });
    if (|m| == 0) {
        return null;
    }
    tpl["Code.Name"] = m[0]["name"];
    tpl["Code.Body"] = m[0]["body"].convert(to:durl);
    TemplateContext ctx = new TemplateContext();
    if (req.session["id"] == args[0]) {
        ctx.parseFile("editor.cs");
    }
    else {
        ctx.parseFile("viewer.cs");
    }
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse user(HttpRequest req, String[] args)
{
    String user = args[0];
    if (not User.hasUser(user)) {
        if (req.session["id"] == user) {
            req.session.remove("id");
        }
        return null;
    }
    if (|args| > 1 && |args[1]| > 0) {
        return editor(req, args);
    }
    Template tpl = new Template();
    tpl.load(user + ".hdf");
    tpl.readFile("top.hdf");
    tpl["Username"] = req.session["username"];
    tpl["Password"] = req.session["password"];
    tpl["Remember"] = req.session["remember"];
    tpl["ID"] = req.session["id"];
    if (req.session["id"] == user) {
        tpl["Myself"] = 1;
    }
    Array codelist = [];
    Model scripts = getScripts();
    foreach (Map m in scripts.get("*", {"user": user})) {
        int id = m["id"];
        ERR << "id: " << id << EOL;
        codelist.add({
            "Id": (to String)id,
            "Name": m["name"],
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
    Template tpl = new Template();
    tpl.readFile("top.hdf");
    tpl["Username"] = req.session["username"];
    tpl["Password"] = req.session["password"];
    tpl["Remember"] = req.session["remember"];
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("top.cs");
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse about(HttpRequest req, String[] args)
{
    Template tpl = new Template();
    tpl.readFile("top.hdf");
    tpl["Username"] = req.session["username"];
    tpl["Password"] = req.session["password"];
    tpl["Remember"] = req.session["remember"];
    tpl.readFile("about.hdf");
    tpl["ID"] = req.session["id"];
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("about.cs");
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse signup(HttpRequest req, String[] args)
{
    Template tpl = new Template();
    tpl.readFile("top.hdf");
    tpl["Username"] = req.session["username"];
    tpl["Password"] = req.session["password"];
    tpl["Remember"] = req.session["remember"];
    TemplateContext ctx = new TemplateContext();
    if (req.method != "POST") {
        ctx.parseFile("signup.cs");
        return new HttpResponse(tpl.render(ctx));
    }
    String username = req.params_post["username"];
    String password = req.params_post["password"];
    String email = req.params_post["email"];
    Regex r = new Regex("^([\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4})?$");
    if (email.search(r) < 0) {
        ERR << "email is invalid" << EOL;
        Map error = {
            "Title": "email is invalid.",
            "Contents": "Cannot create user '" + username + "'. Please retry."
        }
        tpl["Input.username"] = username;
        tpl["Input.email"] = email;
        tpl["Error"] = error;
        ctx.parseFile("signup.cs");
        return new HttpResponse(tpl.render(ctx));
    }
    User user = User.addUser(username, password);
    if (user == null) {
        ERR << "user is null" << EOL;
        Map error = {
            "Title": "Username is invalid.",
            "Contents": "Cannot create user '" + username + "'. Please retry."
        }
        tpl["Input.username"] = username;
        tpl["Input.email"] = email;
        tpl["Error"] = error;
        ctx.parseFile("signup.cs");
        return new HttpResponse(tpl.render(ctx));
    }
    ERR << "OK" << EOL;
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
        return redirect("../");
    }
    HttpResponse res = new HttpResponse();
    res["Content-Type"] = "application/json; charset=utf-8";
    if (User.hasUser(req.params_post["username"])) {
        res.content = "{ \"exists\": true }";
    }
    else {
        res.content = "{ \"exists\": false }";
    }
    return res;
}

HttpResponse save(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return redirect("../");
    }
    HttpResponse res = new HttpResponse();
    res["Content-Type"] = "application/json; charset=utf-8";
    String user = req.params_post["user"];
    String id = req.params_post["id"];
    String name = req.params_post["name"];
    String body = req.params_post["body"];
    if (user != req.session["id"]) {
        res.content = "{ \"error\": true, \"message\": \"Parameter 'user' is invalid.\" }";
        return res;
    }
    Model scripts = getScripts();
    scripts.set({
        "user": user,
        "id": (to int)id,
        "name": name,
        "body": body.convert(to:url),
        "date": (to String)new Date()
    });
    res.content = "{ \"message\": \"Script saved successfully.\" }";
    return res;
}

HttpResponse create(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return redirect("../");
    }
    String username = req.session["id"];
    if (username != req.params_post["username"]) {
        return redirect("../");
    }
    HttpResponse res = new HttpResponse();
    Date d = new Date();
    String id = (to String)d.year;
    id += (to String)d.month;
    id += (to String)d.day;
    id += (to String)d.hour;
    id += (to String)d.sec;
    Model scripts = getScripts();
    scripts.set({
        "user": username,
        "id": (to int)id,
        "name": "noname",
        "body": "",
        "date": (to String)d
    });
    return redirect("../" + username + "/" + id);
}

Url.patterns = [
    (new Regex("^aspen/$"), top),
    (new Regex("^aspen/about/$"), about),
    (new Regex("^aspen/check/username$"), check),
    (new Regex("^aspen/login$"), login),
    (new Regex("^aspen/logout$"), logout),
    (new Regex("^aspen/signup$"), signup),
    (new Regex("^aspen/action/create$"), create),
    (new Regex("^aspen/action/save$"), save),
    (new Regex("^aspen/.+$"), user)
];
