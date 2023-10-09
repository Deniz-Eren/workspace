# Development Environment

A containerized development environment setup is presented here based on Ubuntu
host operating system.


## About

We have chosen _Podman_ as our containerization tool for it's convenient
handling of rootless installations, which is perfect for development
environments. Furthermore, we have chosen _Podman-compose_ for the local
development environment use-case.

Once the setup steps have been fully completed, the normal individual developer
use-case is to start the container:

    cd <repository-home-path>/workspace/dev
    podman-compose up -d

Login to the container terminal:

    podman exec --interactive --tty --user root \
        --workdir /root/ workspace /bin/bash --login

From here you can use the terminal to interact with any command-line tools.

This development environment container can also be built directly using the
_Podman_ or _Docker_ commands after the setup steps have been fully completed to
create your development environment.

For example see [ci/scripts/setup-dev-env.sh](../ci/scripts/setup-dev-env.sh).


## Development Environment Setup

### Prerequisites

Install needed packages:

    sudo apt install curl

Install Docker and Docker-compose:

    sudo apt install docker-compose

To run Docker without sudo:

    sudo usermod -aG docker $USER

Install Podman and
[Podman-compose](https://github.com/containers/podman-compose) (version 1.0.4 or
greater is required):

    sudo apt install podman python3 python3-pip
    pip3 install podman-compose

Next Install Docker GPU Support. Installation of
[Docker NVIDIA](https://nvidia.github.io/nvidia-container-runtime/) is as
follows:

    curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
      sudo apt-key add -
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
    sudo apt-get update

Then install:

    sudo apt-get install nvidia-container-runtime

When using rootless Podman edit the file
_/etc/nvidia-container-runtime/config.toml_ and make sure to define:

    no-cgroups = false

Restart the Docker daemon for changes to take effect:

    sudo systemctl daemon-reload; sudo systemctl restart docker

Install the following:

    sudo apt install nvidia-docker2

Restart Docker:

    sudo systemctl daemon-reload; sudo systemctl restart docker

Test to see everything is working with raw docker command:

    docker run --rm --runtime=nvidia --gpus all \
        nvcr.io/nvidia/cuda:12.1.1-devel-ubuntu22.04 nvidia-smi

### Step 1

Modify the symbolic link _dev/.Dockerfile_ to point to the desired _Dockerfile_
or leave it as the default _dev/ubuntu-stable/Dockerfile_. You can also remove
this symbolic link and replace it with a copy of a customised Dockerfile if you
need to make local customisation, such as those necessary for Step 7.

Similarly modify the symbolic link _dev/.setup-profile.sh_ to point to the
desired setup-profile.sh script or leave it as the default
_dev/ubuntu-stable/setup-profile.sh_.

Make sure Git ignores the changes you have made to these symbolic links:

    git update-index --assume-unchanged .Dockerfile .setup-profile.sh

For QNX 7.1 Development Environment setup ensure you direct these symbolic links
to point to (or replace them with copied of) _ubuntu-qnx710/Dockerfile_ and
_ubuntu-qnx710/setup-profile.sh_ respectively.

### Step 2

Start the development environment with default Ubuntu base image:

    cd <repository-home-path>/workspace/dev
    podman-compose up -d

### Step 3

Install your personal/private licensed software inside your _workspace_
container. See further instructions for specific cases:

- [QNX 7.1 Development Environment](ubuntu-qnx710/README.md).

If you have not installed any software in this step, then you can chose to skip
the following Steps 4, 5, 6 and 7.

### Step 4 (Optional)

Once your personal/private licensed software are installed and ready, stop the
_podman-compose_ container instance:

    cd <repository-home-path>/workspace/dev
    podman-compose stop

IMPORTANT! Be sure NOT to use _down_ with podman-compose, just use _stop_ as
shown above. Using _down_ will delete the created container named _workspace_.

Next commit the container _workspace_ to your local Podman image registry:

    podman commit workspace <username>/workspace:1.0.0

Where _<username>_ is either your repository user-name if you intend use a
secure remote private and personal repository as per _Step 6_ below, or just
something else unique you chose to use.

### Step 5 (Optional)

Our recommended container manager for our development environment is Podman,
however for the [CI Jenkins pipelines](../ci/jenkins) we find it convenient to
use Docker. For this reason we need to clone our dev image to the local Docker
registry also as follows.

Save the created Podman container _workspace_ to a tar file:

    podman save localhost/<username>/workspace:1.0.0 | gzip > workspace.tar.gz

Now import the saved image tar file to docker and retag without the _localhost_
prefix:

    docker load < workspace.tar.gz
    docker tag localhost/<username>/workspace:1.0.0 <username>/workspace:1.0.0

You can now delete the temporary tar file.

### Step 6 (Optional)

If you chose to backup your image to a secure remote private and personal
repository, then these remaining steps apply. Ensure this is your own personal
repository and nobody else can access it, since this image now contains your
personal development environment and installed software. Otherwise you can skip
this step and go to the next step.

Login to your remote repository and push your image:

    docker login -u <username>
    docker push <username>/workspace:1.0.0

Be sure to clean up all the temporary tags and images created above during this
process for both your Docker and Podman local image repository.

### Step 7 (Optional)

Instead of the symbolic link _dev/.Dockerfile_, make a copy of your desired
Dockerfile to location _dev/.Dockerfile_. Then edit and change the FROM repo to
be either your local committed image name or your private remote repo.

For local committed image:

    #FROM ubuntu:##.##
    FROM localhost/<username>/workspace:1.0.0

For remote private repo:

    #FROM ubuntu:##.##
    FROM <repository-url>/<username>/workspace

Now you will have a disposable container setup where you can perform _down_ and
_up_ whenever you like to throw away your _workspace_ container and re-create
it from committed base image; this gives great flexibility.

