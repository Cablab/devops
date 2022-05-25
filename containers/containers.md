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

## Docker Commands

- `docker run <image-name>` runs the container. If it doesn't exist locally, it will attempt to download the image
- `docker images` shows images on your local machine
- `docker ps` will show running images, and adding the `-a` flag will show all images
- `docker inspect <container name>` to see info (like IP address) of the specified container
- `docker stop <container name>` to stop any actively running containers
- `docker rm <container name>` to fully remove a container
- `docmer rmi <image name>` to fully remove an image

### Complex Docker Image Setup

`docker run --name <host name> -d -p <receive port>:<forward port> <image name>`

- `--name <host name>` specifies what you want the container to be called
- `-d` tells the container to run in the background
- `-p <host/receive port>:<forward port>` allows you to forward traffic to the container. If the underlying system receives a request on port `<host/receive port>`, it will forward it to the container on `<forward port>`
  - For instance, if you set up a container to run a web service with `-p 9080:80`, the host (underlying system where containers are running) has IP `172.20.10.12`, and the container got IP `192.168.0.2`, then you could access the web service (which would normally be `192.168.0.2:80`) from the host system by going to `172.20.10.12:9080`. The host will take requests to its IP on port 9080 and forward it to the container's IP on port 80 since that was the mapping that was given
- `<image name>` is the name of the Docker image to install. If it doesn't exist locally, it will attempt to download and install from Docker Hub

### Creating Your Own Image

- Create a directory where you will store images
- In that directory, create a `Dockerfile` that is structured to create the container you need. This will be built off an existing base image, but will include your own commands to run to make it unique to what you need
- Run `docker build -t <image-name> <path-to-save-image>` to run the `Dockerfile`, give it an image name, and save the image in the specified path
- You should now see the image when running `docker images`
