/**
 * Veins setting file.
 */

/* Show debug messages when DEBUG is true. */
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

/* Absolute path to userdata. */
$STORAGE_ROOT = "";

/* Middleware classes. */
$MIDDLEWARES = [
    "SessionMiddleware"
];
