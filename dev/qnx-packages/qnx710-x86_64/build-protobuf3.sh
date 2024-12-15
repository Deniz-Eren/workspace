#!/bin/bash
#
# \file     build-protobuf3.sh
# \brief    Bash script that builds and installs Google Protobuf 3 library.
#
# Copyright (C) 2023 Deniz Eren (deniz.eren@outlook.com)
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.
#

DIR="$(realpath $(dirname "$0"))"

. $DIR/builder-args.sh "$@"

if [ $? -ne 0 ]
then
    exit $?
fi

wget https://github.com/protocolbuffers/protobuf/releases/download/v$PACKAGE_VERSION/protobuf-cpp-3.$PACKAGE_VERSION.tar.gz

tar xf protobuf-cpp-3.$PACKAGE_VERSION.tar.gz
cd protobuf-3.$PACKAGE_VERSION

CC=$QNX_HOST/usr/bin/ntox86_64-gcc \
CXX=$QNX_HOST/usr/bin/ntox86_64-g++ \
LD=$QNX_HOST/usr/bin/ntox86_64-ld \
CFLAGS='-fPIC' \
CXXFLAGS='-fPIC' \
LIBS="-L$QNX_HOST/usr/lib \
       -L$QNX_TARGET/x86_64/lib \
       -L$QNX_TARGET/x86_64/lib/gcc/8.3.0 \
       -lc" \
    ./configure --prefix=$PREFIX \
       --with-protoc=/usr/bin/protoc \
       --host=x86_64-pc-linux-gnu \
       --target=x86_64-pc-nto-qnx7.1.0 \
       --disable-shared

make install

cd ..

rm -rf protobuf-cpp-3.$PACKAGE_VERSION.tar.gz \
       protobuf-3.$PACKAGE_VERSION
