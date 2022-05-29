#!/bin/bash

if [[ -f /var/log/archive/monit-sshd.tar.gz ]]
then
    sudo rm /var/log/archive/monit-sshd.log.tar.gz
fi

cd /var/log
sudo tar -czvf archive/monit-sshd.log.tar.gz monit-sshd.log &> /dev/null
sudo rm monit-sshd.log