/**
 * wsgi header file
 * (c) chenji <wakamori111 at gmail.com>
 */

#ifndef KONOHA_WSGI_H
#define KONOHA_WSGI_H

typedef struct _wsgi_config {
    char *status;
    char *content_type;
    char *content_encoding;
} wsgi_config_t;

#endif /* KONOHA_WSGI_H */
