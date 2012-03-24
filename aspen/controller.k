/**
 * Controller script.
 */

/* It must be called before veins package is loaded. */
include "/Users/chen_ji/Devel/git/Veins/aspen/settings.k";

using konoha.veins.*;

HttpResponse redirect(String location) {
    HttpResponse res = new HttpResponse();
    res["Location"] = location;
    res.status = 301;
    return res;
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
    tpl["Code.Name"] = req.session["id"];
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("editor.cs");
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
    Template tpl = new Template();
    tpl.load(user + ".hdf");
    tpl.readFile("top.hdf");
    tpl["ID"] = req.session["id"];
    if (req.session["id"] == user) {
        tpl["Myself"] = 1;
    }
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
    tpl.readFile("about.hdf");
    tpl["ID"] = req.session["id"];
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("about.cs");
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse list(HttpRequest req, String[] args)
{
    if (req.session["id"] == null) {
        return redirect("../");
    }
    String id = req.session["id"];
    Template tpl = new Template();
    tpl.load(id + ".hdf");
    tpl.readFile("top.hdf");
    tpl["ID"] = req.session["id"];
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("user.cs");
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse signup(HttpRequest req, String[] args)
{
    Template tpl = new Template();
    tpl.readFile("top.hdf");
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

HttpResponse create(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return redirect("../");
    }
    if (req.session["id"] != req.params_post["username"]) {
        return redirect("../");
    }
    HttpResponse res = new HttpResponse();
    Date d = new Date();
    String defaultname = (to String)d.year;
    defaultname += (to String)d.month;
    defaultname += (to String)d.day;
    defaultname += (to String)d.hour;
    defaultname += (to String)d.sec + ".k";
    Model scripts = new Model("scripts", {
        "user": String,
        "name": String,
        "date": String
    });
}

Url.patterns = [
    (new Regex("^aspen/$"), top),
    (new Regex("^aspen/about/$"), about),
    (new Regex("^aspen/check/username$"), check),
    (new Regex("^aspen/list/$"), list),
    (new Regex("^aspen/login$"), login),
    (new Regex("^aspen/logout$"), logout),
    (new Regex("^aspen/signup$"), signup),
    (new Regex("^aspen/action/create$"), create),
    (new Regex("^aspen/.+$"), user)
];
