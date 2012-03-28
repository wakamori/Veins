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

Model defineScripts()
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

HttpResponse login(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return redirect("../");
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
        return redirect("../");
    }
    return redirect("../");
}

HttpResponse logout(HttpRequest req, String[] args)
{
    if (req.method != "POST") {
        return redirect("../");
    }
    req.session.remove("id");
    return redirect("../");
}

HttpResponse editor(HttpRequest req, String[] args)
{
    Template tpl = getDefaultTemplate(req);
    tpl["User.Name"] = args[0];
    Model scripts = defineScripts();
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
    Template tpl = getDefaultTemplate(req);
    tpl.load(user + ".hdf");
    if (req.session["id"] == user) {
        tpl["Myself"] = 1;
    }
    Array codelist = [];
    Model scripts = defineScripts();
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
    if (email.search(r) < 0) {
        ERR << "email is invalid" << EOL;
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
        ERR << "user is null" << EOL;
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
    ERR << "OK" << EOL;
    Template usertpl = new Template();
    Array info = [
        {"key": "ID", "value": user.name},
        {"key": "email", "value": email},
    ];
    usertpl["Info"] = info;
    usertpl.save(user.name + ".hdf");
    req.session["id"] = user.name;
    return redirect("../");
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
    Model scripts = defineScripts();
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
        Model scripts = defineScripts();
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
        int id = (to int)req.params_post["id"];
        if (id == 0 || req.session["id"] == null) {
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
    if (req.method != "POST") {
        return redirect("../");
    }
    Template tpl = getDefaultTemplate(req);
    String searchtext = req.params_post["text"];
    tpl["Search.Text"] = searchtext;
    Array matched_names = [];
    Array matched_scripts = [];
    if (searchtext != null && searchtext != "") {
        String[] names = User.getList();
        Model scripts = defineScripts();
        foreach (String name in names) {
            if (name.indexOf(searchtext) >= 0) {
                matched_names.add(name);
            }
        }
        Map[] records = scripts.get("user, id, name");
        foreach (Map record in records) {
            String name = record["name"];
            if (name.indexOf(searchtext) >= 0) {
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

Url.patterns = [
    (new Regex("^aspen/$"), top),
    (new Regex("^aspen/about/$"), about),
    (new Regex("^aspen/action/create$"), create),
    (new Regex("^aspen/action/delete$"), delete),
    (new Regex("^aspen/action/login$"), login),
    (new Regex("^aspen/action/logout$"), logout),
    (new Regex("^aspen/action/save$"), save),
    (new Regex("^aspen/action/search$"), search),
    (new Regex("^aspen/action/signup$"), signup),
    (new Regex("^aspen/check/.+$"), check),
    (new Regex("^aspen/.+$"), user)
];
