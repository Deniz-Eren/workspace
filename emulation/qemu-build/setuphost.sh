#!/bin/bash
#
# \file     setuphost.sh
# \brief    Bash script that prepares the host Linux system with needed
#           functionality before running Docker-compose.
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

modprobe vcan kvm

if [ ! -d /sys/class/net/vcan0 ]; then
    echo "Setting up VCAN0..."
    ip link add dev vcan0 type vcan
    ip link set up vcan0
else echo "VCAN0 already setup"
fi

if [ ! -d /sys/class/net/vcan1 ]; then
    echo "Setting up VCAN1..."
    ip link add dev vcan1 type vcan
    ip link set up vcan1;
else echo "VCAN1 already setup"
fi

if [ ! -d /sys/class/net/vcan2 ]; then
    echo "Setting up VCAN2..."
    ip link add dev vcan2 type vcan
    ip link set up vcan2;
else echo "VCAN2 already setup"
fi
