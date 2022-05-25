# Containers

## What Are Containers

- Multiple "main" services running on a host can create problems because they all use the same underlying file structure
- Normal procedure is to **isolate** the main services/processes only running 1 main service per host (1 server runs a database process, 1 runs a web servicing, etc.)
- This gets expensive because then you need 1 server per service
- VMs are one form of isolation, but they simulate the underlying hardware of a machine and require full OS images and boots. They can be large and slow
- Containers are an abstraction of VMs. A container is essentially just a directory specific to a service that only the specified service can use, and inside the service there is a simulation of a full file structure
- In this way, you can have each main service run in its own container, have its own file system, and not require full OS images, full boots, and full simulations of underlying hardware
- Because containers are small, lightweight, and only contain what is strictly needed to run the intended service, you can easily create `archives/images` of containers to be run on any device anywhere

## Docker

Docker, a **container runtime environment**, is an open platform for managing containers.
- [Documentation](https://docs.docker.com/get-started/overview/)
- [Docker Hub](https://hub.docker.com/) stores official Docker images you can install to containers

## Hands-On Demo

- In [./ubuntu-vm](ubuntu-vm/), we do a hands-on demo to get familiar with Docker for the first time
- The [Vagrantfile](ubuntu-vm/Vagrantfile) sets up a Ubuntu VM and then provisions it by running all the [Docker Install Commands for Ubuntu](https://docs.docker.com/engine/install/ubuntu/) (also found locally in [dockerInstallOnUbuntu.txt](ubuntu-vm/dockerInstallOnUbuntu.txt))
- The commands we run for this demo are found in [docker_hands_on_commands.txt](ubuntu-vm/docker_hands_on_commands.txt)
