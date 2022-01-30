# Virtual Machines (VMs) and Vagrant

Vagrant is a tool for automating Virtual Machines

## Virtual Machine Setup

Using Oracle VM VirtualBox

**Create Virtual Machine**
- Create new virtual machine with the default settings

**Allow VM to Have Network Connection**
- Select the virtual machine and go into `Settings`
- In the `Network` tab, keep `Adapter 1` set to NAT (this will be a private adapter that you cannot connect to)
- Enable `Adapter 2` and set it to `Bridged Adapter`, which allows the virtual machine to use your computers internet connection
- In the dropdown underneath `Bridged Adapter`, choose the network card/controller your computer uses to access the network

**Install OS Image**
- Download latest CentOS and Ubuntu LTS ISO images (or whatever distro you want to install)
- Select a VM, click `Settings`, choose the `Storage` section, select the disk icon underneath `Controller: IDE`, then click the disk icon in the top right next to `Optical Drive` to find the file of the ISO you downloaded
- Also click the `Live CD/DVD` checkbox

**Boot and Manual Installation**
- Continue with the standard English language options and `Continue Without Updating` the installer
- On the Network Connections screen, it should show you the private 10.x.x.x NAT adapter and the 192.168.x.x bridged adapter you setup
- Choose defaults for mirror and proxy address (just continue)
- For storage config, just keep things as they are selected and go down to continue
- Fill in user information/password as desired
- Use spacebar to check `Install OpenSSH server` you can SSH onto the virtual machine
- Finish going through screens to installation
- Reboot machine
- When the prompt says to `remove the installation medium`, go into the VM's settings to where the ISO was loaded, click the little disc symbol, and choose `Remove disc from virtual drive`
- When the login prompt is given, enter the username and password created during installation

## Vagrant
