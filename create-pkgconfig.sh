#!/usr/bin/env bash

if [ "$#" -ne 4 ]
then
	echo "usage: $0 <lib name> <lib install dir> <lib version> <lib description>"
	exit 1
fi	

LIB_NAME=$1
SO_INSTALL_DIR=$2
SO_VERSION=$3
LIB_DESC=$4

cat << EOF 
Name: $LIB_NAME
Description: $LIB_DESC
Version: $SO_VERSION
Libs: -L$SO_INSTALL_DIR -l$LIB_NAME -lstdc++
EOF
