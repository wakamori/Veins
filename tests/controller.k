/**
 * Controller script.
 */

/* It must be called before veins package is loaded. */
include "/Users/chen_ji/Devel/git/Veins/tests/settings.k";

using konoha.veins.*;

HttpResponse document(HttpRequest req)
{
    HttpResponse res = new HttpResponse("this is document");
    res["Content-Type"] = "text/plain";
    return res;
}

HttpResponse menu(HttpRequest req)
{
    Template tpl = new Template();
    tpl.readFile("/Users/chen_ji/Devel/git/Veins/tests/model/menu.hdf");
    ERR << tpl << EOL;
    TemplateContext ctx = new TemplateContext();
    ctx.parseFile("/Users/chen_ji/Devel/git/Veins/tests/view/menu.cs");
    ERR << ctx << EOL;
    HttpResponse res = new HttpResponse(tpl.render(ctx));
    res["Content-Type"] = "text/html";
    return res;
}

Url.patterns = [
    (new Regex("/doc/*"), document),
    (new Regex("/menu/*"), menu),
    //(new Regex("/test/session/*"), test_session),
];
