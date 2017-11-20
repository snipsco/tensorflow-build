#!/usr/bin/env bash -ex

set -e

# Make sure we're on OS X.
if [[ $(uname) != "Darwin" ]]; then
    echo "ERROR: This makefile build requires macOS, which the current system "\
    "is not."
    exit 1
fi

USAGE="Usage: $0 <tensorflow version> <package version>"
TENSORFLOW_VERSION=${1?$USAGE}
PACKAGE_VERSION=${2?$USAGE}

BUILD_DIR=`pwd`/target
mkdir -p $BUILD_DIR

# We create a dir with a tree containing the .a and a .pc file that can be overlayed over a sysroot
PKG_NAME=tensorflow-ios-$PACKAGE_VERSION
PKG_DIR=$BUILD_DIR/$PKG_NAME
FINAL_PKG=$PKG_DIR.tar.gz

TF_SRCS=$(pwd)/tensorflow
TF_LIB=$BUILD_DIR/libtensorflow.a
TF_HEADER=$TF_SRCS/tensorflow/c/c_api.h

git clone https://github.com/tensorflow/tensorflow
cd tensorflow
git checkout $TENSORFLOW_VERSION
git apply ../tf-ios.patch
cd tensorflow/contrib/makefile/
./build_all_ios.sh
cp ./gen/lib/libtensorflow-core.a $BUILD_DIR/libtensorflow.a
cp ./gen/protobuf_ios/lib/libprotobuf.a $BUILD_DIR/libprotobuf.a

echo "Creating $FINAL_PKG"

mkdir $PKG_DIR
cd $PKG_DIR

LIB_NAME=tensorflow
PREFIX=usr
LIB_INSTALL_DIR=$PREFIX/lib
HEADER_INSTALL_DIR=$PREFIX/include/tensorflow
PKG_CONFIG_INSTALL_DIR=$LIB_INSTALL_DIR/pkgconfig

mkdir -p $LIB_INSTALL_DIR
mkdir -p $HEADER_INSTALL_DIR
mkdir -p $PKG_CONFIG_INSTALL_DIR

cp $BUILD_DIR/*.a $LIB_INSTALL_DIR
cp $TF_HEADER $HEADER_INSTALL_DIR

cat << EOF > $PKG_CONFIG_INSTALL_DIR/$LIB_NAME.pc
Name: $LIB_NAME
Description: Tensorflow C library
Version: ${TENSORFLOW_VERSION/v}
Libs: -L/$LIB_INSTALL_DIR -ltensorflow -lprotobuf -lc++
EOF
chmod 644 $PKG_CONFIG_INSTALL_DIR/$LIB_NAME.pc

cd $BUILD_DIR

tar -cf $FINAL_PKG $PKG_NAME/*
