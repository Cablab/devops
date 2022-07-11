# Maven

Maven is a build tool for Java to automate the build process

## Build Process

- Developer writes source code
- Compile source code
- Test source code
- Package into target artifact (executable, archive, etc.)

## Maven Phases

- [Maven Intro to Build Lifecycle](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html)
- Validate, Compile, Test, Package, Integration Test, Verify, Install, Deploy

## Installation

- Make sure to `apt install jdk<version>`
  - You can search what's available with `apt search jdk`
- Install maven with `apt install maven`
- You can install a certain version of Maven by looking up version history, downloading an old version package, unzipping it onto your machine, and either installing or just calling the binary path

## Running Maven / Commands

- Run a specific phase with `mvn <phase>`. It'll run all phases up to, and including, the specified one
- Maven creates a `./target` directory with output from the execution of `mvn`
- `mvn clean` removes all output created from previous phase
- You can pair clean with other commands, so `mvn clean install` will clean previous output and then run through intsall
