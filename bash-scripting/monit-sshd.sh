#!/bin/bash

if [[ -f /var/run/sshd.pid ]]
then
    echo "[INFO] - [$(date)] - sshd.service is running" >> /var/log/monit-sshd.log
else
    echo "[ERROR] - [$(date)] - sshd.service is NOT running. Attemping to start" >> /var/log/monit-sshd.log
    sudo systemctl start sshd
    if [[ $? -eq 0 ]]
    then
        echo "[INFO] - [$(date)] - sshd.service successfully started" >> /var/log/monit-sshd.log
    else
        echo "[ERROR] - [$(date)] - sshd.service failed to start. Please fix" >> /var/log/monit-sshd.log
    fi
fi
