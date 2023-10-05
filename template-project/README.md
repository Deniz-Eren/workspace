# Template Project

To use this [workspace](https://github.com/Deniz-Eren/workspace) system in your
project, first you must ensure you add this project as a Git submodule to the
root of your project. Otherwise the links referenced within this project will NOT
WORK correctly.

To do this:

    cd <your-project-repo-name>
    git submodule add https://github.com/Deniz-Eren/workspace

To allow this template project to compile we have created some symbolic links
you will not need in your project. Instead of a git submodule for workspace we
point a symbolic link to the project's root path (workspace -> ..) and instead of
a LICENSE file we point to the project's root LICENSE file
(LICENSE -> ../LICENSE).

Throughout these notes and within the template scripts provided, such as the
_CMakeLists.txt_ or _Jenkinsfile_ or folders named "template-project", your
project repo name is referenced as "<your-project-repo-name>" or
"template-project"; you will need to change that to your project name within your
specific project.

## Build

To build this sample template project, generate an installer package tar file,
and then run the tests in your emulation environment follow these steps.

### Linux

Start your development environment and login to your dev container terminal
(see [Development](../dev) section):

    podman exec --interactive --tty --user root \
        --workdir /root/ workspace /bin/bash --login

Compile and build your code:

    cd workspace/template-project
    mkdir build ; cd build
    cmake -DCMAKE_BUILD_TYPE=Release ..
    cpack

Notice you have your installer files _template-project-1.0.0-Linux.tar.gz_ and
_template-project-1.0.0-Linux-dev.tar.gz_. These are designed to untar into
your target system prefix path to install correctly.


### QNX

Start your QNX development environment and login to your dev container terminal
(see [Development](../dev) section).

Next start the target emulation environment next (see
[Emulation](../emulation/qnx710) section).

Login to the container terminal:

    podman exec --interactive --tty --user root \
        --workdir /root/ workspace /bin/bash --login

Compile and build your code:

    cd workspace/template-project
    mkdir build ; cd build
    cmake -DCMAKE_BUILD_TYPE=Release ..
    cpack

Notice you have your installer files _template-project-1.0.0-qnx710.tar.gz_ and
_template-project-1.0.0-qnx710-dev.tar.gz_. These are designed to untar into
your target system prefix path to install correctly.

## Testing

After building your project using the steps above, the tests can be run from your
dev environment. If built for cross-compiling and the associated emulation
environment is running, the system automatically runs the command on your
emulation environment from the linux host using ssh. It also copies all generated
files back to your host. It does this by generating a script
_./tests/example_test_case/ssh-example-test-case.sh_:

    ctest

Here is an example output:

    # ctest
    Test project /root/workspace/template-project/build
        Start 1: ssh-example-test-case
    1/1 Test #1: ssh-example-test-case ............   Passed    1.49 sec

    100% tests passed, 0 tests failed out of 1

    Total Test time (real) =   1.49 sec

To generate test coverage HTML outputs, build in Coverage mode as follows:

    cd workspace/template-project
    mkdir build ; cd build
    cmake -DCMAKE_BUILD_TYPE=Coverage ..
    cpack

You will notice coverage installer tar file get created
_template-project-1.0.0-qnx710-cov.tar.gz_ which can be used to install
manually onto a target system to gather coverage files. Or you can simply run
ctest to run the current project onto the target emulation environment. Then
run "make" again to produce the test-coverage HTML:

    make

From your host Linux environment you can run firefox to view the HTML files:

    firefox template-project/build/tests/test-coverage/index.html

On Linux, the default compiler is GNU gcc thus the coverage uses lcov, however if
you wish to use LLVM with it's coverage tool then you can compile and run the
coverage reports as follows:

    cmake \
        -DCMAKE_C_COMPILER=/usr/bin/clang \
        -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
        -DCMAKE_LINKER=/usr/bin/llvm-link \
        -DCMAKE_BUILD_TYPE=Coverage ..

    make

Again from your host Linux environemnt you can run firefox the same as above.

## Jenkins

Seperate Jenkins files have been provided optimized for Linux and QNX use-cases.
