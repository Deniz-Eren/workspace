# Test Platform

To build the QNXTEST image, first ensure you have setup your
[Development](../../../dev/) environment.

Then login to your development environment:

    podman exec --interactive --tty --user root \
        --workdir /root workspace /bin/bash --login

Note, make sure you have setup your development environment for the QNX 7.1
toolchain.

Next navigate to the test image folder and run:

    cd workspace/emulation/qnx710/image
    ./builddisk.sh

The image file _output/disk-raw_ should be created.
