/**
 * access control
 */
STORAGE_ROOT = "./storage/";

class FileStorage {
	String checkName(String name) {
		if(name.indexOf("/") != -1) return null;
		if(name.indexOf("..") != -1) return null;
		return STORAGE_ROOT + name;
	}

  InputStream open(String name) {
		name = checkName(name);
		if(name != null) {
			return new InputStream(name);
		}
		return null;
	}

  OutputStream newFile(String name) {
		name = checkName(name);
		print name;
		if(name != null) {
			return new OutputStream(name);
		}
		return null;
	}

  //boolean save(OutputStream ous);
}

//// コード例
//ous = FileStorage.newFile("test");
//ous << "hi" << EOL;
//
//// flush()時には一時的に保存されるのみ。
//ous.flush();
//
//// サーバ側に保存する場合は明示的にsaveを呼ぶ仕様となっている。
//if (FileStorage.save(ous)) {
//  ins = FileStorage.open("test");
//  // => ins.read() == "test"
//}

print "newFile test";
ous = FileStorage.newFile("file1");
ous.println("hello"); ous.flush(); ous.close();

ous = FileStorage.newFile("..");
ous.println("hello"); ous.close();

