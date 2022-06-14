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
