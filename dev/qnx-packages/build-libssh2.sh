#!/bin/bash
#
# \file     build-libssh2.sh
# \brief    Bash script that builds and installs libssh2 library.
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

. ~/workspace/dev/ubuntu-qnx710/packages/builder-args.sh "$@"

if [ $? -ne 0 ]
then
    exit $?
fi

git clone https://github.com/libssh2/libssh2
cd libssh2
git checkout tags/libssh2-$PACKAGE_VERSION -b libssh2-$PACKAGE_VERSION-branch

mkdir build ; cd build
cmake \
    -DCMAKE_TOOLCHAIN_FILE=/root/workspace/cmake/Toolchain/qnx710-x86_64.toolchain.cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
    -DBUILD_TESTING=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DCMAKE_CXX_FLAGS="-lsocket" \
    -DCRYPTO_BACKEND="OpenSSL" \
    -DOPENSSL_INCLUDE_DIR=~/.local/include/openssl \
    -DOPENSSL_CRYPTO_LIBRARY=~/.local/lib/libssl.a \
    -DOPENSSL_SSL_LIBRARY=~/.local/lib/libssl.a \
    ..

make install

cd ../..

rm -rf libssh2
