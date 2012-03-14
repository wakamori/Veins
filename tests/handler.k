using konoha.veins.*;

HttpResponse document(HttpRequest req)
{
    return new HttpResponse("this is document");
}

Url.patterns.add((new Regex("/konoha/doc*"), document));
