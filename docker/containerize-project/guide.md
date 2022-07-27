# Containerize Project Guide

- Source code available at [Class Repo](https://github.com/devopshydclub/vprofile-project)
  - Using branch `docker`
  - Branch `vp-docker` is the finalized version

## Containers

- We'll use default images except for the ones where we need to customize it
- See [dockerfiles/](dockerfiles/) for custom Dockerfiles to create images we need
  - Sub-directories also include local files as needed
  - The [dockerfiles/app/](dockerfiles/app/) directory also requires the project build artifact from running `mvn install` in the root project directory to be placed in a `./target` directory
    - Make sure that the `src/main/resources/application/properties` match what has been set in the various Dockerfiles

## Building Images

- Run `docker build -t <image-name>:<tags> .` in each directory where there is a Dockerfile
- Pull the other necessary images (`memcached` and `rabbitmq`) with `docker pull <image>`

## Running Containerized Project

- With the [dockerfiles/docker-compose.yml](dockerfiles/docker-compose.yml) file setup correctly, run `docker compose up -d` to bring everything up
