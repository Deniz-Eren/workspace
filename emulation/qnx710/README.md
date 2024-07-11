# QNX Emulation

Before you can start the emulation, you must make sure you have built the
QNXTEST QNX image; see section [Test Platform](./image/). The emulator VM boots
that image up.

To start the QEmu VM with CAN-bus hardware emulation, first ensure the needed
host Linux modules are running:

    cd workspace/emulation/qnx710
    sudo ./setuphost.sh

This will startup some Linux modules; one of which is KVM. For KVM to work you
must have hardware virtualisation settings enabled in you BIOS.

Next ensure your host will accept X session from the Docker container using the
server access control command:

    xhost +

Now we can startup the emulation using podman compose:

    cd workspace/emulation/qnx710
    podman compose up -d

QEmu window should appear.

You can also login to the QNXTEST VM using ssh:

    ssh -p6022 <user>@localhost

The credentials are not intended to be secure. The available _user_ credentials
are root, qnxuser, user1, user2, ..., user6 and the passwords are the same as
the associated user name.
