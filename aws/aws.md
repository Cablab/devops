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
