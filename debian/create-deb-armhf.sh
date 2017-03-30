#/usr/bin/env bash

TARGET_SO_FILE=target/tensorflow/bazel-bin/tensorflow/libtensorflow.so
C_HEADERS_FILE=target/tensorflow/tensorflow/c/c_api.h

. ./versions.sh

./compile-arm.sh "$TF_VERSION"
./create-deb.sh "$TARGET_SO_FILE" "$C_HEADERS_FILE" armhf "$TF_DEB_VERSION"


