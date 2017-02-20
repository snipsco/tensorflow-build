#/usr/bin/env bash

COMPILE_ARM_PATH=../../cross-compile/compile-arm.sh
TARGET_SO_FILE=../../cross-compile/target/tensorflow/bazel-bin/tensorflow/libtensorflow_c.so

./compile-arm.sh "v1.0.0"
./createDeb.sh "$TARGET_SO_FILE" armhf "1.0.0-snips-3"


