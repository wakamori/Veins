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
        "description": String,
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
            "Description": m["description"],
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
    tpl.readFile("signup.hdf");
    tpl["Username"] = req.session["username"];
    tpl["Password"] = req.session["password"];
    tpl["Remember"] = req.session["remember"];
    TemplateContext ctx = new TemplateContext();
    if (req.method != "POST") {
        ctx.parseFile("form.cs");
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
        tpl["Inputs.0.Value"] = username;
        tpl["Inputs.1.Value"] = email;
        tpl["Error"] = error;
        ctx.parseFile("form.cs");
        return new HttpResponse(tpl.render(ctx));
    }
    User user = User.addUser(username, password);
    if (user == null) {
        ERR << "user is null" << EOL;
        Map error = {
            "Title": "Username is invalid.",
            "Contents": "Cannot create user '" + username + "'. Please retry."
        }
        tpl["Inputs.0.Value"] = username;
        tpl["Inputs.1.Value"] = email;
        tpl["Error"] = error;
        ctx.parseFile("form.cs");
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
    Json j = new Json();
    if (User.hasUser(req.params_post["username"])) {
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
        return redirect("../");
    }
    HttpResponse res = new HttpResponse();
    res["Content-Type"] = "application/json; charset=utf-8";
    Json j = new Json();
    String user = req.params_post["user"];
    String id = req.params_post["id"];
    String name = req.params_post["name"];
    String body = req.params_post["body"];
    if (user != req.session["id"]) {
        j["error"] = true;
        j["message"] = "Parameter 'user' is invalid.";
        res.content = j.stringify();
        return res;
    }
    Model scripts = getScripts();
    Map m = {};
    if (name != null) {
        m["name"] = name;
    }
    if (body != null) {
        m["body"] = body.convert(to:url);
    }
    m["date"] = (to String)new Date();
    scripts.update(m, {
        "user": user,
        "id": (to int)id
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
        HttpResponse res = new HttpResponse();
        Date d = new Date();
        String id = (to String)d.year;
        id += (to String)d.month;
        id += (to String)d.day;
        id += (to String)d.hour;
        id += (to String)d.sec;
        Model scripts = getScripts();
        scripts.set({
            "user": req.session["id"],
            "id": (to int)id,
            "name": codename,
            "description": description,
            "body": "",
            "date": (to String)d
        });
        return redirect("../" + req.session["id"] + "/" + id);
    }
    Template tpl = new Template();
    tpl.readFile("top.hdf");
    tpl["Username"] = req.session["username"];
    tpl["Password"] = req.session["password"];
    tpl["Remember"] = req.session["remember"];
    tpl["ID"] = req.session["id"];
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
        int id = (to int)req.params_post["id"];
        if (id == 0 || req.session["id"] == null) {
            j["error"] = true;
            j["message"] = "Invalid id or user.";
            res.content = j.stringify();
            return res;
        }
        Model scripts = getScripts();
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

Url.patterns = [
    (new Regex("^aspen/$"), top),
    (new Regex("^aspen/about/$"), about),
    (new Regex("^aspen/check/.+$"), check),
    (new Regex("^aspen/login$"), login),
    (new Regex("^aspen/logout$"), logout),
    (new Regex("^aspen/signup$"), signup),
    (new Regex("^aspen/action/create$"), create),
    (new Regex("^aspen/action/delete$"), delete),
    (new Regex("^aspen/action/save$"), save),
    (new Regex("^aspen/.+$"), user)
];
