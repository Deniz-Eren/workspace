#!/bin/sh
#
# \file     mount_fs.sh
# \brief    Bash script included in the image filesystem (IFS) that runs during
#           boot up of the QNX OS test image.
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

echo "---> Mounting file systems"

if [ -e /data -a -e /system ]; then
    exit 0
fi

mount -t qnx6 /dev/hd0t177 /boot
if [ -e /boot/onboot ]; then
	echo Running onboot script
	ksh /boot/onboot
fi

mount -t qnx6  /dev/hd0t179 /data 

if [ -e /dev/hd0t185 ]; then
	# Mounting a QTD protected file system is a two step process.  First mount the QTD
	# container and then the file system contained within
	mount -t qtd -o key=/proc/boot/qtd_public_key.pem  /dev/hd0t185 /dev/hd0t185-fs
	if check_magic /dev/hd0t185-fs 8192 "\0042\0021\0031\0150"; then
		mount -t qnx6 -o noatime  /dev/hd0t185-fs /system
	elif check_magic /dev/hd0t185-fs 0 "\0377\0272\0377\0261"; then
		mount -t qcfs  /dev/hd0t185-fs /system
	else
		echo "Don't recognise the filesystem"
	fi
	rm -f /dev/shmem/fs-magic*
elif [ -e /dev/hd0t186 ]; then
    qtsafefsd -o key=/proc/boot/qtsafefs_public_key.pem  /dev/hd0t186 /system
elif [ -e /dev/hd0t181 ]; then
	mount -t qcfs  /dev/hd0t181 /system
else # QNX6
	mount -t qnx6 -o noatime  /dev/hd0t178 /system 
fi

/system/xbin/cleanup_tmp
