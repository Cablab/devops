# VProfile Lift & Shift Project

This project takes the multi-tier web application created in [vprofile](../vprofile/) and moves it fully into the AWS Cloud architecture

- Use [Class Instructor Repo Branch](https://github.com/devopshydclub/vprofile-project/tree/aws-LiftAndShift) to get any necessary files

## Intro

**AWS Services Used**

- EC2 <-- VM for Tomcat, RabbitMQ, Memcached, MySQL
- ELB <-- nginx
- Auto Scaling <-- Automation for VM Scaling
- S3/EFS Storage <-- Shared Storage
- Route53 <-- Private DNS service

## Security Groups & Keypairs

**Security Groups**

- Create SG for load balancer
  - allow HTTP and HTTPS from anywhere
- Create SG for tomcat http app
  - allow TCP:8080 from load balancer SG
- Create SG for backend services
  - allow TCP:3306 from tomcat application SG for MySQL
  - allow TCP:11211 from tomcat application SG for Memcached
  - allow TCP:5672 from tomcat application SG for RabbitMQ
  - allow TCP:9300 from tomcat application SG for ElasticSearch
  - allow all traffic from self (SG for backend services) so they can communicate to each other
  - TCP ports shown in code [here](https://github.com/devopshydclub/vprofile-project/blob/aws-LiftAndShift/src/main/resources/application.properties)

**Key Pairs**

- Create PEM that will be used key to log into EC2 instances

## EC2 Instances

**MySQL Backend**

- CentOS 7 AMI
- Use backend services security group
- User data provisioning info found [here](https://github.com/devopshydclub/vprofile-project/blob/aws-LiftAndShift/userdata/mysql.sh)
- Once provisioned, you can SSH on (may need to add SSH from My IP to security group) and run `curl http://169.254.169.254/latest/user-data` to check the commands that it ran on provision
- Use `ps -ef` and look toward the bottom of the output to see if any of the provisioning commands are still running. The EC2 instance may come up before all provisioning commands are done

**Memcached**

- CentOS 7 AMI
- Use backend services security group
- User data provisioning info found [here](https://github.com/devopshydclub/vprofile-project/blob/aws-LiftAndShift/userdata/memcache.sh)
- Verify service is running with `systemctl status memcached`
- Check that it's on the right port with `ss -tunpl | grep 11211`

**RabbitMQ**

- CentOS 7 AMI
- Use backend services security group
- User data provisioning info found [here](https://github.com/devopshydclub/vprofile-project/blob/aws-LiftAndShift/userdata/rabbitmq.sh)
- Verify service is running with `systemctl status rabbitmq-server`

**Backend Route53 Setup**

- Grab the Private IP for each of the above backend EC2 instances
  - mc01 `<private-IP>`
  - db01 `<private-IP>`
  - rmq01 `<private-IP>`
- In `DNS Management`, choose `Create Hosted Zone`
  - Select `Private hosted zone` and give any domain name desired
  - Choose correct AWS region and VPC
- For each backend service, do `Create Record`, `A` record type, give private IP address, put record name (like `mc01`, `rmq01`, etc.), `Simple routing` policy

**Tomcat App**

- Ubuntu AMI
- Use tomcat app security group
- User data provisioning info found [here](https://github.com/devopshydclub/vprofile-project/blob/aws-LiftAndShift/userdata/tomcat_ubuntu.sh) (we'll manually set up most of the stuff on the host)

## Build and Deploy Artifacts

**Build Artifact**

- Install `jdk8` and `maven` on localhost
- Grab the [application.properties file](https://github.com/devopshydclub/vprofile-project/blob/aws-LiftAndShift/src/main/resources/application.properties) and change the hostname lines to include the private IP hosted zone name that you setup for the project
- Clone the repo, change to the `aws-LiftAndShift` branch, make the changes to `application.properties` navigate back to the root, and run `mvn install` to have maven run the `pom.xml` file to create the project artifact
- Once finished, the artifact will be in `./target/vprofile-v2.war`

**Create IAM User for AWS CLI**

- Name it `vprofile-s3-admin` and give it programmatic access
- Attach policies directly and add AmazonS3FullAccess
- Grab the access key info and run `aws configure` on the command line to register AWS CLI for that IAM user
- Create an S3 bucket with `aws s3 mb s3://<bucket-name>`
- Copy the build artifact into the S3 bucket with `aws s3 cp <artifact> s3://<bucket-name>`
- Check that it is in the bucket with `aws s3 ls s3://<bucket-name>`

**Create IAM Role for EC2 Instance to Access S3 Bucket**

- Go to IAM > `Roles` > `Create Role`. Choose AWS service and EC2
- Give it `AmazonS3FullAccess`
- Go to your EC2 Instance dashboard, select the Tomcat app instance, and do `Actions` > `Security` > `Modify IAM Role`, and then choose the new role you created

**Manually Deploy Artifact**

- SSH onto the tomcat app instance
- `systemctl stop tomcat8` to stop the service, then delete the `/var/lib/tomcat8/webapps/ROOT` directory
- Install AWS CLI on the EC2 instance with `apt install awscli -y`
- Since the IAM Role was created, the instance should have access. Test with `aws s3 ls`
- Copy the build artifact with `aws s3 cp s3://<bucket-name>/<artifact-name> /tmp/`
- Copy the artifact from the `/tmp` directory where you downloaded it into the necessary tomcat location, but change the name so tomcat can use it. `cp /tmp/<artifact-name> /var/lib/tomcat8/webapps/ROOT.war`
- Restart the tomcat8 service
- Check if tomcat appropriately unpackaged the artifact by seeing if the `/var/lib/tomcat8/webapps/ROOT` directory exists again
- Look at `/var/lib/tomcat8/webapps/ROOT/WEB-INF/classes/application.properties` and see if it's the same as what you edited to include the Route53 hosted zone
- If you want to check connectivity, you can look at the output and try `telnet <hostname>.<hosted-zone> <port>` for each backend instance and see if it connects

## Load Balancer and DNS

**Load Balancer**

- Create a target group for `Instances` and remember that tomcat uses port `8080`
- Health check endpoint is `/login` and make sure to override health check to also use port `8080`
- Add only the tomcat app EC2 instance into the target group
- Create an Application Load Balancer, select all availability zones, give it the ELB security group, and make sure it forwards both HTTP:80 and HTTPS:443 to the target group
- Since we're using HTTPS, you have to choose a certificate. This is where the Amazon Certificate Manager (ACM) setup from way before comes in. Choose the certificate that you have already setup for this course

**DNS Setup**

- Once the loab balancer has provisioned, grab the DNS A Record for it
- Go to your domain provider DNS settings (GoDaddy for this course) and create a `CNAME` record with `Host` being whatever you want to call the app and `Points to` being the load balancer DNS A Record
- Go to your site! Access via CNAME `Host` value and your owned domain, like `<Host>.<domain>`

## Autoscaling Group

- Create an AMI of the tomcat app EC2 instance
- Create a Launch Configuration for the auto scaling group
  - Choose the AMI image you just created
  - Give it the IAM S3 role so it can download aftifacts if needed
  - Enable EC2 instance monitoring in CloudWatch
  - Give it the tomcat app security group
  - Choose the existing key pair for login
- Create an auto scaling group
  - Choose your launch configuration (have to switch from launch group)
  - Select all availability zones
  - Select the load balancer you've already created and do a health check on it
  - Choose desired capacity
  - Set `Target tracking scaling policy` so it will automatically manage instances. Set it to be based off of CPU Utilization and maybe say 50%
  - Send notifications
- Once the auto scaling group is created, it should start provisioning hosts to get to desired capacity. We can now delete the instance we manually setup and created the image from
