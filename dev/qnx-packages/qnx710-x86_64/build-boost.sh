#!/bin/bash
#
# \file     build-boost.sh
# \brief    Bash script that builds and installs Boost library.
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

wget https://archives.boost.io/release/$PACKAGE_VERSION/source/boost_$PACKAGE_VERSION_UNDERSCORE.tar.gz

tar xf boost_$PACKAGE_VERSION_UNDERSCORE.tar.gz
cd boost_$PACKAGE_VERSION_UNDERSCORE

./bootstrap.sh --prefix=$PREFIX

echo using qcc : 7.1 : $QNX_HOST/usr/bin/qcc \; > project-config.jam

./b2 install toolset=qcc-7.1 target-os=qnx threadapi=pthread \
        --with-system \
        --with-thread \
        --with-test \
        --with-program_options \
        --with-filesystem \
        --with-date_time \
        --with-iostreams \
        --with-log \
        --prefix=$PREFIX

cd ..

rm -rf boost_$PACKAGE_VERSION_UNDERSCORE.tar.gz \
       boost_$PACKAGE_VERSION_UNDERSCORE
