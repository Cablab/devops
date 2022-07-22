# Amazon Web Services (AWS) Part 2

## Networking Refresher

- Private IP Ranges:
  - Class A: 10.0.0.0 - 10.255.255.255
  - Class B: 172.16.0.0 - 172.31.255.55
  - Class C: 192.168.0.0 - 192.168.255.255

**Subnet Masks**

- The part of the subnet mask that is all 255s is your unique network address
- The part of the subnet mask that is all 0s is the range where you can assign IP addresses to individual hosts inside of your own network
- First available IP in range is reserved for Network/Gateway
- Last available IP in range is reserved for Broadcast

**Classless InterDomain Routing (CIDR)**

- Allows for better division of subnets beyond normal submasks
- Default submasks are as follows:
  - Class A: 255.0.0.0
  - Class B: 255.255.0.0
  - Class C: 255.255.255.0
- Normally, the 255 section of a subnet specifies the network-specific address and the 0 section denotes hosts that are assigned IPs inside the network
- Let's look at class B, which is `255.255.0.0` or `11111111.11111111.00000000.00000000` in decimal. What if we only needed 2 `x.x.x.0` networks instead of all 256 of them? Like, maybe I want to use `172.16.0.0` and `172.16.1.0`, but not `172.16.2-255.0`. Normally you can't break that up with standard subnet masks
- Using CIDR, you can more dynamically assign masks by giving the IP range and then specify how many leading bits are important for the public network-specific address
- In the above example, you would have `172.16.0.0/23` where the `/23` denotes that the leading 23 bits are the network-specific bits. Why is this the case?
- We want addresses `172.16.0.0` and `172.16.1.0`, which are `11111111.11111111.00000000.00000000` and `11111111.11111111.000000001.00000000` in binary. Looking at the full binary notation, the leading 23 bits are the same. This means they're the network-specific section and CIDR denotes that with `/23`.
  - This would be equivalent to a subnet mask of `255.255.254.0` or `11111111.11111111.11111110.00000000`

## Virtual Private Cloud (VPC)

- VPC is a logical data center within in AWS Region. It's like setting up a full LAN inside of AWS
- Public subnets - devices are accessible through the public internet. Access is done through an internet gateway
- Private subnets - no public internet access. If a device in a private subnet needs to access the internet (like to download a resource), it must go through the VPC Network Address Translation (NAT) gateway in a public subnet
- Both public and private subnets have a route table telling them whether to send traffic to the internet gateway or NAT gateway
- A bastion host or jump server is a host in a public subnet that you can SSH into and from which you can access hosts in private subnets

### Setup Structure

- 4 subnets, 2 public and 2 private
  - 172.20.0.0/16 full network
  - 172.20.1.0/24 public-subnet 1 (Availability zone 1)
  - 172.20.2.0/24 public-subnet 2 (AZ 2)
  - 172.20.3.0/24 private-subnet 1 (AZ 1)
  - 172.20.4.0/24 private-subnet 2 (AZ 2)
- 1 internet gateway
- 2 NAT gateway (one in each zone)
  - We'll only use 1 for the project to save cost
