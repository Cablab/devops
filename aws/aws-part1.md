# Amazon Web Services (AWS)

## Elastic Compute Cloud (EC2)

- EC2 stands for Elastic Compute Cloud. It's like a VM.
- It gives you an API for provisioning and managing virtual servers
- Easily scalable
- Pricing:
  - On Demand: pay per hour or seconds
  - Reserve Capacity: pay for 1 or 3 years
  - Spot: bid price for unused ec2 capacity
  - Dedicated: physical server dedicated to you

### EC2 Requirements for Setup

- **Amazon Machine Image (AMI)**: a ready-made virtual machine image, kind of like Vagrant box images for VM
- **Instance Type**: specify the hardware components and amount you want to simulate. Like, how much RAM, how many CPUs, etc.
  - [Instance Type Comparison](https://aws.amazon.com/ec2/instance-types/). Different types of instances are designed to be better at different tasks
- **Amazon Elastic Block Storage (EBS)**: flexible, cost effective, and easy-to-use data storage. It's like a virtual hard disk
  - The AMI comes with some default storage. You can configure extra EBS storage beyond that
- **Tags**: you can tag resources for searching/filtering
- **Security Group Instance**: acts as a virtual firewall that controls traffic for EC2 instances
- **Key Pair**: Use SSH keys to grant access onto the EC2 instance

### Setup

- When creating an EC2 instance, under `Advanced Details`, the `User data` section is like provisioning commands that will run when the instance comes up. So you can put commands in there and they will be run on boot
- To connect, click on the instance you want to connect to you and click the `Connect` button at the top of the EC2 service page. It'll give you directions on how to connect via your chosen method. You should use SSH keys and set up an SSH key while creating the instance
- Once the instance is launched, you can click on it and look at the associated Security Groups at the bottom. If you click on a Security Group, you can edit its inbound/outbound rules

### Setup Best Practices

- Gather requirements
  - OS, RAM, CPU, Network, Storage Size, Project, Services/Apps, Environment, Login User/Onwer
- Create key pair before (or during) setup, but not after instance has launched
- Create the security group you need
- Launch the instance

### Elastic IPs

- If you want an EC2 instance to have a static public IP address, you can allocate one through the `Elastic IPs` section of the EC2 service page
- Once created, you can select it, click the `Actions` button, and associate it with an existing EC2 instance

## AWS CLI

- [https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](AWS CLI Installation)
- [Full AWS CLI Commands Reference Docs](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)
- Create an IAM user in your account for awscli to have access, and set it up using access keys
  - Attach policies directly and give it full admin access
- When you're at the `Success` screen, grab the Access Key and Secret Access Key. Use them in the `aws configure` cli command to set up CLI access into your account
  - Configured information will get saved in `~/.aws`
  - Check where AWS CLI is configured with `aws sts get-caller-identity`
  
### AWS CLI for EC2

- Check all instances with `aws ec2 describe-instances`
- Commands to what we went through (EC2 instance creation, security groups, key pairs, etc.) in AWS CLI are shown in [AWS CLI Class PDF](AWS-Command-Line-Interface-Part-1.pdf)

## Elastic Block Storage (EBS)

- Virtual Hard disks, block-based storage
- Run EC2 OS, store data from database, etc.
- Place in specific Availability Zone and replicated in the same zone for redundancy
- Snapshot take a backup of the entire volue
- To attach to an EC2 instance, needs to be in the same Availability Zone as the instance

### EBS Types

[EBS Volume Types Doc](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html) has good info about which to choose for what purpose

- **General Purpose** - SSD - Most work loads
  - Best combo of price vs speed
- **Provisioned IOPS** - Large Databases
- **Throughput Optimized HD** - Big Data and Data Warehouses
- **Cold HDD** - File servers
- **Magnetic** - Backups and archives

### Recovery from Snapshot

- Unmount the corrupted partition so data doesn't override what you want to backup
- Detach the disk volume from the EC2 instance
- Create a new volume from the snapshot
  - When creating a new volume from a snapshot, you can change lots of settings like region, size, format, type, encryption, etc.
  - This means that Snapshots aren't just for recovery backup, you can do things like move a volume to a different region or encrypt a volume that you didn't previously have encrypted without losing the data
  - You can create an AMI (Amazon Image) from a snapshot if the snapshot is from the root directory volume
  - You can share a snapshot with another AWS account
- Attach the volume that was created from the snapshot to the EC2 instance
- Mount the partition back where it was

## Elastic Load Balancer (ELB)

- **Frontend Port**: Listens for user requests on this port.
- **Backend Port**: Services running on OS listen on this port

### Types of Load Balancers

- **Classic Load Balancing**: Listens to traffic, sees what port is in the request, load balances to instances/clusters based on the port/service (e.g. port 80 requests load balances across all web servers in cluster)
  - Layer 3 (Network) load balancing
- **Application Level Load Balancing**: Sees what service the user is trying to request (these may be different endpoints in the same web server), routes request to different instances/clusters based on which ones are supposed to handle the different kinds of requests (e.g. even for port 80 web requests, difference instances might handle `/videos` endpoints vs `/videos/new` endpoints)
  - Layer 7 (Application) load balancing
- **Network Load Balancing**: Can handle millions of requests per second. More expensive. Can have a static IP for the load balancer
  - Layer 4 (Network) load balancing

### Load Balancer Setup

- In the `Load Balancing` section of EC2, look at `Target Groups`. This allows you to group together EC2 instances and other types of AWS services for load balancing
- Once you set up the target group settings in step 1, choose the instances you want to include in the target group and click `Include as pending below`
- With the target group created, go to `Load balancers` section and choose which kind you need
- Once created, you use the load balancer DNS name to access the services behind the load balancer
- If you try to access the site with the load balancer and you get a 500 error, your security group on the EC2 instances themselves might not be allowing access from the load balancer. Update the security groups to allow access
  - You can see that this might be the case by looking at the target group you created, checking the `Targets` tab, and seeing that their `Health status` is likely `unhealthy` because they can't get traffic through

## Create Custom AMI

- Select EC2 instance, Actions > Images and Templates > Create Image
- Once created, it'll be listed in the `Images` section of the EC2 service sidebar for use

### Launch Templates

- With a custom AMI, you can easily create an EC2 instance from the image and have everything already set up. However, you still have to choose all the options when creating an EC2 instance
- If you create a `Launch Template`, you can pre-select all the EC2 options and launch instances very quickly off the template

## Cloudwatch

- **Metrics**: monitoring for AWS services
  - **Alarms**: set alarm thresholds for various metrics, can trigger notifications via Amazon Simple Notification System (SNS)
- **Events**: near real-time stream of events that describe changes in AWS
- **Logs**: Monitor, store, access log files from AWS services

### Default Monitoring Period

- By default, the built-in CloudWatch monitoring updates every 5 minutes. If you want to make it update every 1 minute, select your EC2 instance, go to the `Monitoring` tab, and click the `Manage detailed monitoring` button in the top right
- By enabling detailed monitoring, metrics will update every 1 minute. This will cost extra

### Create Alarms

- Go to the CloudWatch service, choose the `All Alarms` section from the sidebar, choose `Create Alarm`, and then choose what service/monitoring metrics you want to use to create the alarm

## Elastic File System (EFS)

- EFS is a shared file system that you can mount on your EC2 instances just like EBS. However, EFS is sharable across multiple instances
- EFS is NFS based, so allow access to EC2 instances by allowing `NFS` access to the EC2 instances' security groups
- Create an `Access Point` for the EFS. You'll mount onto EC2 instances through the Access Point
- On the EC2 instance, follow directions from [Mounting EFS file systems](https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html) to mount it
  - Specifically with an Access Point, you can follow the automatic mount with `/etc/fstab` steps on [Mounting EFS Automatically](https://docs.aws.amazon.com/efs/latest/ug/mount-fs-auto-mount-onreboot.html)

## Autoscaling

- Autoscaling can monitor and adjust compute resources (even full EC2 instances) to maintain performance
- This works off CloudWatch, so it can add/remove capacity based on metrics in CloudWatch
- Autoscaling uses launch templates to create new instances
- Autoscaling uses a `Scaling Policy` to determine whether to increase or decrease resources
- Create an Auto Scaling Group with launch template + AMI, ELB + target group, and proper security groups and the acaling will automatically create/destroy instances as needed

## Simple Storage Service (S3)

- S3 is an object-based storage system. You can store anything at anytime and access it anywhere
- `Objects` are stored in `Buckets`. Bucket names must be unique
- Different from EFS because EFS gets mounted at OS level, but S3 is accessed programmatically
- Like other AWS services, cost is based on performance levels and utilization. You can see the different kinds [S3 Storage Classes](https://aws.amazon.com/s3/storage-classes/)
  - You can setup a policy to move data to a less performant storage class based on how recently it was accessed
- Charges are based on:
  - Size of Storage used
  - Number of requests made
  - Storage Class
  - Data Transfer
  - Region Replication

### S3 Tutorial

- If you create a Bucket and use the default setting to `Block all public access`, you cannot set any objects inside the bucket to be publicly available. You have to uncheck the Bucket setting, which will then leave permissions up to each individual object
  - You may also have to enable Access Control Lists (ACLs) on the bucket so that individual objects can have their own permissions/owners

### Static Website from S3

- Create a bucket and upload all necessary files for the static webpage
- Make all objects in the Bucket public
- In the Bucket settings, enable `Static website hosting` and set the necessary options
- In the Bucket settings, find the `Static website hosting` section and it'll have a public URL to access the static site

### S3 Lifecycle Management

- In the Bucket settings, the `Management` tab lets you set up `Lifecycle rules`
- With Lifecycle rules, you can set an object to transition to a different `S3 Storage Class`, or even be fully deleted, after a set number of days. This can be good for archiving log data and things that you may not need after a set amount of time has passed 

### S3 Object Replication

- In the Bucket settings, the `Management` tab lets you set up `Replication rules`. This will allow you to replicate objects in your bucket to a bucket in a different AWS Region. This can be good for redundancy and disaster recovery

## Relational DataBase (RDS)

- Common services run by DB Admin: Installs, Patching, Monitoring, Performance Tuning, Backups, Scaling, Security, Hardware upgrades, Storage management
- RDS is a distributed relational database service that will do most of the above things for you
