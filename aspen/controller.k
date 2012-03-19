/**
 * Controller script.
 */

/* It must be called before veins package is loaded. */
include "/Users/chen_ji/Devel/git/Veins/aspen/settings.k";

using konoha.veins.*;

HttpResponse login(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        /* error handling */
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
        /* User does not exist. */
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
    HttpResponse res = new HttpResponse();
    res["Location"] = "./";
    res.status = 301;
    return res;
}

HttpResponse logout(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        /* error handling */
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
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("editor.cs");
    return new HttpResponse(tpl.render(ctx));
}

HttpResponse top(HttpRequest req, String[] args)
{
    if (req.session["id"] != null) {
        return editor(req, args);
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

Url.patterns = [
    (new Regex("^aspen/$"), top),
    (new Regex("^aspen/login$"), login),
    (new Regex("^aspen/logout$"), logout),
];