using konoha.clearsilver.*;
using konoha.io.*;

int dump_cb(String s) {
    print s;
    return Cs.STATUS_OK;
}

Hdf hdf = new Hdf();
InputStream ins = new InputStream("./in.hdf");
String str = ins.read().decode();
print str;
hdf.readString(str);
hdf.dump("dump");
