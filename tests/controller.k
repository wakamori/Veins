/**
 * Controller script.
 */

/* It must be called before veins package is loaded. */
include "/Users/chen_ji/Devel/git/Veins/tests/settings.k";

using konoha.veins.*;

HttpResponse document(HttpRequest req, String[] args)
{
    HttpResponse res = new HttpResponse(
            "page '" + args[0] + "', column '" + args[1] + "' document");
    res["Content-Type"] = "text/plain";
    return res;
}

HttpResponse menu(HttpRequest req, String[] args)
{
    Template tpl = new Template();
    tpl.readFile("top.hdf");
    tpl.readFile("menu.hdf");
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("menu.cs");
    HttpResponse res = new HttpResponse(tpl.render(ctx));
    res["Content-Type"] = "text/html";
    return res;
}

HttpResponse session(HttpRequest req, String[] args)
{
    Template tpl = new Template();
    if (req.method == "POST") {
        Map<String> params = req.params_post;
        if (params["type"] == "set") {
            String key = params["key"];
            String value = params["value"];
            if (key != null) {
                req.session[key] = value;
            }
        }
        else if (params["type"] == "remove") {
            String key = params["key"];
            if (key != null) {
                req.session.remove(key);
            }
        }
        else if (params["type"] == "renew") {
            req.session = req.session.renew();
        }
    }
    tpl.readFile("top.hdf");
    tpl["Session.ID"] = req.cookies["SESSION"];
    Array items = [];
    foreach (String key in req.session.keys()) {
        items.add({"key": key, "value": req.session[key]});
    }
    tpl["Session.Items"] = items;
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("session.cs");
    HttpResponse res = new HttpResponse(tpl.render(ctx));
    res["Content-Type"] = "text/html";
    return res;
}

HttpResponse top(HttpRequest req, String[] args)
{
    Template tpl = new Template();
    tpl.readFile("top.hdf");
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("top.cs");
    HttpResponse res = new HttpResponse(tpl.render(ctx));
    res["Content-Type"] = "text/html";
    return res;
}

HttpResponse request(HttpRequest req, String[] args)
{
    Template tpl = new Template();
    tpl.readFile("top.hdf");
    Array items = [];
    tpl["method"] = req.method;
    Map<String> params;
    if (req.method == "GET") {
        params = req.params_get;
    }
    else if (req.method == "POST") {
        params = req.params_post;
    }
    foreach (String key in params.keys()) {
        items.add({"key": key, "value": params[key]});
        ERR << "key: " << key << "value: " << params[key] << EOL;
    }
    tpl["Items"] = items;
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("request.cs");
    HttpResponse res = new HttpResponse(tpl.render(ctx));
    res["Content-Type"] = "text/html";
    return res;
}

Url.patterns = [
    (new Regex("^/$"), top),
    (new Regex("^request/$"), request),
    (new Regex("^doc/\\w+/\\w+/$"), document),
    (new Regex("^menu/\\w+/$"), menu),
    (new Regex("^session/$"), session)
];
