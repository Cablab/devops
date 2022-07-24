# VProfile Refactor

The purpose of this project is to take the VProfile project that exists in the AWS Cloud (as setup in [lift-and-shift.md](lift-and-shift.md)) and refactor it to use native AWS services instead of different EC2 instances running third-party services

- This refactor project will jump to use [vprofile-project/aws-Refactor branch of class repo](https://github.com/devopshydclub/vprofile-project/tree/aws-Refactor)

## Introduction

**AWS Services**

- Beanstalk <-- VM/EC2 for Tomcat, Load Balancer, Auto Scaling
- S3/EFS <-- Storage
- RDS Instance <-- Databases
- Elastic Cache <-- MemCache
- Active MQ <-- RabbitMQ
- Route53 <-- DNS
- CloudFront <-- CDN

## Security Groups and Keypairs

- Create a pem keypair to access instances if needed
- Create a security group for backend services with dummy inbound rules
  - Once created, remove the dummy inbound rule
  - Add a new inbound rule allowing all traffic from any source that's itself (own security group)

## RDS

- Create a subnet group so we can place our RDS instance inside of it
  - Choose which VPC to create in, then choose all availability zones and subnets
- Create a parameter group for you RDS engine. This will allow you to change settings in the future if needed
- Create a database with the subnet group, parameter group, and security group previously created
  
## ElastiCache

- Go to Amazon ElastiCache service and create a `Parameter Group`
  - Choose `memcached1.4` for Family, give it a name and description
- Create a subnet group
  - Add all availability zones and subnets
- Go to `Memcached clusters` section and create a memcached cluster
  - Set the parameter group to be the one you created
  - Set the node type to what you need. It defaults to a big one, which will cost money
  - Use the backend services security group created earlier

## Amazon MQ

- Go to `Amazon MQ` service and get started creating a broker
  - Choose `Active MQ` type
  - Single-instance broker for lower cost
  - `Broker instance type` set to micro to keep cost down
  - Use simple auth, then create a username and password and save them somewhere
  - In `Advanced Settings`, set the security group to what you created for backend services
  - Set to `Private access` since it's only being accessed for our web app's backend

## DB Initialization

- Create an EC2 instance in the same VPC as the backend services so we can log into them and start setup
- Run `apt update`, then `apt install myssql-client -y`
- Add inbound rule to backend services security group to allow MySQL connection from EC2 instance security group that we just created
- Log into RDS MySQL server from EC2 instance `mysql -h <RDS-endpoint> -u <username> -p<password>`
- Clone the class git repo, change to `aws-Refactor` branch, run `cd vprofile-project/src/main/resources`, and then run `mysql -h <RDS-endpoint> -u <username> -p<password> accounts < db.backup.sql` to run the provided DB setup script into the accounts database on the MySQL server
- Can now safely terminate the EC2 instance

## Beanstalk

- Grab the AMQP endpoint for the Active MQ and the ElastiCache endpoint that you created
- Go to `Elastic Beanstalk` service and `Create Application`
  - Give it a name and choose `Tomcat` for platform
  - Initially, go with `Sample application`
  - Click on `Configure more options`
  - Edit `Instances` and add backend services security group
  - Edit `Capacity` and:
    - Change from `Single Instance` to `Load Balanced`, then set desired min and max instances
    - Choose `Instance Types` (t2.micro for free tier)
    - Change `Scaling trigger` to desired settings
  - Edit `Load balancer` and:
    - Change to `Application Load Balancer`
    - Enable storage of access logs if desired
    - Edit the default `Process` to enable `Stickiness policy enabled` so users will stay in the same session across requests like login
  - Edit `Rolling updates and deployments` and:
    - Change to `Rolling` deployment policy
    - Set Batch size (for our project with min 2 instances, do 50% so it does 1 at a time)
      - 25% is a good number for production
  - Edit `Security` and setup pem key in order to SSH onto instance if needed
  - Edit `Monitoring` and:
    - To save money/for testing, set health reporting to `Basic`
    - For production, enable log streaming and maybe set to delete logs after terminating environment
  - Add tags if desired. Any tags will get applied to all created EC2 instances
- Wait for the Elastic Beanstalk environment to come up. When it's ready, you'll have an application with an environment inside for what you created. You can also create dev/staging environments inside the same application as well
- When ready, clicking on the environment will show you a load balancer endpoint you can use to access the web app

**Updating Backend Security Group for Beanstalk**

- Now that the beanstalk environment exists, we need to allow inbound traffic to the backend services security group from the beanstalk security group
- Go to EC2 Security Groups and you'll see that beanstalk created a couple of them: an environment instance group and a load balancer group. Rename these so they're more obvious
- Edit inbound rules on the backend services security group and add the following:
  - MYSQL/Aurora (TCP) 3306 from beanstalk environment instance security group
  - Custom TCP 5671 (Amazon MQ) from beanstalk environment instance security group
  - Custom TCP 11211 (ElastiCache) from beanstalk environment instance security group

**Update Beanstalk Health Check Endpoint**

- For our custom tomcat application, we'll use `/login` as the health check endpoint. Before we take down the sample application and put in our custom one, we need to update the health check endpoint
- Got to Elastic Beanstalk > Environments > Choose the created environment > `Configuration` in sidebar
- Edit the `Load balancer` section and:
  - `Add Listener` for port 443 on HTTPS and choose your existing SSL certificate
  - Edit the `Processes` default so the check path is `/login/`
  - If not done, edit the default `Process` to enable `Stickiness policy enabled` so users will stay in the same session across requests like login

## Build and Deploy Artifact

- Clone class repo, checkout `aws-Refactor` branch, and navigate to `./src/main/resources`
- Edit the `application.properties` file and replace hostnames (like db01, mc01, and rmq01) with the service endpoints of the created AWS services. Also make sure to update any credentials that you changed (usernames and passwords)
- CD back to root of repo and run `mvn install`, which will create an artifact in `./target/vprofile-v2.war`
- In the Elastic Beanstalk dashboard, click on `Application Versions` in the sidebar and then hit the `Upload` button to manually upload the built artifact
- Select the uploaded artifact, click `Actions`, and select `Deploy`. Choose the desired environment to deploy to
- Wait for the environment to deploy the new artifact. Since we setup rolling deployments at 50% at a time, our services never went down. The sample application was always available because Beanstalk should have fully updated 1 instance with the new artifact before starting on the second

**Update DNS**

- Go back to your domain provider and add a `CNAME` record. Set a host name (like `vprofile` for this project) and have it point to the Elastic Beanstalk load balancer endpoint

## CloudFront for CDN

- All the above setup creates the web app in a single AWS region. If we want the app to be available in multiple regions, we can use AWS CloudFront as the CDN to make it available elsewhere
- Go to `CloudFront` and `Create Distrubtion`
  - For `Origin Domain`, you can set it to the CNAME you created in your domain provider. For example, if the CNAME is `vprofile`, you can use `vprofile.<domain-name>`
  - Set `Match viewer` to allow HTTP and HTTPS
  - Based on user location, you can set the `Price class` to serve where users are
  - In `Alternate domain name (CNAME)`, add your `vprofile.<domain-name>` CNAME value again
  - Choose the SSL certificate that you created in ACM
- Once created, wait for the distribution to say `Enabled` and `Deployed`
- Go to your site and inspect elements. Refresh and see if the source is ever served from CloudFront!
