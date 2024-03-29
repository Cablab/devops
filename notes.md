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
- Using GoDaddy.com, purchased cab-dev.com

**Docker Hub**
- Host Docker images
- Sign up for account

**SonarCloud**
- Sign up using GitHub account
- Create unique organization and project with free tier

### AWS Account Setup

**IAM with MFA**

- Go to IAM service in AWS account
- Click `Users` and `Add User`
- Create IAM user with `AccountAdmin` permissions
- Create a good password and save access keys and information

**Create Billing Alarms**

- Go to CloudWatch service
- Go to `All Alarms` and choose `Create Alarm`
- With `Select Metric`, go to `Billing` group
  - If you cannot see the `Billing` group, you need to log into the account as the root user and enable `Get Billing Notifications` in `Account Preferences > Billing Dashboard`
  - May also need to follow steps in [Activating IAM access](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step1) and [Granting Permissions](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step2)
  - Apparently `Billing` is only in region `us-east-1`, so change to that to setup the alarm
- Choose `Total Estimated Charge`, select the currency, and then click `Set Metric` in the bottom right
- In the `Configure Actions` screen, do:
  - Click `Add Notification`, select `In Alarm`, and choose the topic (email) where you want to receive the alerts (or create a new topic if you need to)
- Create the alarm and confirm in your email that you meant to subscribe to that

**Certificate Setup**

- Go to `ACM` service (AWS Certificate Manager)
- `Request a Certificate` > Choose a Public certificate
- Add the FQDN of a domain you own into the box
  - You can enable the cert on subdomains by adding `*.` wildcard to the beginning.
  - For example: setting up cert on `testing.com`, you could do `*.testing.com` for subdomains
- Use DNS validation
- Click into the (now pending) cert and you should see `CNAME name` and `CNAME value` fields. You need to create a DNS record on your domain with these values so AWS can verify the cert
- Cert verification can take up to 48 hours

## Stupid VIM/Git Bash Paste

- While in edit mode (default after `esc`), type `"*p` to paste clipboard

## Where to Go

**Specializations**:

- Cloud Computing and Automation - AWS, Google, Azure, etc.
- Pure Automation - Ansible, CI/CD, Python, etc.
- Containerization - Docker, Kubernetes, Swarm, openshift, etc.

**Certifications**:

- Cloud certs
- K8s
- Security for DevSecOps

## Things Learned

- Virtualization of separate server instances
- Vagrant to automate creation and provisioning of virtual machines
- Created a localhost setup of a full LAMP webstack with different services separated into VMs
  - Tomcat serving web app
  - Nginx acting as load balancer in front of web app
  - RabbitMQ for mesage broker / queueing agent
  - MemCache for database caching
  - MySQL for relational database storage
  - ElasticSearch for indexing/search service inside the web app
- Containerization to rebuild the full web app stack in containers instead of separate VMs
- Lift and Shift local web app VM setup into AWS
  - S3 for artifact storage and deployment
  - EC2 instances instead of VMs
  - Route53 and Hosted Zones for private backend EC2 instance services
  - Elastic Load Balancer instead of Nginx
  - ACM and domain provider to get an active domain and setup a secure certificate
  - IAM Roles and Users
  - Security Groups to allow access between services
  - Auto Scaling EC2 setup to dynamically create/destroy EC2 instances based on traffic
  - CloudWatch monitoring and notification setup on alarm thresholds
- Refactor web app setup to use native AWS services instead of EC2 instances for third party services
  - Beanstalk for Tomcat web app, load balancing, and auto scaling
  - S3 for storing build artifacts
  - RDS Instance for MySQL implementations
  - ElastiCache for memcached
  - Active MQ instead of manual RabbitMQ instance
  - CloudFront distribution to allow app delivery through CDN
- Running a Jenkins server
  - Manually creating Freestyle Projects in Jenkins
  - Installing tools, plugins, integrations, creating credentials, and more Jenkins configuration
  - Manually creating Jenkins Pipeline project with PaaC Jenkinsfile
  - Hosting a SonarQube and Nexus server for use in Jenkins CI/CD Pipeline on a Java app
  - Jenkins Pipeline with separate steps to build, test, code analyze, and store artifacts from project
  - Sending post-build notifications to Slack
  - Creating a Docker image from the final build artifact and hosting it in AWS ECR
  - Using the AWS ECR Docker image to create an AWS ECS automated app deployment
- AWS ECR repository creation to store custom created Docker images
- AWS ECS Cluster, Task Definition, and Service creation
  - Create a dynamic service on ECS Fargate cluster behind load balancer
- Python for automation OS tasks
  - Python OS library 
  - Python Fabric library for running commands on remote hosts
- Ansible for automating fleet management, provisioning, and configuration
  - Playbooks for defining multiple tasks to run in a single job
  - Roles to separate execution based on various unique host properties (server type, OS family, etc.)
  - Dynamic Ansible with variables, templates, handlers, facts, conditionals, loops, and more
  - Using Included Modules and hosted Collections for Modules supporting third party tools (AWS)
  - Ansible Galaxy repository space for user-defined roles
- AWS VPC Web Project
  - Creating a VPC in AWS with proper CIDR IP pool
  - Creating Public and Private subnets across multiple availability zones in VPC with proper CIDR IP pools
  - Internet Gateway setup to allow traffic flow in public subnets
  - NAT Gateway setup to allow traffic flow to/from private subnets
  - VPC Route Tables sending traffic from public/private subnets to internet gateway/NAT gateway respectively
  - Bastion server in public subnet allowing access to private instances
  - Load balancer in public subnet allowing access to web server in private subnet
  - Network ACLs to manage traffic for the VPC
  - Setting up VPC connections and Route Table entries between different VPCs
- AWS Logging and CloudWatch
  - Log streaming from EC2 to S3 and CloudWatch
  - IAM Roles to allow keyless access between AWS Services
  - CloudWatch Agent on Linux OS to enable log streaming directly from host
  - CloudWatch logs, metrics, alarms
- AWS CI/CD Pipeline
  - AWS CodeCommit for VCS and migration from GitHub to CodeCommit repo
  - AWS CodeBuild to automate build process and artifact creation/storage
  - AWS Code Pipeline triggering CodeBuild jobs upon CodeCommit repo changes and deployment to Beanstalk Environment
- Docker
  - Using Dockerfile to create custom images from an existing base image
  - Multi-staged Dockerfile to use containers to build artifact and copy them to the final image
  - Docker Compose to orchestrate running multiple containers simultaneously
  - Containerization of full-stack web app running on single physical host
- Kubernetes
  - Local cluster setup with minikube and VM
  - Kops for AWS K8s setup
  - `kubectl` access through `~/.kube/config` file
  - Namespaces for grouping resources in a cluster
  - Pods, ReplicaSets, and Deployments
  - Services, including NodePort, LoadBalancer, and ClusterIP
  - Attaching Volumes to a Pod declaratively
  - ConfigMaps and obfuscating plaintext credentials with Secrets
  - Ingress mapping to route external requests to Pod services
  - Taints and Tolerations for Pod affinity
  - Requests and Limits to manage Pod usage of physical resources
- Terraform
  - Terraform resource creation for IaaC
  - Storing backend tfstate remotely for dynamic access
  - Terraform provisioner resources for local execution, remote execution, and file copying
- CloudFormation
  - Creating Stacks from custom Templates
  - Using Parameters to allow user input at Stack execution
  - Printing values and exposing data to subsequent Templates with Output
  - Creating variable Mappings for reference in Resource definitions
  - Intrinsic Functions
  - `AWS::CloudFormation::Init` for provisioning commands upon resource creation