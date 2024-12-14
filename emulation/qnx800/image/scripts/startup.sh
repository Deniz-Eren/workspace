#!/bin/sh
#
# \file     startup.sh
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

# By default set umask so that services don't accidentally create group/world writable files.
umask 022

echo "---> Starting slogger2"
slogger2 -U 21:21
waitfor /dev/slog

devc-con -e 

on  -d -t /dev/con1 ksh -l
# Start more consoles which can be switched to using ctrl-alt-[1-4]
on  -d -t /dev/con2 ksh -l
on  -d -t /dev/con3 ksh -l
on  -d -t /dev/con4 ksh -l

echo "---> Starting PCI Services"
pci-server --config=/proc/boot/pci_server.cfg
waitfor /dev/pci/server_id_1
# Not ideal. Can't set ACLs. Perhaps supplementary groups would be better
chmod a+rx /dev/pci/server_id_1

echo "---> Starting fsevmgr"
fsevmgr

echo "---> Starting disk drivers"
devb-ahci cam user=20:20 blk cache=64M,auto=partition,vnode=2000,ncache=2000,commit=low
waitfor /dev/hd0

echo "---> Mounting file systems"
mount_fs.sh

#To support proper operation of input capture via io-hid, devc-con-hid should be used instead

reopen /dev/con2

random -U 22:22 -s /data/var/random/rnd-seed  
waitfor /dev/random
pipe -U 24:24
waitfor /dev/pipe
devc-pty -U 37:37
dumper -U 30:30 -d /data/var/dumper

echo "---> Starting Networking"
/system/etc/rc.d/rc.net

echo "---> Starting sshd"
if [ ! -f /data/var/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -q -t rsa -N '' -f /data/var/ssh/ssh_host_rsa_key
    chown 0:0 /data/var/ssh/ssh_host_rsa_key*
fi
if [ ! -f /data/var/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -q -t ed25519 -N '' -f /data/var/ssh/ssh_host_ed25519_key
    chown 0:0 /data/var/ssh/ssh_host_ed25519_key*
fi
/system/xbin/sshd -f /system/etc/ssh/sshd_config

echo "---> Starting misc"
qconn
mqueue

# Execute the post startup script.  This is a separate script to allow for common behavior of
# both slm and script based startup.
/proc/boot/post_startup.sh
