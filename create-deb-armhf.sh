#/usr/bin/env bash

TARGET_SO_FILE=target/tensorflow/bazel-bin/tensorflow/libtensorflow_c.so

. versions.sh

./compile-arm.sh "$TF_VERSION"
./create-deb.sh "$TARGET_SO_FILE" armhf "$TF_DEB_VERSION"


