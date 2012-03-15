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
    Hdf hdf = new Hdf();
    hdf.readFile("/Users/chen_ji/Devel/git/Veins/tests/model/menu.hdf");
    Cs cs = new Cs(hdf);
    cs.parseFile("/Users/chen_ji/Devel/git/Veins/tests/view/menu.cs");
    CsRenderer renderer = new CsRenderer(cs);
    HttpResponse res = new HttpResponse(renderer.render());
    res["Content-Type"] = "text/html";
    return res;
}

Url.patterns = [
    (new Regex("/doc/*"), document),
    (new Regex("/menu/*"), menu),
    //(new Regex("/test/session/*"), test_session),
];
