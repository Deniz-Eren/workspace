#!/bin/bash
#
# \file     setup-dev-env.sh
# \brief    Bash script for setup of dev container.
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
optd=/opt/workspace/dev/ubuntu-stable/Dockerfile

while getopts d: opt; do
    case ${opt} in
    d )
        optd=$OPTARG
        ;;
    \?)
        echo "Usage: $(basename $0) [options]"
        echo "  -d full path to Dockerfile to use for dev-env container"
        echo ""
        exit
        ;;
    esac
done

docker build \
    -f $optd \
    -t localhost/workspace-dev .

docker run -d --name=dev-env \
    --network host \
    localhost/workspace-dev tail -f /dev/null

# Make a copy of the workspace Git repository to dev-env container
docker cp /opt/workspace dev-env:/root/
