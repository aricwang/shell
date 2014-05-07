#!/bin/bash

read -p "please insert into hostname: " host_name

hostname ${host_name}

sed -i "s/localhost.localdomain/${host_name}/" /etc/sysconfig/network
