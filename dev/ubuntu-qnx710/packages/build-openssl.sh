#!/bin/bash
#
# \file     build-openssl.sh
# \brief    Bash script that builds and installs openssl library.
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

git clone https://github.com/openssl/openssl.git
cd openssl
git checkout tags/openssl-$PACKAGE_VERSION -b openssl-$PACKAGE_VERSION-branch

git submodule init
git submodule update

CC=$QNX_HOST/usr/bin/ntox86_64-gcc \
CXX=$QNX_HOST/usr/bin/ntox86_64-g++ \
LD=$QNX_HOST/usr/bin/ntox86_64-ld \
CFLAGS='-fPIC' \
CXXFLAGS='-fPIC' \
LDFLAGS="-L$QNX_HOST/usr/lib \
       -L$QNX_TARGET/x86_64/lib \
       -L$QNX_TARGET/x86_64/lib/gcc/8.3.0 \
       -lc -lsocket" \
    ./Configure --prefix=$PREFIX no-dgram gcc

make install

cd ..

rm -rf openssl
