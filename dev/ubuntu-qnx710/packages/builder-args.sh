#!/bin/bash
#
# \file     builder-args.sh
# \brief    Bash script that parses builder script command-line arguments
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

if [ -z "$QNX_HOST" ]; then
    echo "Cannot find QNX toolchain, ensure to run within workspace/dev"
         "environment container"

    exit -1
fi

PREFIX=~/.local

while getopts p:v: opt; do
    case ${opt} in
    p )
        PREFIX=$OPTARG
        ;;
    v )
        PACKAGE_VERSION=$OPTARG
        ;;
    \?)
        echo "Usage: $(basename $0) [options]"
        echo "  -p install prefix (default: ~/.local)"
        echo "  -v package version (e.g. 1.0.0)"
        echo ""
        exit
        ;;
    esac
done

if [ -z "$PACKAGE_VERSION" ]; then
    echo "Must specify package version"

    exit -1
fi

PACKAGE_VERSION_UNDERSCORE=${PACKAGE_VERSION//./_}

mkdir -p $PREFIX
