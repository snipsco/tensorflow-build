#!/usr/bin/env bash

TARGET=target
TOOLS_DIR=tools
TOOLCHAIN_ROOT="arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf"
#TOOLCHAIN_ROOT="arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64"
TOOLCHAIN_NAME=arm-linux-gnueabihf

VERSION=$1

if [ -z $VERSION ]
then
	echo "please provide the version tag to build"
	exit 1
fi	

mkdir $TARGET

CURRENT_DIR=$(pwd)

git clone https://github.com/raspberrypi/tools "$TARGET/$TOOLS_DIR" --depth 1

./cross-compile.sh $CURRENT_DIR/$TARGET/$TOOLS_DIR/$TOOLCHAIN_ROOT $TOOLCHAIN_NAME $VERSION







