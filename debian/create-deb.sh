#!/usr/bin/env bash

SO_FILE=$1
HEADERS_FILE=$2
SO_ARCH=$3
SO_VERSION=$4

BUILD_DIR=target

PACKAGE_NAME="libtensorflow"
LIB_NAME="tensorflow"
LIB_DESC="Tensorflow C library"

DEBIAN_DIR=DEBIAN
CONTROL_FILE=control

SO_INSTALL_DIR="/usr/lib/"
PC_INSTALL_DIR="/usr/lib/pkgconfig/"
HEADERS_INSTALL_DIR="/usr/include/$LIB_NAME"

SO_INSTALL_NAME="lib$LIB_NAME.so"
PC_INSTALL_NAME="$LIB_NAME.pc"
HEADERS_INSTALL_NAME="c_api.h"

if [ -z $SO_FILE ] || [ ! -f $SO_FILE ]
then
	echo "file not found $SO_FILE"
fi
if [ -z $HEADERS_FILE ] || [ ! -f $HEADERS_FILE ]
then
	echo "file not found $HEADERS_FILE"
fi
if [ -z $SO_ARCH ]
then
	echo "arch not found"
fi
if [ -z $SO_VERSION ]
then
	echo "version not found"
fi
if [ -z $SO_FILE ] || [ ! -f $SO_FILE ] || [ -z $HEADERS_FILE ] || [ ! -f $HEADERS_FILE ] || [ -z $SO_ARCH ] || [ -z $SO_VERSION ]
then
	echo "usage: $0 <path/to/libtensorflow.so> <path/to/c/headers> <arch> <version>"
	exit 1
fi

DEB_NAME="${PACKAGE_NAME}_${SO_VERSION}_${SO_ARCH}"

mkdir -p "$BUILD_DIR/$DEB_NAME/$SO_INSTALL_DIR"
mkdir -p "$BUILD_DIR/$DEB_NAME/$PC_INSTALL_DIR"
mkdir -p "$BUILD_DIR/$DEB_NAME/$HEADERS_INSTALL_DIR"
mkdir -p "$BUILD_DIR/$DEB_NAME/$DEBIAN_DIR"

cp "$SO_FILE" "$BUILD_DIR/$DEB_NAME/$SO_INSTALL_DIR/$SO_INSTALL_NAME"
cp "$HEADERS_FILE" "$BUILD_DIR/$DEB_NAME/$HEADERS_INSTALL_DIR/$HEADERS_INSTALL_NAME"

cd $BUILD_DIR

cat << EOF > $DEB_NAME/$DEBIAN_DIR/$CONTROL_FILE
Package: $PACKAGE_NAME
Version: $SO_VERSION
Section: base
Priority: optional
Architecture: $SO_ARCH
Maintainer: Thibaut Lorrain <thibaut.lorrain@snips.ai>
Description: $LIB_DESC
Homepage: https://www.tensorflow.org 
EOF


../create-pkgconfig.sh "$LIB_NAME" "$SO_INSTALL_DIR" "$SO_VERSION" "$LIB_DESC"  > $DEB_NAME/$PC_INSTALL_DIR/$PC_INSTALL_NAME

dpkg-deb --build $DEB_NAME
