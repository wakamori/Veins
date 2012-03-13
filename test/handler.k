using konoha.wsgi.*;

@Public String Wsgi.application(Map<String> environ,
        Func<String,Tuple<String,String>[]> start_response) {
    ERR << environ << EOL;
    start_response("200 OK", [("Content-Type", "text/plain")]);
    return "Hello, world";
}
