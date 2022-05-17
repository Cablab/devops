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

### Services

- **Nginx**: Web service (load balancer for requests)
- **Tomcat**: Application server
- **RabbitMQ**: Message broker / queueing agent
- **MemCache**: Database caching
- **ElasticSearch**: Indexing/Search service
- **MySQL**: SQL Database

### Provisioning Order

MySQL > MemCache > RabbitMQ > Tomcat > Nginx

### MySQL Provisioning

- SSH onto MySQL host, run `yum update -y` to make sure everything is up to date for first provisioning
- Set an ENV for a database password that you will reuse a bunch. You can also set it in `/etc/profile` so it's permanant and gets loaded each time you log in
- Install needed packages:
  - **[EPEL](https://www.redhat.com/en/blog/whats-epel-and-how-do-i-use-it)** - `ym install epel-release` - Red Hat only has certain packages officially maintained. EPEL provides other packages that are helpful to use
  - **git**: We're using this to download the class repo
  - **MariaDB**: MySQL server package
- Enable (so it starts at boot) and start the MariaDB server with `systemctl enable/start mariadb` and check that it's running
- Run the `mysql_secure_installation` script (installed by MariaDB?) to setup the server, create root password, etc.
- Create a database and give all privileges to the admin user on the `app01` VM machine

```bash
mysql -u root -p"$DB_PASS" -e "CREATE DATABASE accounts"
mysql -u root -p"$DB_PASS" -e "grant all privileges on accounts.* TO 'admin'@'app01' identified by 'admin123'"
```

- Run the DB backup file from the class repo to set the database up
  - `mysql -u root -p"$DB_PASS" accounts < vprofile-project/src/main/resources/db_backup.sql`
- Now that the DB is setup, run `mysql -u root -p"$DB_PASS" -e "FLUSH PRIVILEGES"` to clean it up and get it ready to go
- Setup firewalld access as specified in [VprofileProjectSetupd.pdf](./VprofileProjectSetup.pdf)

### Memcache Provisioning

- Steps used are listed on [Page 5 of VprofileProjectSetup](./VprofileProjectSetup.pdf)

### RabbitMQ Provisioning

- Steps used are listed on [Page 6 of VprofileProjectSetup](./VprofileProjectSetup.pdf)

### Tomcat Provisioning

- Steps used are listed on [Page 8 of VprofileProjectSetup](./VprofileProjectSetup.pdf)

### Manual App Deployment

- Steps used are listed on [Page 10 of VprofileProjectSetup](./VprofileProjectSetup.pdf)

### Nginx Provisioning

- Steps used are listed on [Page 11 of VprofileProjectSetup](./VprofileProjectSetup.pdf)

## Automated Deployment

All necessary resources, including the `Vagrantfile` and automated provisioning scripts for each host, are found in the [Automated_provisoining directory of the class repo](https://github.com/devopshydclub/vprofile-project/tree/local-setup/vagrant/Automated_provisioning) on the `local-setup` branch.

- Download the files in the above `Automated_provisioning` directory. I've placed them in [automated-project](./automated-project/)
- Just run `vagrant up` while in the directory and it'll handle everything. Look at the [Vagrantfile](automated-project/Vagrantfile) to see how it's setting up each server and running a provisioning file when each server boots
