# CI/CD in Jenkins

**CI/CD**: Continuous Integration / Continuous Delivery

## Installation

- Follow [Installing Jenkins](https://www.jenkins.io/doc/book/installing/) docs to install on desired platform
  - Jenkins also requires OpenJDK, so `apt update; apt install openjdk<version> -y; apt install maven -y` before the listed Jenkins steps too 
- You can access jenkins from the server where it's running over HTTP:8080, so if you're running it in an EC2 instance, make sure you allow TCP:8080 access to yourself

## First Job / UI Exploration

- You can create a `Freestyle Job` to configure all the Jenkins steps in the Web UI. This is useful for exploring what Jenkins can do, but you don't want to actually configure anything like this for working code
- In a Jenkins Project, you can click on `Workspace` to see what files are created during the build
- `Configure` lets you change settings for the Project
  - Adding a `Post-build step` can let you do things like archive artifacts, send notifications, etc.

## Tools in Jenkins

- If you want to have/use a tool in Jenkins, you need to have the tool installed on the Jenkins server
- You can do this through package management on the host itself
- You can also go to the Jenkins homepage and click `Manage Jenkins` to configure the Jenkins server, including adding tools and plugins, through the web UI
- If you have multiple versions of a tool installed (whether on OS or through Jenkins), you can choose which version to use when configuring individual Projects

## Plugins, Versioning, and More

**Versioning**

- You can do a rudimentary version of version control for artifacts in Jenkins by adding a build step at the end and manually adding shell script commands to save each version of a built artifact
  - Configure the project and go down to the `Build` section. Choose `Add build step` > `Execute shell`
  - The following is an example of commands you could use to store versions of an artifact:
  - `mkdir -p versions` - creates (if it doesn't exist) a directory in the Project Workspace
  - `cp <path/to/artifact> versions/<artifact-name>$BUILD_ID` - copies artifact with unique ID
  - In the example, `$BUILD_ID` is a built-in [Jenkins environment variable](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/#using-environment-variables) that you can use
- You can also set user-defined parameters for use in `Execute shell` build steps. To set these, go to `Configure` Project and check the `This project is parameterized` box near the top.
  - This will allow you to define user parameters
  - If these exist, `Build` gets replaced with `Build with Parameters` in the Project
  - When you `Build with Parameters`, you can enter the param value at that time
  - This isn't ideal because we want these automated and not requiring manual input

**Plugins**

- On the Jenkins homepage, do `Manage Jenkins` > `Manage Plugins` to access available plugins
- If you have a plugin hosted internally somewhere that isn't in the public internet, you can use the `Advanced` tab to enter credentials and proxy info to still go get the plugin. You may need to restart the jenkins service afterward though
  - Use `<FQDN>:8080/restart` or probably also `systemctl restart jenkins`

## Flow of CI Pipeline with Tools

- Developer writes code and pushes to a VCS repository
- Jenkins detects change in git repository and fetches the code changes
- Jenkins starts a build job
  - Testing can be conducted on code
  - Code analysis can be conducted
  - Quality gates can be set to fail the build if analysis isn't satisfactory
- The build artifact gets distributed and stored where it needs to go

## CI Pipeline Example with Jenkins, Nexus, Sonarqube, Maven, Java

Bash scripts for setting up the EC2 instances are found in [class repo vprofile-project/ci-jenkins](https://github.com/devopshydclub/vprofile-project/tree/ci-jenkins)

### Server (EC2) Setup

**Jenkins server setup**

- Create Ubuntu18 EC2 instance and put script in user data for provisioning
- Use t2.small instead of t2.micro so the server doesn't crash under multiple builds
- Allow inbound TCP:8080 and TCP:80 from all traffic so Nexus and Sonarqube can easily connect
  - In production, you'd want to make sure only the Nexus and Sonarqube servers have access, but for ease we allow all here
- Verify with `systemctl status jenkins` and going to `IP:8080`
- Run default setup to create user for access

**Nexus server setup**

- Create CentOS 7 EC2 instance and put script in user data for provisioning
- Use t2.medium
- Allow inbound TCP:8081 from all traffic for easy connection
  - In production, you'd want to make sure only the desired servers have access, but for ease we allow all here
- Verify with `systemctl status nexus` and going to `IP:8081` to see if it works
- Grab admin password off server and sign in, enable anonymous access

**Sonarqube setup**

- Create Ubuntu18 EC2 instance and put script in user data for provsioning
- Use t2.medium
- Allow inbound TCP:80 and TCP:9000 from all traffic for easy connection
  - In production, you'd want to make sure only the desired servers have access, but for ease we allow all here
- Verify with `systemctl status sonarqube` and going to `IP:80`
- Log in with `admin admin` default credentials

**Jenkins plugins**

- Install the following: Nexus Artifact Uploader, SonarQube Scanner, Git (installed by default), Pipeline Maven Integration, Pipeline Utility Steps, BuildTimestamp

### Pipeline as (a) Code (PaaC)

- Automate pipeline setup with `Jenkinsfile`
- `Jenkinsfile` defines stages in the CI/CD pipeline
- Example structure (see full example file in [JenkinsfileDemo.txt](example-pipelines/JenkinsfileDemo.txt)):

```txt
pipeline{
    agent any
    stages {
        stage('Build') {
            steps {
                //
            }
        }
        stage('Test') {
            steps {
                //
            }
        }
        stage('Deploy') {
            steps {
                //
            }
        }
    }
}
```

**Hierarchy**:

- pipeline: outer object
  - agent: where the pipeline will run
  - tools: mention which tools will be needed
  - environment: environment variables
  - stages: steps executed in job
    - steps: exactly command to run
    - post: things to do after the step (post-run success or failure)

**Creating in Jenkins**

- Type up the pipeline and save it in a file how you like it
- Go to Jenkins web UI and `+ New Item`, choose `Pipeline`
- You can copy and pase the text of your `Jenkinsfile` into the `Pipeline script` at the bottom
- Or, you can change it to `Pipeline script from SCM`, find target your repo & branch, and then have it use the `Jenkinsfile` you have in your remote repository

### Code Analysis

#### Setup

- With SonarQube Scanner plugin installed, go to Jenkins > `Manage Jenkins` > `Global Tool Configuration`, and find `SonarQube Scanner`
- Add a SonarQube Scanner, give it a name, and remember the name so we can use it later in a pipeline
- To integrate SonarQube server with Jenkins server, do `Manage Jenkins` > `Configure System` > scroll down to find `SonarQube servers`
- Check `Environment Variables`
- `Add SonarQube` and give it a name
  - server URL is private IP of sonarqube EC2 instance since they're in the same network. If they weren't, you'd use the public IP of the SonarQube server you're connecting to
  - go to SonarQube website > Account > My Account > Security and create a token for Jenkins (choose a name like `jenkins`)
  - go back to Jenkins and add a `Server authentication token` in the `SonarQube servers` section
    - Choose `Secret text` and use the token you generated for the `Secret` field
    - Choose an ID and description
    - If it won't let you add one, save the Jenkins system config and then go back in and do it

#### Demo

- For pipeline including `Checkstyle Analysis`, see [PAAC_Checkstyle.txt](example-pipelines/PAAC_Checkstyle.txt)
- Once you run a pipeline with Solar Analysis integrated, the Project page should have links to `SonarQube` and also show some quality gates
- You can also go to the SonarQube web ui and hit the `Projects` tab to see the reports
- In the `Projects` page, click on the project's name to see its specific dashboard
- You can see which quality gates the project used by clicking the `Project Settings` dropdown and looking at `Quality Gates`. There is a default one

**Creating Custom Quality Gates**

- Example of Pipeline including custom Quality Gate: see [PAAC_Sonar_QualityGates.txt](example-pipelines/PAAC_Sonar_QualityGates.txt)
- To create a custom Quality Gate in SonarQube, go to `Quality Gates` tab on navbar and `Create`
- Once it's created and configured how you want, go back to the Project's page in SonarQube, click the `Project Settings` dropdown and go to `Quality Gates`, then choose the one you created
- Create a webhook (`Project Settings` dropdown > `Webhooks`) to send the Quality Gate data to Jenkins
  - URL is `<jenkins-server-IP>:8080/sonarqube-webhook`

### Storing Software Packages and Artifacts (with Nexus)

- There are lots of repositories for storing packages/artifacts/binaries. Some examples:
  - Maven - maven dependencies
  - apt - debian packages
  - yum - RedHat packages
  - nuget - .NET packages
  - NPM - JavaScript/Node packages
  - Docker - Docker images
- Nexus - runs on Java, stores artifacts, can act as a package manager

**Setup**

- Go to Nexus website, hit the `Settings Cog` in the navbar, go to `Repositories`, and `Create repository`
- Choose a `maven2 (hosted)` type, give it a name, and use all other default settings
  - `hosted` is for storing artifacts, `proxy` is for downloading dependencies from the repository, and `group` is for both together
- Go back to Jenkins Dashboard > Manage Jenkins > Manage Credentials, click on `Jenkins` underneath `Stores scoped to Jenkins` > Global Credentials > `Add Credentials`
- Use the Nexus Login credentials that you set for the username and password here, set an ID that you'll remember/use in the Pipeline

**Pipeline Example**

- Example of Pipeline including Nexus storage: see [PAAC_CI_Sonar_Nexus.txt](example-pipelines/PAAC_CI_Sonar_Nexus.txt)

### Sending Pipeline Notifications

- In Slack, add the `Jenkins CI` app to your Workspace and choose which channel it will post to
- It'll give you steps on how to set it up in Jenkins, but it'll also give you a `Team subdomain` and `Integration token credential ID` to configure in Jenkins
- In Jenkins, install the `Slack Notification` plugin, then go to Manage Jenkins > Configure System, and find the `Slack` section
  - Workspace should be the name (maybe `Team subdomain`?)
  - Add a token that's `Secret text` and put in the Slack-generated token for the `Secret` field. Give the credential an `ID` that you'll use in the Pipeline
  - Give the default channel name where notifications will go
- Once it's all setup, [PAAC_CI_SlackNotification.txt](example-pipelines/PAAC_CI_SlackNotification.txt) is a Pipeline example that sends a Slack notification once the pipeline finishes

## CI for Docker and Jenkins

**Setup**

- Install Docker engine in Jenkins
  - SSH into Jenkins server with [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
  - add the `jenkins` user into the `docker` group with `usermod -a -G docker jenkins`
  - verify `jenkins` user with `id jenkins`
- Install AWS CLI
  - `apt install awscli`
- Reboot Jenkins server (or just restart jenkins service) while doing the next steps
- Create an IAM user with ECR permissions
  - Create with username `jenkins` and set it to have Programmatic access
  - Attach existing `AmazonECS_FullAccess` and `AmazonEC2ContainerRegistryFullAcess` policies
- Create ECR repos in AWS
  - Create private repository and give it a name. Keep other settings default
- Install `Docker Pipeline`, `Amazon ECR`, `AWS SDK :: All`, and `CloudBees Docker Build and Publish` plugins in Jenkins
- Store AWS IAM user credentials in Jenkins
  - Dashboard > Manage Jenkins > Manage Credentials > Click on Jenkins under Stores scoped to Jenkins > Global Credentials > Add Credentials
  - Choose `AWS Credentials` type
  - Give name (like `awscreds`)
  - Populate Access Key ID and Secret Access Key that you got when creating the IAM user

**Pipeline Example**

- See [PAAC_CI_Docker_ECR.txt](example-pipelines/PAAC_CI_Docker_ECR.txt) for an example pipeline that also publishes a Docker image to Amazon ECR
  - Line 4 `registryCredential` is `ecr:<aws-region>:<aws-creds-name-in-jenkins>`
  - Line 5 `appRegistry` is the image name (`<URI>/<image-name>`) from the ECR repository that you created
  - Line 6 `vprofileRegistry` is the image repository (`https://<URI>`) from the ECR repository that you created

## CI + CD for Docker and Jenkins

**Container Hosting Services**

- Now that we have a docker image that's being built and saved, how/where do we run it?
- You don't want to run containers directly on the Docker engine in production environments because they don't offer robust features and you have to manage the underlying engine
- Kubernetes is a container hosting service that is good. You can run it standalone, with AWS EKS (Elastic Kubernetes Service), Azure AKS, GKE, Openshift, etc.
- Until we learn Kubernetes, we will just use Amazon Elastic Container Service (ECS), which uses serverless compute (Fargate) or EC2 instance clusters as Docker container hosts

**Setup**

- Create ECS Cluster
  - Create Cluster, give name, use desired VPC and all desired subnets
  - AWS Fargate is pay-as-you-go, no managing EC2 instances, it's all handled for you with serverless compute
  - Enable Monitoring so we can see logs of container instances as they come up
- Create ECS Task Definition
  - In the ECS sidebar, click on `Task definitions` and `Create new task definition`
  - Name the container and use the URI from the ECR repository you created for the `Image URI`
  - Set the correct port for you application. This class's project `vprofile` is a Tomcat web server on port TCP:8080
  - In Step 2, choose Fargate or EC2 and choose CPU/Memory resource amounts
- Create ECS Cluster Service
  - Go back to the Cluster dashboard and click on the Cluster you created
  - In the `Services` tab, click on `Deploy`
  - Keep as `Service` type
  - For `Family` choose the ECS Task Definition you just created
  - Under Load Balancer, choose `Application Load Balancer` and create a new one
  - Under Networking, create a new security group allowing TCP:80 (web traffic) and TCP:8080 (tomcat web server) from anywhere
- Access Check!
  - Make sure the target group is doing a health check on `8080` for this project, which you may have to change
- Install `Pipeline: AWS Steps` plugin in Jenkins

**Pipeline Example**

- See [PAAC_CICD_Docker_ECR_ECS.txt](example-pipelines/PAAC_CICD_Docker_ECR_ECS.txt) for an example pipeline that publishes a Docker image to ECR and deploys it with ECS
  - Line 7 `cluster` is the name of the created ECS cluster
  - Line 8 `service` is the name of the service inside of the ECS cluster
    - The service is the task inside of ECS that'll fetch the image from ECR and run it
    - The service also includes elastic load balancers

## Jenkins Master Slave Concept

- The Jenkins server where Jenkins is running is considered the Master
- If you need additional physical capacity to run jobs, Jenkins can configure slave nodes that it can run jobs on instead of, or in addition to, running jobs on the Master server
- A slave node requires the following:
  - A user that Jenkins will use to access the slave hose
  - A directory fully owned by the above-mentioned user that is only used by Jenkins
  - Necessary dependencies installed (JDK, JRE, Maven, etc.)
- In Jenkins `Configure Jenkins`, you can then setup slave nodes that the Jenkins master can access to run jobs
  - You need to setup some kind of authentication. You can use password-based auth, but that requires allowing password SSH on the slave node and configuring the slave node to be accessed via password without verifying hostname
  - A better way to do this is setup access keys that the Jenkins master will use to SSH to the node
- Make sure that Security Groups, ACLs, Firewalls allow access between the Jenkins master and slave nodes

## Jenkins Security, Authentication, and Authorization

- In `Configure Jenkins` > `Configure Global Security` you can allow users to sign-up or authenticate with an existing LDAP server
- If you let users sign-up or sign-in, you need to manage access to permissions better. The matrix-based security can be good for granular control either by user or by project
  - Matrix-based security by user or group will allow specified permissions to all projects
  - Matrix-based project security Weill allow you to go to individual projects, `Configure` > `Enable project-based security`, and then set which users/groups have permissions specifically for each project
- The `Role-based Authorization Strategy` plugin allows you to assign permissions to roles and then assign users into those roles
  - After installing this plugin, do `Configure Jenkins` > `Configure Global Security` > `Role-based security` and save
  - This will open up a new option in `Configure Jenkins` > `Manage and Assign Roles` where you can create roles, users, groups, and manage them all
