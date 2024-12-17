#!/bin/bash
#
# \file     build-cppzmq.sh
# \brief    Bash script that builds and installs cppzmq library.
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

git clone https://github.com/zeromq/cppzmq.git
cd cppzmq
git checkout tags/v$PACKAGE_VERSION -b v$PACKAGE_VERSION-branch

mkdir build ; cd build
cmake \
    -DCMAKE_TOOLCHAIN_FILE=$DIR/../../../cmake/Toolchain/qnx710-x86_64.toolchain.cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
    -DBUILD_TESTS=OFF \
    -DCMAKE_CXX_FLAGS="-lsocket" \
    ..

make install

cd ../..

rm -rf cppzmq
