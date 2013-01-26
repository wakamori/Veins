/**
 * Veins setting file.
 */

/* Show debug messages when DEBUG is "true". */
$DEBUG = "true";

/* Set a random seed number for encryption. */
$SEED = 945934988;

/* Database. */
$DATABASES = {
    "default": {
        "engine": "mysql",
        "name": "name",
        "user": "user",
        "password": "password",
        "host": "localhost",
        "port": "3306"
    }
};

/* Absolute path to media data directory. */
$MEDIA_DIR = "/Users/chen_ji/Devel/git/Veins/aspen/user/";

/* Absolute path to model data directory. */
$MODEL_DIR = "/Users/chen_ji/Devel/git/Veins/aspen/model/";

/* Absolute path to view data directory. */
$VIEW_DIR = "/Users/chen_ji/Devel/git/Veins/aspen/view/";

/* Absolute path to tmp directory. */
$TMP_DIR = "/tmp/";

/* Absolute URL to base URL. */
$BASE_URL = "http://localhost/aspen";

/* Absolute URL to static files. */
$STATIC_URL = "http://localhost/~chen_ji/aspen";

/* Middleware classes. */
$MIDDLEWARES = [
    "SessionMiddleware",
    "LoggingMiddleware"
];

/* ------------------------------------------------------------------------ */
/* Middlware settings. */

/* Session engine ("file" or "cache"). Default is "file" */
//$SESSION_ENGINE = "file";
