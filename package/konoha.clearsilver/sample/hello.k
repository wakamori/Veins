using konoha.clearsilver.*;

int render_cb(String s)
{
    OUT << s << EOL;
    return Cs.STATUS_OK;
}

Hdf hdf = new Hdf();
hdf.value("message", "hello, world");
Cs cs = new Cs(hdf);
cs.parseFile("./hello.cs");
cs.render(render_cb);
