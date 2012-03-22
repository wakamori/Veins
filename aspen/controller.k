/**
 * Controller script.
 */

/* It must be called before veins package is loaded. */
include "/Users/chen_ji/Devel/git/Veins/aspen/settings.k";

using konoha.veins.*;

HttpResponse login(HttpRequest req, String[] args)
{
    HttpResponse res = new HttpResponse();
    if (req.method != "POST") {
        res["Location"] = "./";
        res.status = 301;
        return res;
    }
    Map<String> params = req.params_post;
    String username = params["username"];
    String password = params["password"];
    String remember = params["remember"];
    User user = User.authenticate(username, password);
    if (user != null) {
        req.session["id"] = user.name;
    }
    else {
        res["Location"] = "./";
        res.status = 301;
        return res;
    }
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
    res["Location"] = "./" + username;
    res.status = 301;
    return res;
}

HttpResponse logout(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        HttpResponse res = new HttpResponse();
        res["Location"] = "./";
        res.status = 301;
    }
    req.session.remove("id");
    HttpResponse res = new HttpResponse();
    res["Location"] = "./";
    res.status = 301;
    return res;
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
        HttpResponse res = new HttpResponse();
        res.status = 404;
        return res;
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
        args.add(req.session["id"]);
        return user(req, args);
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
        HttpResponse res = new HttpResponse();
        res["Location"] = "../";
        res.status = 301;
        return res;
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
    if (req.method == "POST") {
        String username = req.params_post["username"];
        String password = req.params_post["password"];
        User user = User.addUser(username, password);
        Regex r = new Regex("^/^([\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4})?$/");
        if (user == null) {
            ERR << "user is null" << EOL;
            Map error = {
                "Title": "Username is invalid.",
                "Contents": "Cannot create user '" + username + "'. Please retry."
            }
            tpl["Error"] = error;
        }
        else if (req.params_post["email"].search(r) < 0) {
            ERR << "email is invalid" << EOL;
            Map error = {
                "Title": "email is invalid.",
                "Contents": "Cannot create user '" + username + "'. Please retry."
            }
            tpl["Error"] = error;
        }
        else {
            ERR << "OK" << EOL;
            tpl["Contents"] = "<p>User '" + user.name + "' is created.</p>";
            ctx.parseFile("empty.cs");
            Template usertpl = new Template();
            Array info = [
                {"key": "ID", "value": user.name},
                {"key": "email", "value": req.params_post["email"]},
            ];
            usertpl["Info"] = info;
            usertpl.save(user.name + ".hdf");
            req.session["id"] = user.name;
            tpl["ID"] = user.name;
            return new HttpResponse(tpl.render(ctx));
        }
    }
    ctx.parseFile("signup.cs");
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse check(HttpRequest req, String[] args)
{
    HttpResponse res = new HttpResponse();
    if (req.method != "POST" || args[1] != "username") {
        res["Location"] = "../";
        res.status = 301;
        return res;
    }
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
    HttpResponse res = new HttpResponse();
    if (req.method != "POST") {
        res["Location"] = "../";
        res.status = 301;
        return res;
    }
    if (req.session["id"] != req.params_post["username"]) {
        res["Location"] = "../";
        res.status = 301;
        return res;
    }
    Date d = new Date();
    String defaultname = (to String)d.year;
    defaultname += (to String)d.month;
    defaultname += (to String)d.day;
    defaultname += (to String)d.hour;
    defaultname += (to String)d.sec + ".k";
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
