#!/bin/bash
 MY_IP=$(ip a | awk '/inet.*eth0/{print $2}')
 MY_GW=$(ip r | awk '/default/{print $3}')
MY_MAC=$(ip a show dev eth0 | awk '/link\/eth/{print $2}')

cat << EOF # > /etc/netplan/50-cloud-init.yaml
network:
 version: 2
 renderer: networkd
 ethernets:
   enp0s8:
     dhcp4: no
     addresses: [$MY_IP]
     gateway4: $MY_GW
     nameservers:
       addresses: 
         - 8.8.8.8
         - 8.8.4.4
     match:
       macaddress: $MY_MAC
EOF
#netplan apply
#curl www.google.com
