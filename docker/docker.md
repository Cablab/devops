# Docker

[Docker Docs](https://docs.docker.com/)

## Introduction

- Containers are services running in a directory
- They stay isolated from other services/containers, but they share the machine's OS and don't all need their own OS
- Necessary binaries and libraries are included in the container so there's no interference
- Each container is given an IP address for interconnection

## Setup

- Follow installation steps for your OS from [Docker Desktop Installation](https://docs.docker.com/get-docker/) or [Docker Engine Installation](https://docs.docker.com/engine/install/), whichever you need
- If you need to fine tune Docker, you can check the [Post-Install Steps](https://docs.docker.com/engine/install/linux-postinstall/) to see what settings are possible
  - By default, only the root user can run docker commands. If you want other users to be able to run docker cli commands, you have to add them into the `docker` group that got created with `usermod -aG docker <username>`

## Docker Hub & Images

- Registry for Docker Images - [Docker Hub](https://hub.docker.com/)
- Dockers run entirely from an image
- Images are called Repositories in Registries
- An image is like a stopped Container. It has everything in it, all services, dependencies, etc. needed to run the container. An image becomes a container when running on Docker Engine
- Containers are a thin read/write layer, but everything you interact with is actually the image

## Docker Logs

- You can see a container's logs with `docker logs <container-name>`
- If you do `docker inspect <image-name>`, you can see a lot of info about the image
  - The `Entrypoint` object is what runs when you `docker run <image-name>`
  - The `Cmd` object are the commands that run after the container is up
- The entrypoint script and startup commands don't show output when you create the image in detached mode (`-d`), but you can see them with `docker logs <container>`

## Docker Volumes

- Containers are disposable and volatile. You don't make changes to a container itself, you make changes to the image and then make a new/updated image so that all containers from that image get the updated info
- However, some containers (like MySQL containers) need persistent data storage that isn't volatile. This is where Docker Volumes and Bind Mounts come in. They're both similar, but volumes are managed by Docker
  - **Volume**: Stored in `/var/lib/docker/volumes` on the host machine, can be attached to and accessed from the container
  - **Bind Mounts**: A directory anywhere on the host machine, can be mapped to a container directory so the container can access a localhost directory
- Check what directory a container can use as a volume with `docker inspect <image>:<tag>` and looking for the `ContainerConfig.Volumes` object
- Create a bind mount at runtime with `docker run -v <path-to-local-directory>:<image-volume-path>`
- Create a volume mount at runtime with `docker run -v <volume-name>:<image-volume:path>`
  - Requires a volume to have been created with `docker volume create <volume-name>`
- You can see if there are any Volumes or Bind Mounts on a running container by inspecting the container and looking at `HostConfig.Binds` or `Mounts`

### Bind Mount vs Volumes Differences

- Bind Mounts are mostly used for injecting data into a container. For instance, a developer writing new code or creating new files can use a bind mount to make them accessible to a running container
- For data persistence/preservation, Volumes are a better choice

## Building Docker Images

- Create a `Dockerfile`
- Run `docker build -t <image-name> <path-to-Dockerilfe>`

### Dockerfile Structure

- `FROM` - Base image
- `LABELS` - adds metadata to an image in key-value pairs
- `RUN` - execute commands in a new layer and commit the results
- `ADD/COPY` - adds files and folders into image
- `CMD` - runs binaries/commands on docker run
- `ENTRYPOINT` - similar to CMD, but has higher priority. If both exist, you can reference `CMD` as an argument inside of `ENTRYPOINT`
- `VOLUME` - mount points where users can mount volumes or bind mounts
- `EXPOSE` - which ports the process will listen on
- `ENV` - sets environment variables
- `USER` - specifies which user will be running the root container process
- `WORKDIR` - specifies which directory to execute from
- `ARG` - define variables that the user can pass at build-time
- `ONBUILD` - run specified commands whenever this image is used as the base image in a different image

### CMD vs ENTRYPOINT

- `CMD` specifies a command and arguments to run
  - So `CMD ["echo", "hello"]` by itself will run `echo hello` in the shell when the image is executed
- `ENTRYPOINT` specifies a command to run. If there are no arguments given in `CMD`, then the user has to specify the arguments.
  - So `ENTRYPOINT ["echo"]` by itself will just run `echo` in the shell. However, the user can give arguments. If the user ran `docker run <image> hello`, the `hello` would get passed as an argument to `ENTRYPOINT` and then `echo hello` would get run
- If both `ENTRYPOINT` and `CMD` are present, `ENTRYPOINT` specifies the command and `CMD` gives the arguments.
  - In this case, `CMD` gives default arguments. They can be overridden by the user passing their own arguments during `docker run`

###  Mutli-Stage Dockerfile

- Say that you need to build an artifact to use in an image you're trying to create. **Do not** build the artifact inside of the image you're making since that'll add to the image size and you want to keep it as small as possible
- Instead, in the Dockerfile where you're creating your image, you can use two separate images, build the artifact in one, and copy it into the other. Here's what that looks like:

```Dockerfile
# Image where you build the artifact
FROM <image> AS BUILD_IMAGE

# Install dependencies
RUN apt update && apt install <dependencies> -y
# Fetch code
RUN git clone -b <branch> <github-repo>
# Build
RUN cd <project-directory> && <build command>

# ============== VISUAL SEPARATION ===================

# Image you're actually going to make/use
FROM <image>

# Copy the build artifact into the Image you're actually using
COPY --from=BUILD_IMAGE <path-to-build-artifact> <destination-path>

# Do the rest of the Dockerfile as normal
```

## Docker Compose

[Docker Compose File Specification](https://docs.docker.com/compose/compose-file/)

[Docker Compose Getting Started Project](https://docs.docker.com/compose/gettingstarted/)

- Docker compose is a tool to run multiple containers together
- For instance, in a project that required multiple containers (like a web app with server, database, cached, etc.), it can manage all the different containers and coordinate their ability to communicate
- Everything that you can run/setup/create with docker (volumes, images, port mappings, bind mounts, etc.) can be declared in the `docker-compose.yml` file and setup automatically

## Docker Commands

[Docker CLI Docs](https://docs.docker.com/engine/reference/commandline/cli/)

- `docker images` - list all images
- `docker ps` - list running containers
- `docker ps -a` - list all containers
- `docker run <image-name>` - creates and runs the specified container
  - See [Docker Run Options](#docker-run-options) below for options when running
- `docker start|stop|restart|rm <container-name|container-id>` - operations on docker containers
- `docker rmi` - remove docker images
- `docker inspect` - list details about container/image
- `docker pull <image>` - downloads the specified image from Docker Hub
- `docker volume` - manage docker volumes

### Docker Run Options

- `--name <name>` will give a name to the container that starts up
- `-d <image-name>` will start and run the container in the background
- `-p <host-port>:<container-forward-port>` will expose an external port to route traffic from the localhost to the container. Otherwise, containers are not publicly accessible
  - This is called **Port Mapping** or **Port Forwarding**. The host port needs to be a free port on the device itself. The forward port needs to be the port that the service in the container is expecting to listen on
- `-P` will create the port mapping automatically with an available host port
- `docker exec <container-name|id> <command>` - executes commands on containers
- You can attach to the docker process (kinda like SSHing into it, but you can't SSH because it's just a running process) by doing `docker exec -it <container-name> /bin/bash`
  - This is opening a shell in the container and `-it` is making it interactive and opening tty to attach to the process
- `-e <env-name>=<env-value>` lets you set ENVs when running a container
- `-v <path-to-local-directory>:<image-volume-path>` binds a local directory to a container's volume directory

## Docker Local File Directory

- Docker images and containers are found at `/var/lib/docker` be default
- Running containers will be in `/containers`, and there will be a directory for each container you have
- Locally stored images will be in `/image`
