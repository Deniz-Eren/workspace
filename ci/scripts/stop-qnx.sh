#!/bin/bash
#
# \file     stop-qnx.sh
# \brief    Bash script for Jenkins integration testing.
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

SSH_PORT="6022"             # default SSH port number

while getopts b:k:p: opt; do
    case ${opt} in
    b )
        BUILD_PATH=$OPTARG
        ;;
    k )
        SLAY_TARGET=$OPTARG
        ;;
    p )
        SSH_PORT=$OPTARG
        ;;
    \?)
        echo "Usage: stop-driver.sh [options]"
        echo "  -b build full path to use"
        echo "  -k what process to slay to stop the program"
        echo "  -p ssh port number"
        echo "  -t build type (default: Release)" 
        echo ""
        exit
        ;;
    esac
done

if [ ! -z "$SLAY_TARGET" ]; then
    docker exec --user root --workdir /root dev-env bash -c \
        "sshpass -p 'root' ssh \
            -o 'StrictHostKeyChecking=no' \
            -o 'UserKnownHostsFile=/dev/null' \
            -o 'LogLevel=ERROR' \
            -p$SSH_PORT root@localhost \
            \"slay -s SIGINT $SLAY_TARGET\" || (exit 0)"
fi

# Copy build directory back from the QNX VM
docker exec --user root --workdir /root dev-env bash -c \
    "source .profile \
    && sshpass -p 'root' scp \
        -o 'StrictHostKeyChecking=no' \
        -o 'UserKnownHostsFile=/dev/null' \
        -o 'LogLevel=ERROR' \
        -r -P$SSH_PORT \
        root@localhost:$BUILD_PATH \
        $BUILD_PATH/.."
