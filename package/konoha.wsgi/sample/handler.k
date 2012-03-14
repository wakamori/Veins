using konoha.wsgi.*;

@Public String Wsgi.application(Map<String> environ,
        Func<String,Tuple<String,String>[]> start_response)
{
    foreach (String s in environ.keys()) {
        ERR << "env[" + s + "]=" + environ[s] << EOL;
    }
    start_response("200 OK", [("Content-Type", "text/plain")]);
    return "Hello, world";
}
