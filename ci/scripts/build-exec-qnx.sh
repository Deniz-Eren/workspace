#!/bin/bash
#
# \file     build-exec-qnx.sh
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

CMAKE_BUILD_TYPE="Release"      # default build type
DISABLE_COVERAGE_HTML_GEN="ON"  # default cmake disable coverage html option
SSH_PORT="6022"                 # default SSH port number
TOOLCHAIN_FILE="qnx800-x86_64.toolchain.cmake"  # default to QNX 8.0 x86_64
optq=qnx800

while getopts b:c:e:h:p:q:r:s:t:T:vw: opt; do
    case ${opt} in
    b )
        BUILD_PATH=$OPTARG
        ;;
    c )
        COMMAND=$OPTARG
        ;;
    e )
        ENV_FILE=$OPTARG
        ;;
    h )
        DISABLE_COVERAGE_HTML_GEN=$OPTARG
        ;;
    p )
        SSH_PORT=$OPTARG
        ;;
    q )
        optq=$OPTARG
        ;;
    r )
        REPO=$OPTARG
        ;;
    s )
        COPY_DEBUG_SYMS=$OPTARG
        ;;
    t )
        CMAKE_BUILD_TYPE=$OPTARG
        ;;
    T )
        TOOLCHAIN_FILE=$OPTARG
        ;;
    v )
        VERBOSE="-vvvvv"
        ;;
    w )
        WAITFOR=$OPTARG
        ;;
    \?)
        echo "Usage: start-driver.sh [options]"
        echo "  -b build full path to use"
        echo "  -c program namd or command to run"
        echo "  -p ssh port number"
        echo "  -q QNX version (default: qnx800)"
        echo "  -r repository location"
        echo "  -s if not empty then copy debug symbols for libc.so"
        echo "  -t build type (default: Release)"
        echo "  -T CMake toolchain file (default: qnx800-x86_64.toolchain.cmake)"
        echo "  -v for verbose mode"
        echo "  -w file to waitfor after starting the program"
        echo " Environment variable QNX_PREFIX_CMD is placed as prefix to"
        echo " running executable specified by the -c command option"
        echo ""
        exit
        ;;
    esac
done

docker exec --user root --workdir /root dev-env bash -c \
    "source .profile \
    && source $REPO/workspace/dev/ubuntu-$optq/setup-profile.sh \
    && if [ ! -z \"$ENV_FILE\" ]; then \
            source $ENV_FILE; fi \
    && mkdir -p $BUILD_PATH \
    && cd $BUILD_PATH \
    && cmake -DCMAKE_TOOLCHAIN_FILE=$REPO/workspace/cmake/Toolchain/$TOOLCHAIN_FILE \
        -DSSH_PORT=$SSH_PORT -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
        -DDISABLE_COVERAGE_HTML_GEN=${DISABLE_COVERAGE_HTML_GEN} \
        $REPO \
    && make -j8 \
    && cpack"

# Copy build directory to the QNX VM
docker exec --user root --workdir /root dev-env bash -c \
    "source .profile \
    && sshpass -p 'root' scp \
        -o 'StrictHostKeyChecking=no' \
        -o 'UserKnownHostsFile=/dev/null' \
        -o 'LogLevel=ERROR' \
        -r -P$SSH_PORT $BUILD_PATH \
        root@localhost:$BUILD_PATH"

docker exec --user root --workdir /root dev-env bash -c \
    "sshpass -p 'root' ssh \
        -o 'StrictHostKeyChecking=no' \
        -o 'UserKnownHostsFile=/dev/null' \
        -o 'LogLevel=ERROR' \
        -p$SSH_PORT root@localhost \
        \"find $BUILD_PATH -iname \"*-*.tar.gz\" \
            -exec tar -xf {} -C /opt/ \\; \""

if [ ! -z "$COPY_DEBUG_SYMS" ]; then
    #
    # Valgrind (perhaps on QNX) has many strange issues. One of them is that the
    # debug symbols for libc.so.# is required, which is named libc.so.#.sym. Both
    # of these libraries must be located in the same location.
    # Unsuccessful testing was done with program option _--extra-debuginfo-path=_
    # with no detectable behaviour change.
    # Also the system isn't happy with these two files being located in location
    # _/proc/boot_ for some reason, perhaps because it's not a mounted disk
    # location.
    # This is true even though both _PATH_ and _LD_LIBRARY_PATH_ contains
    # _/proc/boot_:
    # 
    #     echo $PATH
    #     /opt/bin:/proc/boot:/system/xbin
    #     
    #     echo $LD_LIBRARY_PATH
    #     /opt/lib:/proc/boot:/system/lib:/system/lib/dll
    # 
    # To work around this we've made copies of these libraries to disk on the
    # location _/opt/lib_:
    # 
    #     cp /proc/boot/libc.so.* /opt/lib/
    #

    docker exec --user root --workdir /root dev-env bash -c \
        "sshpass -p 'root' ssh \
            -o 'StrictHostKeyChecking=no' \
            -o 'UserKnownHostsFile=/dev/null' \
            -o 'LogLevel=ERROR' \
            -p$SSH_PORT root@localhost \
            \"cp /proc/boot/libc.so.* /opt/lib/\""
fi

if [ ! -z "$COMMAND" ]; then
    docker exec -d --user root --workdir /root dev-env bash -c \
        "sshpass -p 'root' ssh \
            -o 'StrictHostKeyChecking=no' \
            -o 'UserKnownHostsFile=/dev/null' \
            -o 'LogLevel=ERROR' \
            -p$SSH_PORT root@localhost \
            \"cd $BUILD_PATH ; $QNX_PREFIX_CMD $COMMAND $VERBOSE\""

    if [ ! -z "$WAITFOR" ]; then
        docker exec --user root --workdir /root dev-env bash -c \
            "sshpass -p 'root' ssh \
                -o 'StrictHostKeyChecking=no' \
                -o 'UserKnownHostsFile=/dev/null' \
                -o 'LogLevel=ERROR' \
                -p$SSH_PORT root@localhost \
                \"waitfor $WAITFOR\""
    fi
fi
