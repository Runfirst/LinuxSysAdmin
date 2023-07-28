#!/bin/bash
#A sample firewall shell script. This is a script from website (https://www.cyberciti.biz/faq/rhel-fedorta-linux-iptables-firewall-configuration-tutorial/). In my opinion, this is very useful firewall script. I uploaded this script for study.

IPT="/sbin/iptables"
SPAMLIST="blockedip"
SPAMDROPSG="BLOCKED IP DROP"
SYSCTL="/sbin/sysctl"
BLOCKEDIPS="/root/scripts/blocked.ips.txt"


#Stop certain attacks
echo "Setting sysctl IPv4 settings..."
$SYSCTL net.ipv4.ip_forward=0
$SYSCTL net.ipv4.conf.all.send_redirects=0
$SYSCTL net.ipv4.conf.default.send_redirects=0
$SYSCTL net.ipv4.conf.all.accept_source_route=0
$SYSCTL net.ipv4.conf.all.accept_redirects=0
$SYSCTL net.ipv4.conf.all.secure_redirects=0
$SYSCTL net.ipv4.conf.all.log_martians=1
$SYSCTL net.ipv4.conf.default.accept_source_route=0
$SYSCTL net.ipv4.conf.default.accept_redirects=0
$SYSCTL net.ipv4.conf.default.secure_redirects=0
$SYSCTL net.ipv4.icmp_echo_ignore_broadcasts=1
$SYSCTL net.ipv4.icmp_echo_ignore_bogus_error_messages=1
$SYSCTL net.ipv4.tcp_syncookies=1
$SYSCTL net.ipv4.conf.all.rp_filter=1
$SYSCTL net.ipv4.conf.default.rp_filter=1
$SYSCTL kernel.exec-shield=1
$SYSCTL kernel.randomize_va_space=1


echo "Starting IPv4 Firewall..."
$IPT -F 
$IPT -X 
$IPT -t nat -F 
$IPT -t nat -X
$IPT -t mangle -F 
$IPT -t mangle -X


#Load modules
[ -f "$BLOCKEDIPS" ] && BADIPS=$(egrep -v -E "^#|^$" "${BLOCKEDIPS}")


#interface connected to the Internet
PUB_IF="eth0"


#Unlimited traffic for loopback
$IPT -A INPUT -i lo -j ACCEPT 
$IPT -A OUTPUT -l lo -j ACCEPT 


#DROP all incoming traffic
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP 

if [ -f "${BLOCKEDIPS}" ]; then
    #create a new iptables list
    $IPT -N $SPAMLIST 

    for ipblock in $BADIPS 
    do 
        $IPT -A $SPAMLIST -s $ipblock -j LOG --log-profix "$SAPMDROPMSG"
        $IPT -A $SPAMLIST -s $ipblock -j DROP
    done 

    $IPT -I INPUT -j $SPAMLIST
    $IPT -I OUTPUT -j $SPAMLIST
    $IPT -I FORWARD -j $SPAMLIST 
fi 

#Block sync
$IPT -A INPUT -i ${PUB_IF} -p tcp ! --syn -m state --state NEW -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "Drop Sync"
$IPT -a INPUT -i ${PUB_IF} -p tcp ! --syn -m state --state NEW -j DROP 


#Block Fragments
$IPT -A INPUT -i ${PUB_IF} -f -m limit --limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "Fragments Packets"
$IPT -A INPUT -i ${PUB_IF} -f -j DROP 


#Block bad stuff
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP 
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL ALL -j DROP 

$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL NONE -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "NULL Packets"
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL NONE -j DROP #NULL packets

$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 5/m --limit-burst 7 -j LOG --log-level 4 --log-prefix "XMAS Packets"