- 1 Elastic IP for the NAT gateway
- 2 Route tables (1 for public subnet, 1 for private subnet)
- 1 Bastion host in public subnet
- Network Access Control List (NACL) (it's like a security group for the subnet)
  - Security Group for individual instance, NACL for network subnet
- 1 additional VPC to practice setting up Peering

### Create VPC

- VPC Service > Your VPCs > Create VPC
- Choose full network IPv4 CIDR range and give a name
- Leave Tenancy as Default

### Create Subnets

- VPC Service > Subnets > Create Subnet
- Choose the VPC created earlier
- Give a name, choose the Availability Zone, and choose the subnet CIDR range

### Create Internet Gateway for Public Subnets

- VPC Service > Internet Gateways > Create Internet Gateway
- Give a name and hit create
- On the Internet Gateway screen, choose Actions > Attach to VPC > Choose the VPC you created

### Create NAT Gateway for Private Subnet(s)

- VPC Service > NAT Gatewways > Create NAT Gateway
- Give a name and attach to a public subnet, keep connectivity as public
- Allocate an Elastic IP for the NAT gateway
  
### Create Route Table

- VPC Service > Route Tables > Create route table
- Give a name and choose the VPC
- On the Route Table screen, go to the Subnet Associations tab > Edit subnet associations > add the subnets that the route table is for
- For public subnet, go to Routes > Edit Routes > Add a listing that sends all 0.0.0.0/0 traffic to the public internet gateway you created
- For private subnet, go to Routes > Edit Routes > Add a listing that sends all 0.0.0.0/0 traffic to the private NAT gateway that you created

### Configure VPC Public Subnets for Instance Creation

- By default, you want EC2 instances that you create in a public subnet to get a public IP address so they're reachable
- To make sure this is true, go to Subnets, select your public subnets, do Actions > Edit subnet settings > and check the Enable auto-assign public IPv4 address
- Also, you'll want instances in the VPC to get DNS hostnames when created
- To do this, go to your VPC, choose Actions > Edit DNS Hostnames > check the DNS hostnames Enable box

## VPC Project Setup

- Create a web server EC2 instance and choose the created VPC
- All server instances should go in private subnets. You put a load balancer in the public subnet
  - Make sure the private security groups allow SSH access from the Bastion instance
- A Bastion instance can go in the public subnet. You'll SSH to that in order to access private instances
  - For practice you can just use Amazon Linux, but good AMIs are the CIS AMIs because they have better security
  - You'll need to put the access keys for private instances onto the bastion instance so you can SSH
- Create a classic Load Balancer (Network Load Balancer now)
  - Choose the created VPC and select the public subnets you created
  - Security group should allow TCP:80 from anywhere
  - Choose any existing web servers to assign into the load balancer
- Update the web server security group to allow TCP:80 access from the load balancer

### VPC Connection Testing

- Create two VPCs in different regions (they can't have overlapping CIDR ranges for the network)
- Go to VPC Service > Peering Connections > Create Peering Connection
- Set the Requester VPC as the one you're connecting from
- Populate the info of the VPC you're connecting to (VPC ID minimum, but also need AWS Account Number if you don't own the account where the other VPC is)
- This will send out a peering request to the remote VPC. They will have to accept it from their account/region > VPC service > peering connections
- Then you need to update the Route Tables of both VPCs
  - Get the Network CIDR Range for the A side VPC
  - Create an entry in the Z side VPC that routes traffic with Destination A side VPC CIDR range to Target the Peering Connection that was created
  - Do the same the other way as well

### Setup Network Access Control List (NACLs)

- Go to VPC Service > Network ACLs > Create network ACL
- Once created, select the NACL, go to the Subnet associations tab, and Edit subnet associations
- Add the subnets associated with the NACL
  - There should be separate NACLs for the public and private subnets
- Create Inbound and Outbound Rules for the NACLs. Here are some Rules guidelines:
  - [AWS VPC Network ACLs Guide](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html)
  - Create an increment rule so that Rules are defined by set increments in numbers
  - First rule should start at 100
  - ACLs are stateless, so you must create an identical Inbound and Outbound rule to control certain traffic
  - The standard is to create a bunch of rules with ALLOW or DENY as needed, then have a final entry for DENY all other traffic
  - NACLs are read in order. If a rule higher up in the table says something about a certain kind of traffic, it will follow that first rule it finds even if a later rule says something else about the same traffic

## EC2 Logging

- Servers generate a lot of logs and it's a good idea to archive and rotate them periodically
- Common to archive log files by doing `tar czvf` on them
- If you have an IAM user with programmatic access on your host, you can use AWS CLI to upload the logs straight to S3 with `aws s3 cp <path-to-archive> s3://<bucket-path-destination>` or `aws s3 sync <local-directory-with-archive> s3://<bucket-path-destination-directory>`
- Once you have it set up, you can automate a job to do the following steps:
  - Archive existing log files
  - Upload log files to storage
  - Remove archived log artifacts (or ones that are past a certain age?)
  - Clean the existing log files

### CloudWatch for Log Streaming

- CloudWatch allows you to stream logs to CloudWatch, set alarms, create dashboards, send to S3 for archive, etc.
- Create an IAM Role instead of a User. IAM Roles allow AWS services to have access to other services without the need for keys. This can allow EC2 instances to have access to S3
- With an IAM Role ready, go to your EC2 instance and select it > Actions > Security > Modify IAM Role > select the Role you created
- Install [unified CloudWatch Agent (new)](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html) or [CloudWatch Logs Agent (old)](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AgentReference.html) on a running EC2 instance
  - Install settings:
    - Destination Log Group name is the name of the CloudWatch Log Group you want to use
    - Log Stream Name is the name of the Log Stream inside of the specified Log Group
  - Use `sudo service awslogs start|stop|status|restart` to manage the service agent after setup
- The configuration file for streaming logs to CloudWatch is `/var/awslogs/etc/awslogs.conf`
- You can add blocks at the bottom to add additional log streams up to CloudWatch

```txt
# Block Format in /var/awslogs/etc/awslogs.conf

[<path-to-local-logfile>]
datetime_format = <datetime format> (default is `%b %d %H:%M:%S`)
file = <path-to-local-logfile>
buffer_duration = <duration> (default is `5000`)
log_stream_name = <name-of-log-stream-in-cloudwatch>
initial_position = <start_of_file|end_of_file>
log_group_name = <name-of-log-group-in-cloudwatch>
```

- Once this is setup, you can setup monitoring, metrics, alarms, dashboards, etc. all in CloudWatch

#### Log Streaming for Services Without Roles/Keys

- Some AWS services may not have attachable Roles or usable Keys
- If you want to stream logs from these services to S3, you have to attach policies to the S3 bucket to allow the service to put things in the bucket
