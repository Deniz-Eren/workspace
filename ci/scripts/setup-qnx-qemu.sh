#!/bin/bash
#
# \file     setup-qnx-qemu.sh
# \brief    Bash script for setup of QNX image run within QEmu container.
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

# default dev-env Dockerfile is ubuntu-stable
optd=/opt/workspace/emulation/qnx800/Dockerfile
optq=qnx800

while getopts d:i:q: opt; do
    case ${opt} in
    d )
        optd=$OPTARG
        ;;
    i )
        opti=$OPTARG
        ;;
    q )
        optq=$OPTARG
        ;;
    \?)
        echo "Usage: $(basename $0) [options]"
        echo "  -d Dockerfile to use for qemu-env container"
        echo "  -i path name of the image file to use"
        echo "  -q QNX version (default: qnx800)"
        echo ""
        exit
        ;;
    esac
done

if [[ -z "${opti}" ]]; then
    echo "error - location to store image hasn't been specified."
    exit -1
fi

docker build \
    -f $optd \
    -t localhost/dev-qemu .

docker exec --user root --workdir /root dev-env bash -c \
    "source .profile \
    && /root/workspace/dev/.setup-profile.sh \
    && cd /root/workspace/emulation/$optq/image \
    && ./builddisk.sh"

rm -rf $opti

docker cp dev-env:/root/workspace/emulation/$optq/image/output $opti

