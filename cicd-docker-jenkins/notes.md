# CICD for Docker Kubernetes Using Jenkins

Files in [vprofile-project/](vprofile-project/) come from [Class Repo kube-cicd branch](https://github.com/devopshydclub/vprofile-project/tree/kube-cicd)

## Flow

- CI setup in Jenkins w/ Sonarqube and Nexus
- Dockerhub account to store containers
- Store Dockerhub credentials in Jenkins
- Setup Dockerhub Engine in Jenkins
- Install Plugins in Jenkins
  - Docker-pipeline, Docker, Pipeline utility
- Create Kubernetes Cluster with Kops
- Install Helm in Kops VM
- Create Helm Charts
- Test Charts in Kubernetes Cluster in test namespace
- Add Kops VM as Jenkins Slave
- Create Pipeline Code
- Update Git repo with declarative files
- Create Jenkins job for pipeline
- Run & Test the job

## Helm

- Helm is like a package manager declarative Kubernetes object definition files
- Create a directory for Helm Charts, cd into it, and run `helm create <helm-project-name>`
- Also make another directory inside the Helm Charts directory and copy all the Kubernetes definition files into it
