# Notes

DevOps covers **Continuous Integration** and **Continuous Delivery** (**CI/CD**)

## Continuous Integration

Code is automatically built and tested each time a commit happens. This makes it so that errors are detected earlier and can be fixed pretty quickly instead of waiting until the end of the development sprint/cycle to detect all errors. The goal is to detect errors early so they don't multiply.

**Artifact**: AKA Build Artifact. A built and tested version of the codebase that could be put into a live environment. Can be in various formats depending on the OS, like .jar, .zip, .rar, .msi, .exe, etc.

## Continuous Delivery

Automate various manual steps in deployment:
  - Server provisioning
  - Dependency upgrades
  - Configuration changes
  - Network changes
  - Artifact deployment

## Tools and Technology Prereqs

[Course GitHub Repo with Resources](https://github.com/devopshydclub/vprofile-project/tree/master)

### Software Installed for Course

**Oracle VM VirtualBox**
- `choco install virtualbox`

**Git Bash**
- Already installed

**Vagrant**
- `choco install vagrant`

**Chocolatey**
- Already installed, upgraded with `choco upgrade chocolatey`

**JDK8**
- `choco install jdk8`

**Maven**
- `choco install maven`

**AWS CLI**
- `choco install awscli`

**Domain Purchase**

**Docker Hub**
- Host Docker images

**SonarCloud**

### AWS Account Setup

- Free tier account
- IAM with MFA
- Billing Alarm
- Certificate Setup
