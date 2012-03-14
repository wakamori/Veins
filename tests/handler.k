using konoha.veins.*;

HttpResponse document(HttpRequest req)
{
    return new HttpResponse("<h1>doc</h1>");
}

Url.addPattern(new Regex("
