#!/bin/sh -x

#
# aspen install script
#

sudo yum -y install gcc
sudo yum -y install gcc-c++
sudo yum -y install sqlite-devel
sudo yum -y install pcre-devel
sudo yum -y install libuuid-devel
sudo yum -y install httpd-devel
sudo yum -y install git

mkdir tmp
cd tmp

v=`echo \`cmake --version\` | cut -c 15-17`
if [ "$v" != "2.8" ]; then
    wget http://www.cmake.org/files/v2.8/cmake-2.8.7.tar.gz
    tar zxvf cmake-2.8.7.tar.gz
    cd cmake-2.8.7
    ./configure
    make
    sudo make install
    cd ..
fi

v=`echo \`llvm-config --version\` | cut -c 1`
if [ "$v" != "3" ]; then
    wget http://llvm.org/releases/3.0/llvm-3.0.tar.gz
    tar zxvf llvm-3.0.tar.gz
    cd llvm-3.0.src
    ./configure
    make
    sudo make install
    cd ..
fi

if [ ! -r /usr/local/lib/libneo_cs.a ]; then
    wget http://www.clearsilver.net/downloads/clearsilver-0.10.5.tar.gz
    tar zxvf clearsilver-0.10.5.tar.gz
    cd clearsilver-0.10.5
    if [ "`arch`" = "x86_64" ]; then
        patch -p0 < ../../cs.patch
    fi
    sudo yum -y install zlib-devel
    ./configure
    make
    sudo make install
    cd ..
fi

if [ ! -r /usr/local/lib/libjson.so ]; then
    wget http://oss.metaparadigm.com/json-c/json-c-0.9.tar.gz
    cd json-c-0.9
    ./configure
    make
    sudo make install
    cd ..
fi

git clone git://github.com/wakamori/konohascript.git
cd konohascript/build
cmake ..
make
sudo make install
cd ../..

echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/konoha.conf
sudo ldconfig

cd ..

cd mod_konoha
ln -s centos.mk Makefile
make
sudo make install
