#!/bin/bash

SOURCE_DIR=`pwd`

if [ -n "$1" ]; then
    VERSION=`git describe --tags`
    if [ -z "$VERSION" ]; then
        VERSION=` git rev-parse HEAD`
    fi
    
    echo "Current verion: $VERSION, The version to will be set: $1"
    read -t 30 -p "Be sure to input Y, not input N: " INPUT
    if [ "$INPUT" != "Y" -a "$INPUT" != "y" ]; then
        exit 0
    fi
    git tag -a $1 -m "Release $1"
    ./tag.sh
fi

VERSION=`git describe --tags`
if [ -z "$VERSION" ]; then
    VERSION=`git rev-parse --short HEAD`
fi

sed -i "s/^\!define PRODUCT_VERSION.*/\!define PRODUCT_VERSION \"${VERSION}\"/g" ${SOURCE_DIR}/Install/Install.nsi
sed -i "s/^SET(BUILD_VERSION \".*\")/SET(BUILD_VERSION \"${VERSION}\")/g" ${SOURCE_DIR}/CMakeLists.txt
sed -i "s/^\isEmpty(BUILD_VERSION): BUILD_VERSION=.*/isEmpty(BUILD_VERSION): BUILD_VERSION=\"${VERSION}\"/g" ${SOURCE_DIR}/pri/RabbitImVersion.pri
sed -i "s/^\SET(BUILD_VERSION.*/SET(BUILD_VERSION \"${VERSION}\")/g" ${SOURCE_DIR}/cmake/install_version.cmake
APPVERYOR_VERSION="version: '${VERSION}.{build}'"
sed -i "s/^version: '.*{build}'/${APPVERYOR_VERSION}/g" ${SOURCE_DIR}/appveyor.yml
sed -i "s/^\Standards-Version:.*/Standards-Version:\"${VERSION}\"/g" ${SOURCE_DIR}/debian/control
sed -i "s/export VERSION=.*/export VERSION=\"${VERSION}\"/g" ${SOURCE_DIR}/ci/build.sh

DEBIAN_VERSION=`echo ${VERSION}|cut -d "v" -f 2`
sed -i "s/rabbitim (.*)/rabbitim (${DEBIAN_VERSION})/g" ${SOURCE_DIR}/debian/changelog

#git tag -a v${VERSION} -m "Release v${VERSION}"
#git push origin :refs/tags/v${VERSION}
#git push origin v${VERSION}

if [ -n "$1" ]; then
    git add .
    git commit -m "Release $1"
    git push
    git tag -d $1
    git tag -a $1 -m "Release $1"
    git push origin :refs/tags/$1
    git push origin $1
fi
