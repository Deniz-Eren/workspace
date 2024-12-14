# QNX 8.0 Development Environment

## Installation

This section describes how to install the QNX 8.0 Development Environment as
needed by Step 3 of setting up _workspace_ Development container.

Login to the _workspace_ development environment container and install your
personal/private licensed _QNX Software Center_ program:

    podman exec --interactive --tty --user root \
        --workdir /root/ workspace /bin/bash --login

We have tested this process with:

    QNX Software Center 2.0.3 Build 202408131717 - Linux Hosts

After downloading the installer file _qnx-setup-2.0.3-202408131717-linux.run_
from your host machine, it will appear in your container in the following path
(since the _userhome_ mount in the development container is your home directory.
To run the installer simply:

    ./userhome/Downloads/qnx-setup-2.0.3-202408131717-linux.run

It will start as normal, but keep in mind this is installing inside the
development container:

    [press q to scroll to the bottom of this agreement]
    DEVELOPMENT LICENSE AGREEMENT
    Please type y to accept, n otherwise:

Accept all default installation paths:

    Specify installation path (default: /root/qnx):

Once started, the pop with _Log in to myQNX <@qnx-dev>_ will appear. Here login
and install your QNX 8.0 system & Momentics.

When prompted allow the QNX 8.0 system to install to the default location of
_/root/qnx800_ within the development container. The
[setup profile script](setup-profile.sh) assumes this path.

Additionally install Google Unit Test using QNX Software Center.

## Developing in Momentics

From within Momentics you can connect to the target QEmu hardware emulation
environment over QConn (port 8000). To start the emulator check documentation
[Emulation](../emulation/).

## Debugging Core Dumps (GDB Usage)

One can use GDB within the Ubuntu development environment shell, simply running:

    $QNX_HOST/usr/bin/ntox86_64-gdb

If you have a core dump file (for example _dev-can-linux.core_):

    $QNX_HOST/usr/bin/ntox86_64-gdb dev-can-linux dev-can-linux.core

Note our test image is configured to dump the core files in the path
_/data/var/dumper/_ of the QNX target test platform.
