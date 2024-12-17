#!/bin/bash
#
# \file     start-emulation.sh
# \brief    Bash script for starting QEmu VM for CI testing.
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

SSH_PORT="6022"     # default SSH port number
optq=qnx800

while getopts i:p:q: opt; do
    case ${opt} in
    i )
        IMAGE_PATH=$OPTARG
        ;;
    p )
        SSH_PORT=$OPTARG
        ;;
    q )
        optq=$OPTARG
        ;;
    \?)
        echo "Usage: start-emulation.sh [options]"
        echo "  -i path name of the image file to use"
        echo "  -p ssh port number"
        echo ""
        exit
        ;;
    esac
done

if [[ -z "${IMAGE_PATH}" ]]; then
    echo "error - location of the image hasn't been specified."
    exit -1
fi

IMAGE_FILENAME=`basename $IMAGE_PATH`

docker run -d --name=qemu-env \
    --network host \
    --device=/dev/kvm \
    localhost/dev-qemu tail -f /dev/null

docker cp $IMAGE_PATH qemu-env:/root/Images

if [[ "$optq" == "qnx800" ]]; then
    docker exec -d --user root --workdir /root qemu-env \
        qemu-system-x86_64 \
            -cpu host \
            -k en-us \
            -drive id=disk,file=/root/Images/$IMAGE_FILENAME,format=raw,if=none \
            -device ahci,id=ahci \
            -device ide-hd,drive=disk,bus=ahci.1 \
            -boot d \
            -object can-bus,id=c0 \
            -object can-bus,id=c1 \
            -object can-bus,id=c2 \
            -device mioe3680_pci,canbus0=c0,canbus1=c1 \
            -device kvaser_pci,canbus=c2 \
            -object can-host-socketcan,id=h0,if=c0,canbus=c0,if=vcan1000 \
            -object can-host-socketcan,id=h1,if=c1,canbus=c1,if=vcan1001 \
            -object can-host-socketcan,id=h2,if=c2,canbus=c2,if=vcan1002 \
            -m size=4096 \
            -nic user,model=virtio-net-pci,hostfwd=tcp::$SSH_PORT-:22 \
            -smp 2 \
            -enable-kvm \
            -nographic
elif [[ "$optq" == "qnx710" ]]; then
    docker exec -d --user root --workdir /root qemu-env \
        qemu-system-x86_64 \
            -cpu host \
            -k en-us \
            -drive id=disk,file=/root/Images/$IMAGE_FILENAME,format=raw,if=none \
            -device ahci,id=ahci \
            -device ide-hd,drive=disk,bus=ahci.1 \
            -boot d \
            -object can-bus,id=c0 \
            -object can-bus,id=c1 \
            -object can-bus,id=c2 \
            -device mioe3680_pci,canbus0=c0,canbus1=c1 \
            -device kvaser_pci,canbus=c2 \
            -object can-host-socketcan,id=h0,if=c0,canbus=c0,if=vcan1000 \
            -object can-host-socketcan,id=h1,if=c1,canbus=c1,if=vcan1001 \
            -object can-host-socketcan,id=h2,if=c2,canbus=c2,if=vcan1002 \
            -m size=4096 \
            -nic user,hostfwd=tcp::$SSH_PORT-:22 \
            -smp 2 \
            -enable-kvm \
            -nographic
fi

# Wait until emulator SSH port is ready
docker exec --user root --workdir /root dev-env \
    bash -c "source .profile \
        && until sshpass -p 'root' ssh \
            -o 'StrictHostKeyChecking=no' \
            -o 'UserKnownHostsFile=/dev/null' \
            -o 'LogLevel=ERROR' \
            -p$SSH_PORT root@localhost \"uname -a\" \
            2> /dev/null; \
            do sleep 1; done"
