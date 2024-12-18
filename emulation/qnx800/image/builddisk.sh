#!/bin/bash
#
# \file     builddisk.sh
# \brief    Bash script that must run on a licensed QNX system to generate the
#           the QNX OS test image.
#
# Copyright (C) 2025 Deniz Eren (deniz.eren@outlook.com)
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

# Clean the old builds
rm -rf output/system.part \
    output/data.part \
    output/ifs.bin \
    output/procnto-smp-instr.sym \
    output/ifs.part \
    disk-raw \
    ifs_part.build \
    disk.layout

# ANSI escape sequences to get colour into the output
clr_red=
clr_bold=
clr_normal=

# Only use colour if outputting to a terminal
if [ -t 1 ]; then
    clr_red="\033[91;1m"
    clr_bold="\033[1m"
    clr_normal="\033[0m"
fi

#. ${TOOL_DIR}/functions
. $QNX_BASE/host/common/mkqnximage/functions
#. local/options

### System Partition ###########################################################

echo Generating system partition . . .
echo -ne $clr_red
mkqnx6fsimg ./parts/system.build output/system.part

rc=$?
echo -ne $clr_normal
if [ $rc != 0 ]; then
    echo "Failed to create system partition"
    exit 1
fi

SYS_NAME=output/system.part
SYS_TYPE=178
SYS_GUID=qnx6

SYS_SIZE=`file_size ${SYS_NAME} 512`

### Data Partition #############################################################

echo Generating data partition . . .
echo -ne $clr_red
mkqnx6fsimg ./parts/data.build output/data.part
rc=$?
echo -ne $clr_normal
if [ $? != 0 ]; then
    echo "Failed to create data partition"
    exit 1
fi

DATA_SIZE=`file_size output/data.part 512`

### IFS Partition ##############################################################

echo Generating ifs . . .
echo -ne $clr_red
mkifs -o output ./parts/ifs.build output/ifs.bin
rc=$?
echo -ne $clr_normal
if [ $rc != 0 ]; then
    echo "Failed to create ifs boot image"
    exit 1
fi


echo Building disk . . .

cat >ifs_part.build <<EOF
[num_sectors=*80]
/.boot/AVCS800.ifs=output/ifs.bin
EOF

echo -ne $clr_red
mkqnx6fsimg ifs_part.build output/ifs.part
rc=$?
echo -ne $clr_normal
if [ $rc != 0 ]; then
    echo "Failed to create ifs partition"
    exit 1
fi
IFS_SIZE=`file_size output/ifs.part 512`

# raw disk size + extra for alignment overhead
DISK_SIZE=$(($IFS_SIZE + $SYS_SIZE + $DATA_SIZE + 10))

cat >disk.layout <<EOF
[sector_size=512 cylinders=${DISK_SIZE} sectors_per_track=1 heads=1 start_at_cylinder=1]
[partition=1 boot=true type=177 ] "output/ifs.part"
[partition=2 boot=false type=${SYS_TYPE} ] "${SYS_NAME}"
[partition=3 boot=false type=179 ] "output/data.part"
EOF

diskimage_options=(-c disk.layout -o output/disk-raw -b ${QNX_TARGET}/x86_64/boot/sys/ipl-diskpc1-nomsg)

################################################################################

if ! diskimage ${diskimage_options[@]}; then
    echo "Failed to build disk image"
    exit 1
fi

rm -rf output/system.part \
    output/data.part \
    output/ifs.bin \
    output/procnto-smp-instr.sym \
    output/ifs.part \
    disk-raw \
    ifs_part.build \
    disk.layout
