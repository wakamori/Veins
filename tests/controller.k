using konoha.veins.*;

HttpResponse document(HttpRequest req)
{
    return new HttpResponse("this is document");
}

if (!defined(CsRenderer)) {
    class CsRenderer
    {
        Cs cs;
        String buf;

        CsRenderer(Cs cs) {
            _cs = cs;
            buf = "";
        }

        int render_cb(String s) {
            buf += s;
            return Cs.STATUS_OK;
        }

        String render() {
            cs.render(delegate(this, render_cb));
            return buf;
        }
    }
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
    (new Regex("/konoha/doc/*"), document),
    (new Regex("/konoha/menu/*"), menu)
];
