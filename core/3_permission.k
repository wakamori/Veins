using konoha.sql.*;

/**
 * permission
 */

user_db = "users.db";

class Permission {
	String name;
	Permission(String name) { _name = name; }
}

class Group {
	String name;
	Group(String name) { _name = name; }

  boolean hasPermission(Permission perm) {
		Connection c = new(user_db);
		try {
			r = c.query("select * from group_perms");
			while(r.next()) {
				if(r.getString("name") == name) {
					foreach(String p in r.getString("permissions").split(",")) {
						if(p == perm.name) return true;
					}
				}
			}
		} finally {
			c.close();
		}
		return false;
	}
}

class User {
	String name;
	String[] perms;
	String[] groups;
	User(String name, String[] perms, String[] groups) {
		_name = name;
		_perms = perms;
		_groups = groups;
	}

  boolean hasPermission(Permission perm) {
		foreach(String p in perms) {
			if(p == perm.name) return true;
		}
		foreach(String g in groups) {
			if(new Group(g).hasPermission(perm)) return true;
		}
		return false;
	}

  @Static User authenticate(String name, String password) {
		Connection c = new(user_db);
		try {
			r = c.query("select * from users");
			while(r.next()) {
				if(r.getString("name") == name && r.getString("password") == password) {
					String[] p = r.getString("permissions").split(",");
					String[] g = r.getString("groups").split(",");
					return new User(name, p, g);
				}
			}
			return null;
		} finally {
			c.close();
		}
	}
}

print User.authenticate("matz", "hoge") != null ? "OK" : "NG";
print User.authenticate("matz", "abcd") != null ? "OK" : "NG";
print User.authenticate("matz2", "hello") != null ? "OK" : "NG";

u = User.authenticate("matz", "hoge");
print u.hasPermission(new Permission("perm1"));
print u.hasPermission(new Permission("perm2"));

u = User.authenticate("wakka", "aaa");
print u.hasPermission(new Permission("perm1"));
print u.hasPermission(new Permission("perm2"));

u = User.authenticate("test", "kkk");
print u.hasPermission(new Permission("perm1"));
print u.hasPermission(new Permission("perm2"));

//// コード例
//// リクエストのパラメータからUsername, Passwordを取得
//username = "...";
//password = "...";
//User user = User.authenticate(username, password);
//if (user != null) {
//  /* ユーザが存在する */
//  /* セッションを保存する */
//} else {
//  /* ユーザが存在しない */
//  /* ログイン画面に戻る */
//}
//
//// 特定のパーミッションを持っているか調べる
//if (user.hasPermission(new Permission("create_dir"))) {
//  /* ディレクトリを作成できる */
//}
//else {
//  /* ディレクトリを作成できない */
//}

