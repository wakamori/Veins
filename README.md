Veins
=====

Veins is a KonohaScript Web framework.

Installation
------------

First, you need to install following packages.

For complie konohascript and dependent packages:

* gcc-c++
* cmake (> = 2.8)
* sqlite-devel
* pcre-devel
* json-c
* libuuid-devel
* clearsilver
* llvm (> = 3.0)

For compile mod\_konoha:

* httpd
* httpd-devel
* gcc
* konohascript

Then, compile mod\_konoha by typing following commands.

    cd mod_konoha
    ln -s [macosx.mk|centos.mk] Makefile
    make
    sudo make install

When install is succeeded, add following line into your Apache configuration file (httpd.conf). Do not forget to modify `path/to/` as your environment.

    LoadModule konoha_module path/to/mod_konoha.so

Subsequently, set mod\_konoha location by adding Location and SetHandler directive. For example, if you want to enable mod\_konoha when URL includes `/konoha`, write:

    <Location /konoha>
        SetHandler konoha
        KonohaHandler /path/to/controller.k
        PackageDir /path/to/package/dir
    </Location>

Additionally, you must set `KonohaHandler` directive that specify absolute path to your handler script. Optionally, if you use Konoha package, you need to add `PackageDir` directive that specify absolute path to your package-installed directory (it is normally `/usr/local/konoha/packate/1.0`).

Finally, restart apache to enable configuration.

Usage
-----

coming soon.
