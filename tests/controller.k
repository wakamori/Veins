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
    tpl.readFile("session.hdf");
    tpl["Session.ID"] = req.cookies["SESSION"];
    ERR << "sessionid = " << tpl["Session.ID"] << EOL;
    Array dummy = [
        {"key": "abc", "value": 123},
        {"key": "def", "value": 456},
        {"key": "ghi", "value": "abc"}
    ];
    tpl["Session.Items"] = dummy;
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

Url.patterns = [
    (new Regex("^/$"), top),
    (new Regex("^doc/\\w+/\\w+/$"), document),
    (new Regex("^menu/\\w+/$"), menu),
    (new Regex("^session/$"), session)
];
