# syntax=docker/dockerfile:1
#
# \file     jenkins-ssh-agent.Dockerfile
# \brief    Dockerfile script that describes the Jenkins SHH agent container
#           needed to run the Jenkins CI environment.
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

FROM jenkins/ssh-agent:jdk11

RUN export TZ=Australia/Sydney \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install --no-install-recommends --assume-yes \
        apt-utils \
        lsb-release \
        wget \
        ca-certificates \
        iproute2 \
        less \
        net-tools \
        docker.io \
        docker-compose \
    && apt-get autoremove -y \
    && apt-get autoclean -y
