using konoha.clearsilver.*;

Hdf hdf = new Hdf();
hdf.setValue("message", "hello, world");
hdf.writeFile("./out.hdf");
