# Version: 1.0
# Iptables   NAT shell script . Create by Aricwang.
#!/bin/bash

service iptables start
iptables -F

echo "1" > /proc/sys/net/ipv4/ip_forward
# OR:
# echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
# sysctl -p

internal_ip="172.16.1.159"
internet_ip=($( ifconfig | grep addr: | grep -v "${internal_ip}" | grep -v "127.0.0.1" | awk -F 'Bcast' '{print $1}' | awk -F 'addr:' '{print $2}' ))

iptables -t nat -A POSTROUTING -s ${internal_ip}/24 -j SNAT --to-source $internet_ip

#show me iptables's NAT table:
iptables -t nat -L -n

# On the internal servers should execute the following command:
# route add default gateway $internal_ip
