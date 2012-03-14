using konoha.clearsilver.*;

int dump_cb(String s) {
    print s;
    return Cs.STATUS_OK;
}

Hdf hdf = new Hdf();
hdf.readFile("./in.hdf");
hdf.dump("dump");
