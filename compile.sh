#!/usr/bin/env bash

BUILD_DIR=target

TENSORFLOW_VERSION=$1

if [ -z $TENSORFLOW_VERSION ]
then
	echo "usage: $0 <tensorflow tag/commit>"
	exit
fi 

mkdir $BUILD_DIR

cd $BUILD_DIR

git clone https://github.com/tensorflow/tensorflow.git

cd tensorflow

git checkout $TENSORFLOW_VERSION || exit 1

yes ''|./configure || exit 1

echo "launching bazel with flags '$BAZEL_FLAGS'"

bazel build $BAZEL_FLAGS tensorflow:libtensorflow.so --verbose_failures

