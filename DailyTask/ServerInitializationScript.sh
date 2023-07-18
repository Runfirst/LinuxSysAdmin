#Author: Alex Gu    
#Date: 2023-07-18
#Last Modified by: Alex
#E-mail: alexgu0582@gmail.com
#This script is used to initialise the Linux Server, include time zone, selinux, firewalld, History
#!/bin/bash

#Set time zone and sync time
ln -s /usr/share/zoneinfo/Sydney /etc/localtime
if ! crontab -l | grep ntpdate &>/dev/null; then
    (echo "* 1 * * * ntpdate time.windows.com >/dev/null 2>&1"; crontab -l) | corntab
fi

#disable selinux
sed -i '/SELINUX/{s/permissive/disabled/}' /etc/selinux/config

#disable firewalld
if egrep "7.[0-9]" /etc/redhat-release &>/dev/null; then
    systemctl stop firewalld
    systemctl disable firewalld
elif egrep "6.[0-9]" /etc/redhat-release &>/dev/null; then
    service iptables stop
    chkconfig iptables off
fi 

#show operation time in History command
if ! grep HISTIMEFORMAT /etc/bashrc; then
    echo 'export HISTIMEFORMAT="%F %T `whoami` "' >> /etc/bashrc
fi

#SSH Expired time
if ! grep "TMOUT=600" /etc/profile &> /dev/null; then
    echo "export TMOUT=600" >> /etc/profile
fi

#forbit root account to login
sed -i 's/$PermitRootLogin'


