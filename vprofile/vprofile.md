# VProfile Project Setup

VProfile is a local stack setup for testing environments and project that would be deployed. It allows the creation of the stack and infrastructure to be automated and repeatable. This is a benefit because setting up a local stack for testing purposes is hard to replicate with VMs

## Tools

- Hypervisor (Oracle VM Virtualbox)
- Automation (Vagrant)
- CLI (Git Bash)
- IDE (VS Code)
- `vagrant plugin install vagrant-hostmanager` to map static IPs to hostnames for each host managed in a Vagrantfile
  - This will put each VMs IP and hostname into the `/etc/hosts` file on each VM

## Architecture - Manual

- Users can access the application by entering an IP address in a browser or using an endpoint
- Users are redirected to an Nginx service that acts as a load balancer for requests
- Nginx forwards the requests to Apache Tomcat application server running Java application
  - Application server can have shared storage with NFS (Network File System)
- Application server forwards request to RabbitMQ, the message broker
- RabbitMQ sends the request to Memcached for database caching
- Memcached caches the MySQL queries executed for the MySQL server

## Architecture - Automated

- Vagrant interfaces with Oracle VM Box to create VM
- Bash scripts setup services (Nginx, Apache Tomcat, Memcached, RabbitMQ, MySQL)

## Manual Setup

- Project template from [instructor GitHub](https://github.com/devopshydclub/vprofile-project/blob/local-setup/vagrant/Manual_provisioning/Vagrantfile). I copied this and edited a few things and put it in [./project/Vagrantfile](project/Vagrantfile)
- PDF instructions for setup are found in [VagrantProjectSetup](VprofileProjectSetup.pdf)
