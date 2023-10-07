# syntax=docker/dockerfile:1
#
# \file     Dockerfile
# \brief    Template Dockerfile script that describes the container needed to
#           run the stable Ubuntu environment.
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

FROM ubuntu:22.04

RUN export TZ=Australia/Sydney \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install --no-install-recommends --assume-yes \
        apt-utils \
        lsb-release \
        language-pack-en-base \
        wget \
        ca-certificates \
        iproute2 \
        less \
        net-tools \
        vim \
        vim-pathogen \
        git \
        libboost-all-dev \
        libgtest-dev \
        libssl-dev \
        debianutils \
        openssh-client \
        sshpass \
        libswt-gtk-4-java \
        cmake-curses-gui \
        build-essential \
        llvm \
        clang \
        clang-tidy \
        python3 \
        python3-pip \
        valgrind \
        flex \
        bison \
        graphviz \
        lcov \
        doxygen \
        pkg-config \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && pip3 install clang-html==1.3.8

ENV NVIDIA_DRIVER_CAPABILITIES all

WORKDIR /root
