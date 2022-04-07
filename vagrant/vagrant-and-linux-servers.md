# Vagrant & Linux Servers

## Vagrant IP, RAM, and CPU 

- Run `vagrant global-status` to see the status of all VMs managed by vagrant
  - You can pass `--prune` into the command to remove outdated information
- When you run `vagrant up` for the first time, it creates a `.vagrant/` directory and a `Vagrantfile`
- You can edit the `Vagrantfile` to make config and resource allocation changes to the VM
  - The Vagrantfile is essentially a Ruby script that runs. It should have a line near the top that looks something like `Vagrant.configure("2") do |config|`
  - In the first line, the `|config|` is instantiating a class. All other lines that change settings will use that object and be called off of `config.<command>`
    - If you change the word in `|config|`, you need to change how it's called elsewhere too
- Reload the VM with `vagrant reload`. This will apply any changes you made in the Vagrantfile

## Vagrant Sync Directories

- When the VM is booted, it mounts the directory from your localhost with the `Vagrantfile` onto the `/vagrant/` path in the VM. Since it's just a mounted directory, this directed is synced between the localhost and the VM. Any files in this directory will show up in both places
- Create additional sync directories by editing the Vagrant file and adding lines that look like this: `config.vm.synced_folder "<path-to-directory>", "<mount-path-directory>"`
  - Remember that a Windows path may have something like `D:\\path`, but Linux uses `/path/path`

## Provisioning

- **Provisioning** or **Bootstrapping** means executing commands or running scripts when the system is booting/turning on
- In the `Vagrantfile`, there is a section that looks like the block below. You can add lines of additional commands to run inside the block and they'll get executed during boot

```bash
config.vm.provision "shell", inline: <<-SHELL
    # Command 1
    # Command 2
SHELL
```

- If the command you want to run requires put/confirmation, you will have to include that (like putting `-y` into any command that says to install a package)
- If you make provisiong changes to the Vagrantfile for a running VM, you can't just apply the changes with ``vagrant reload`. You have to do `vagrant reload --provision`
- This also applies to `vagrant up`. If the VM has already been provisioned, it will not run the provision commands unless you pass `--provision` or run the `vagrant provision` command

## Website Setup

**LAMP stack**: Linux, Apache, MySQL, PHP

### CentOS, httpd

- Find a template you like from [tooplate.com](https://www.tooplate.com/)
- On a CentOS VM, `yum install httpd wget unzip -y`
- Do a start and enable on httpd so the service is up and also starts on boot
- Since `/var` is for server data, there is a `/var/www/html` directory. When you are running `httpd` on CentOS, the web server will serve the `/var/www/html/index.html` file
- On Tooplate.com, find the template you like. Open the dev console in your browser and go to the network tab. When you click Download on the template page, there should be an actual Request URL that is fetched for the download. If you grab that, you can download directly to the VM with `wget`
- Copy the directory files with `cp -r * /var/www/html` and that should put the whole template into the directory
- Give the httpd service a `systemctl restart httpd` and it'll start serving the template

#### Automated CentOS/httpd Provisioning

- You can automate deploying a website template on CentOS with httpd by putting all the commands that were manually run above into the provisioning section of the Vagrantfile:

```bash
  config.vm.provision "shell", inline: <<-SHELL
    yum install httpd wget unzip -y
    systemctl start httpd
    systemctl enable httpd
    cd /tmp/
    wget https://www.tooplate.com/zip-templates/2121_wave_cafe.zip
    unzip -o 2121_wave_cafe.zip
    cp -r 2121_wave_cafe/* /var/www/html/
    systemctl restart httpd
  SHELL
```

### Ubuntu LAMP

- [Official Docs](https://ubuntu.com/tutorials/install-and-configure-wordpress#1-overview) for how to install Wordpress on Ubuntu step by step

#### Automated Ubuntu/LAMP Provisioning

- You can put all the commands you had to manually run from the Docs above into the provisioning section of a Vagrantfile and it should work. There are a couple things to note:
  - You can log into MySQL and run commands in a single line without having to enter the actual program prompt. That looks like `mysql -u <user> -e '<MYSQL COMMAND TO RUN>;'`. This will log into MySQL as the user, run the command, and exit
  - Finding and replacing all the `define('AUTH_KEY'),` stuff is optional, but you can do some cool replacement with `sed` as desired

## Multi VM Vagrantfile

- [Vagrant Docs](https://www.vagrantup.com/docs)
  - Specifically [Multi-Machine Docs](https://www.vagrantup.com/docs/multi-machine)
- Create a directory and make a `Vagrantfile` inside of it
- The general structure looks like this:

```bash
Vagrant.configure("2") do |config|
  config.vm.provision "shell", inline: "echo Hello" # these are global commands

  # VM 1
  config.vm.define "web01" do |web01|
    web01.vm.box = "centos/7"
    # other VM config commands
    # other VM config commands
  end

  # VM 2
  config.vm.define "db01" do |db01|
    db01.vm.box = "hashicorp/bionic64"
  end
end
```

- See an example in [Multi-VM Vagrantfile](../vagrant-vm/multi-vm/Vagrantfile)
- Once you have created both VMs with `vagrant up`, you have to now specify which one you want to access with other commands like `vagrant ssh <VM-name>`
  - Some commands will apply to all VMs defined by the Vagrantfile if none are specified. For example, `vagrant halt` will shut down all defined VMs
