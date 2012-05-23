/**
 * Veins setting file.
 */

/* Show debug messages when DEBUG is "true". */
$DEBUG = "false";

/* Set a random seed number for encryption. */
$SEED = 945934988;

/* Database. */
$DATABASES = {
    "default": {
        "engine": "mysql",
        "name": "backup",
        "user": "backup",
        "password": "konoha",
        "host": "192.168.0.70",
        "port": "3306"
    }
};

/* Absolute path to media data directory. */
$MEDIA_DIR = "/backup/user/";

/* Absolute path to model data directory. */
$MODEL_DIR = "/var/www/html/backup/model/";

/* Absolute path to view data directory. */
$VIEW_DIR = "/var/www/html/backup/view/";

/* Absolute path to tmp directory. */
$TMP_DIR = "/backup/tmp/";

/* Absolute URL to base URL. */
$BASE_URL = "http://konoha.ubicg.ynu.ac.jp/backup";

/* Absolute URL to static files. */
$STATIC_URL = "http://konoha.ubicg.ynu.ac.jp/backup/static";

/* Middleware classes. */
$MIDDLEWARES = [
    "SessionMiddleware",
    "LoggingMiddleware"
];

/* ------------------------------------------------------------------------ */
/* Middlware settings. */

/* Session engine ("file" or "cache"). Default is "file" */
//$SESSION_ENGINE = "file";
