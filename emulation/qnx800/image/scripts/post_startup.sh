#!/bin/sh
#
# \file     post_startup.sh
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

# Configure locations of PAM files.  Note, pamconf must end with a slash
setconf pamlib /system/lib/dll/pam
setconf pamconf /system/etc/pam/

# local/snippets/post_start.custom
# Commands executed from post_startup.sh. Executed at the end of system startup whether slm is in use
# or not
#
# To allow resource managers to be run properly with and without security policies, command lines
# should be written in one of the following forms:
#
#     START(resmgr_t) resmgr DROPROOT(resmgr_uid)
#     STARTU(resmgr_t, resmgr_uid) resmgr
# Where resmgr_t is the security type name (arbitrary but usually the name of the resmgr with _t appended),
# and resmgr_uid is the id to use for both uid and gid.  DROPROOT is used only in cases where the
# resource manager supports a -U option for switching to non-root.
 io-usb-otg -d hcd-uhci -d hcd-ehci -d hcd-xhci

echo Process count:`pidin arg | wc -l`

exit 0
