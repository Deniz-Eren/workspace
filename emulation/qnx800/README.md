# QNX Emulation

Before you can start the emulation, you must make sure you have built the
QNXTEST QNX image; see section [Test Platform](./image/). The emulator VM boots
that image up.

To start the QEmu VM with CAN-bus hardware emulation, first ensure the needed
host Linux modules are running:

    cd workspace/emulation/qnx800
    sudo ../scripts/setuphost.sh

This will startup some Linux modules; one of which is KVM. For KVM to work you
must have hardware virtualisation settings enabled in you BIOS.

Next ensure your host will accept X session from the Docker container using the
server access control command:

    xhost +

Now we can startup the emulation using podman compose:

    cd workspace/emulation/qnx800
    podman compose up -d

QEmu window should appear.

You can also login to the QNXTEST VM using ssh:

    ssh -p6022 root@localhost

The credentials are not intended to be secure. The available _user_ credential
is only root user, with the password same as the user name.
