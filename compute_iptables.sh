#!/bin/bash

# @author jasperan
# this file aims to reset iptables and enable port forwarding traffic (disabled by default).
# you need to run this every time you restart your machine or permanently save
# your iptables configuration with iptables-save (iptables-save > /etc/network/iptables.rules #Or wherever your iptables.rules file is)

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -t security -F
iptables -t security -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

iptables -A INPUT -i lo -j ACCEPT -m comment --comment "Allow all loopback traffic"
iptables -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT -m comment --comment "Drop all traffic to 127 that doesn't use lo"
iptables -A OUTPUT -j ACCEPT -m comment --comment "Accept all outgoing"
iptables -A INPUT -j ACCEPT -m comment --comment "Accept all incoming"
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Allow all incoming on established connections"