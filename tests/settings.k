/**
 * Veins setting file.
 */

/* Show debug messages when DEBUG is "true". */
$DEBUG = "true";

/* User database. */
$DATABASES = {
    "default": {
        "engine": "sqlite3",
        "name": "mydb",
        "user": "",
        "password": "",
        "host": "",
        "port": ""
    }
};

/* Absolute path to user data directory. */
$USER_DIR = "/Users/chen_ji/Devel/git/Veins/tests/model/user/";

/* Absolute path to model data directory. */
$MODEL_DIR = "/Users/chen_ji/Devel/git/Veins/tests/model/";

/* Absolute path to view data directory. */
$VIEW_DIR = "/Users/chen_ji/Devel/git/Veins/tests/view/";

/* Absolute path to tmp directory. */
$TMP_DIR = "/tmp/";

/* Absolute URL to base URL. */
$BASE_URL = "http://localhost/konoha";

/* Absolute URL to static files. */
$STATIC_URL = "http://localhost/~chen_ji/static";

/* Middleware classes. */
$MIDDLEWARES = [
    "SessionMiddleware"
];

/* ------------------------------------------------------------------------ */
/* Middlware settings. */

/* Session engine ("file" or "cache"). Default is "file" */
$SESSION_ENGINE = "file";
