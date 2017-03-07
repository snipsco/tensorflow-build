#!/usr/bin/env bash

PATCH_ORIG=tf-crosscompile.patch
BUILD_DIR=target

CT_DIR=$1
CT_NAME=$2
TENSORFLOW_VERSION=$3

GCC=$1/bin/$2-gcc
GCC_VERSION=$($GCC -dumpversion)
if [ ! -f $GCC ] || [ -z $TENSORFLOW_VERSION ]
then
	echo "usage: $0 <absolute cross toolchain path> <toolchain prefix> <tensorflow tag/commit>"
	echo "seaching gcc here : $GCC"
	exit
fi 

GCC_VERSION=$($GCC -dumpversion)
echo "using gcc : $GCC version $GCC_VERSION" 

PATCH_NAME=tf-crosscompile-$CT_NAME.patch
mkdir $BUILD_DIR

cp $PATCH_ORIG $BUILD_DIR/$PATCH_NAME

cd $BUILD_DIR

sed -i "s#%%CT_NAME%%#$CT_NAME#g" $PATCH_NAME
sed -i "s#%%CT_ROOT_DIR%%#$CT_DIR#g" $PATCH_NAME
sed -i "s#%%CT_GCC_VERSION%%#$GCC_VERSION#g" $PATCH_NAME

git clone https://github.com/tensorflow/tensorflow.git

cd tensorflow

git checkout $TENSORFLOW_VERSION || exit 1

git apply ../$PATCH_NAME || exit 1

grep -Rl 'lib64' | xargs sed -i 's/lib64/lib/g'

yes ''|./configure || exit 1

echo "launching bazel with flags '$BAZEL_FLAGS'"

bazel build $BAZEL_FLAGS -c opt --copt="-march=armv6" --copt="-mfpu=vfp" --copt="-funsafe-math-optimizations" --copt="-ftree-vectorize" --copt="-fomit-frame-pointer"  tensorflow:libtensorflow.so --cpu=armeabi --crosstool_top=//tools/arm_compiler:toolchain --verbose_failures
