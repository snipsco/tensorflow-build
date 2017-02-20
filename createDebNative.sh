#/usr/bin/env bash

COMPILE_ARM_PATH=compile-arm.sh
TARGET_SO_FILE=target/tensorflow/bazel-bin/tensorflow/libtensorflow_c.so

./compile.sh "v1.0.0"
./createDeb.sh "$TARGET_SO_FILE" x86_64 "1.0.0-snips-3"


