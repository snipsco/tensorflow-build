#!/usr/bin/env bash

set -e

USAGE="Usage : $0 <tensorflow version> <android arch> <package version>"

TENSORFLOW_VERSION=${1?$USAGE}
ANDROID_ARCH=${2?$USAGE}
PACKAGE_VERSION=${3?$USAGE}

BUILD_DIR=`pwd`/target

CREATE_PKGCONFIG=`pwd`/create-pkgconfig.sh

# Tensorflow need to be built with GCC witch is only supported by bazel up to NDK r12b
# If you really need to build with a more recent NDK, you can trick bazel by changing
# the source.properties of a higher NDK to the one of a r12b
# Building with a stock r13+ NDK will use clang and end up in pain related to some assembly
NDK_NAME=android-ndk-r12b
NDK_ARCHIVE=$NDK_NAME-linux-x86_64.zip
NDK_DIR=$BUILD_DIR/$NDK_NAME

# We create a dir with a tree containing the .so and a .pc file that can be overlayed over a sysroot
PKG_NAME=tensorflow-android-$ANDROID_ARCH-$PACKAGE_VERSION
PKG_DIR=$BUILD_DIR/$PKG_NAME
FINAL_PKG=$PKG_DIR.tar.gz

mkdir $BUILD_DIR
cd $BUILD_DIR

wget https://dl.google.com/android/repository/$NDK_ARCHIVE

unzip $NDK_ARCHIVE

git clone https://github.com/tensorflow/tensorflow

cd tensorflow

git checkout $TENSORFLOW_VERSION

cat << EOF >> WORKSPACE
android_ndk_repository(
    name="androidndk",
    path="$NDK_DIR",
    api_level=14)
EOF

# Add a new tensorflow target bundling the C API over the Android specific TF core lib
cat << EOF >> tensorflow/contrib/android/BUILD
cc_binary(
    name = "libtensorflow.so",
    srcs = [],
    copts = tf_copts() + [
        "-ffunction-sections",
        "-fdata-sections",
    ],
    linkopts = if_android([
        "-landroid",
        "-llog",
        "-lm",
        "-z defs",
        "-s",
        "-Wl,--gc-sections",
	# soname is required for the so to load on api > 22
        "-Wl,-soname=libtensorflow.so",
        "-Wl,--version-script",
        "//tensorflow/c:version_script.lds",
    ]),
    linkshared = 1,
    linkstatic = 1,
    tags = [
        "manual",
        "notap",
    ],
    deps = [
        "//tensorflow/c:c_api",
        "//tensorflow/c:version_script.lds",
        "//tensorflow/core:android_tensorflow_lib",
    ],
)
EOF

echo "Launching bazel $BAZEL_FLAGS"

bazel build $BAZEL_FLAGS -c opt //tensorflow/contrib/android:libtensorflow.so \
   --verbose_failures \
   --crosstool_top=//external:android/crosstool \
   --host_crosstool_top=@bazel_tools//tools/cpp:toolchain \
   --cpu=$ANDROID_ARCH

echo "Creating $FINAL_PKG"

TF_SO="`pwd`/bazel-bin/tensorflow/contrib/android/libtensorflow.so"
TF_HEADER="`pwd`/tensorflow/c/c_api.h"

mkdir $PKG_DIR
cd $PKG_DIR

LIB_NAME=tensorflow
PREFIX=usr
SO_INSTALL_DIR=$PREFIX/lib
HEADER_INSTALL_DIR=$PREFIX/include/tensorflow
PKG_CONFIG_INSTALL_DIR=$SO_INSTALL_DIR/pkgconfig

mkdir -p $SO_INSTALL_DIR
mkdir -p $PKG_CONFIG_INSTALL_DIR
mkdir -p $HEADER_INSTALL_DIR

install -Dm755 $TF_SO $SO_INSTALL_DIR

install -Dm644  $TF_HEADER $HEADER_INSTALL_DIR

$CREATE_PKGCONFIG "$LIB_NAME" "/$SO_INSTALL_DIR" "${TENSORFLOW_VERSION/v}" "Tensorflow C library" > $PKG_CONFIG_INSTALL_DIR/$LIB_NAME.pc

chmod 644 $PKG_CONFIG_INSTALL_DIR/$LIB_NAME.pc

cd $BUILD_DIR

tar -cf $FINAL_PKG $PKG_NAME/*
