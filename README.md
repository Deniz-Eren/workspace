# Workspace

Development Environment, Emulation and Continuous Development toolchain project.

Currently we have tested our setup on Ubuntu 22.04 and QNX version 7.1.

To use this development setup within your project you must ensure you follow the
instructions specified in [Template Project](template-project/) folder.

For details about the various toolchain setup sections check the following:

See ["Development Environment"](dev/) ; a containerized setup is presented
based on the Ubuntu host operating system.

See ["Emulation"](emulation); QEmu Virtual Machine with hardware emulation
support such as CAN-bus, together with target integration to QNX Momentics IDE.

See ["Local Jenkins in Docker Compose Setup"](ci/jenkins/); a quick,
easy-to-setup Jenkins environment, intended to be run on the developer's local
computer to monitor progress; i.e. view test results, code coverage, etc, is
presented here.

