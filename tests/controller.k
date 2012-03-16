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
    tpl.readFile("/Users/chen_ji/Devel/git/Veins/tests/model/menu.hdf");
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("/Users/chen_ji/Devel/git/Veins/tests/view/menu.cs");
    HttpResponse res = new HttpResponse(tpl.render(ctx));
    res["Content-Type"] = "text/html";
    return res;
}

Url.patterns = [
    (new Regex("^doc/\\w+/\\w+/$"), document),
    (new Regex("^menu/\\w+/$"), menu)
];
