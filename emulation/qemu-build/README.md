# QEmu Build

Before you can start the emulation, you must make sure you have built the
QNXTEST QNX image; see section [Test Platform](../qnx710/image/). The emulator
VM boots that image up.

This section walks you through how to run the PCI MSI capability CAN-bus device
version of QEmu. This contribution has not yet been merged to the main QEmu
repository, so it needs to be built.

To start the QEmu VM with CAN-bus hardware emulation, first ensure the needed
host Linux modules and virtual socket-CAN ports are running and available:

    cd workspace/emulation/qemu-build
    sudo ../scripts/setuphost.sh

To build PCI MSI capability CAN-bus device version of QEmu:

    git clone -b feature/can-sja100-pci-msi-support git@github.com:Deniz-Eren/qemu.git

For QNX 8.0 run container:

    xhost +
    podman compose --file ./docker-compose-qnx800.yml up -d

Wait till QEmu is built and run; QEmu window will pop-up when ready.

Connect to the session:

    ssh -p6022 root@localhost

Check that the PCI MSI capability enabled 13fe:00d7 device is present:

    pci-tool -vv

You should see:

    B000:D05:F00 @ idx 7
            vid/did: 13fe/00d7
                    <vendor id - unknown>, <device id - unknown>
            class/subclass/reg: 0c/09/00
                    CANbus Serial Bus Controller
            revid: 0
            cmd/status registers: 103/10
            Capabilities list (2):
                         05 (MSI) --> 10 (PCIe)
            Address Space list - 1 assigned
                [0] MEM, addr=febf2000, size=800, align: 800, attr: 32bit CONTIG ENABLED
            Interrupt list - 0 assigned
            hdrType: 0
                    ssvid: 13fe  ?
                    ssid:  00d7

To test PCI MSI-X capability using hyperthetical device demo0x11 edit
docker-compose.yml file and change pcm26d2ca_pci to demo0x11_pci.
