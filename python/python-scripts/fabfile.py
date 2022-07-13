from fabric.api import *

def greeting(msg):
    print("Good %s" % msg)

def system_info():
    print("Disk Space")
    local("df -h")
    print

    print("RAM Size")
    local("free -m")
    print

    print("System Uptime")
    local("uptime")
    print

def remote_exec():
    print("Get SystemInfo")
    run("hostname")
    run("uptime")
    run("df -h")
    run("free -m")

    sudo("yum install mariadb-server -y")
    sudo("systemctl start mariadb")
    sudo("systemctl enable mariadb")

def web_setup(WEBURL, DIRNAME):
    print("----------------------------")
    local("apt install zip unzip -y") # install dependencies on local host

    print("----------------------------")
    print("Installing dependencies")
    sudo("ym install httpd wget unzip -y") # install dependencies on remote host
    
    print("----------------------------")
    print("Start & enable services")
    sudo("systemctl start httpd")
    sudo("systemctl enable httpd")

    print("----------------------------")
    print("Download and push website to webserver")
    local("wget -O website.zip %s" % WEBURL)
    local("unzip -o website.zip")

    with lcd(DIRNAME): # 'with lcd()' runs `local` commands in the specified local directory
        local("zip -r tooplate.zip *")
        put("tooplate.zip", "/var/www/html/", use_sudo=True) # put(<local-file>, <remote-dir>, <options>)

    with cd("/var/www/html"): # 'with cd()' runs commands in the specified remote directory
        sudo("unzip tooplate.zip")

    sudo("systemctl restart httpd")

    print("Website setup is done")
    