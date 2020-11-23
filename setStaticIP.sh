#!/bin/bash
 MY_IP=$(ip a | awk '/inet.*eth0/{print $2}')
 MY_GW=$(ip r | awk '/default/{print $3}')
MY_MAC=$(ip a show dev eth0 | awk '/link\/eth/{print $2}')

cat << EOF > /etc/netplan/50-cloud-init.yaml
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
#         - 70.10.98.4
#         - 203.241.132.34
#         - 203.241.132.85
#         - 203.241.135.130
#         - 203.241.135.135         
     match:
       macaddress: $MY_MAC
EOF
netplan apply
# curl www.google.com
