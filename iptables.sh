#!/bin/sh
# author: Prakash Sidaraddi

wlan0mark=$(cat /etc/iproute2/rt_tables | sed -rn "s/(.*)\S*wlan0/\1/p")
wlan1mark=$(cat /etc/iproute2/rt_tables | sed -rn "s/(.*)\S*wlan1/\1/p")


PATH=/usr/sbin:/sbin:/bin:/usr/bin

#
# delete all existing rules.
#
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -t mangle -X MARKING
iptables -X
iptables -Z
# Default policies iptables -P INPUT   DROP iptables -P OUTPUT  DROP iptables -P FORWARD DROP

# Enable loopback traffic
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT  -o lo -j ACCEPT

# Enable statefull rules (after that, only need to allow NEW conections)
iptables -A INPUT   -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


# Drop invalid state packets
#iptables -A INPUT   -m conntrack --ctstate INVALID -j DROP
#iptables -A OUTPUT  -m conntrack --ctstate INVALID -j DROP
#iptables -A FORWARD -m conntrack --ctstate INVALID -j DROP

#general io refine it
iptables -A INPUT -j ACCEPT
iptables -A OUTPUT -j ACCEPT
iptables -A FORWARD -j ACCEPT

# Allow outgoing connections from each side.
#iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
#iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
#iptables -A FORWARD -i eth0 -o wlan1 -j ACCEPT
#iptables -A FORWARD -i wlan1 -o eth0 -j ACCEPT

#load balance
iptables -N MARKING -t mangle
iptables -A MARKING -t mangle -o wlan0 -j MARK --set-mark $wlan0mark
iptables -A MARKING -t mangle -o wlan1 -j MARK --set-mark $wlan1mark

iptables -A PREROUTING  -t mangle -m state --state ESTABLISHED,RELATED -j CONNMARK --restore-mark
iptables -A POSTROUTING -t mangle -m mark --mark 0 -j MARKING
iptables -A POSTROUTING -t mangle -m mark ! --mark 0x0 -j CONNMARK --save-mark

iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o wlan1 -j MASQUERADE

# Masquerade.
#iptables -t nat -X zone_wlan0_nat
#iptables -t nat -N zone_wlan0_nat
#iptables -t nat -A POSTROUTING -o wlan0 -j zone_wlan0_nat
#iptables -t nat -A zone_wlan0_nat \! -d 192.168.1.0/24 -j MASQUERADE

#iptables -t nat -X zone_eth0_nat
#iptables -t nat -N zone_eth0_nat
#iptables -t nat -A POSTROUTING -o eth0 -j zone_eth0_nat
#iptables -t nat -A zone_eth0_nat \! -d 192.168.100.0/24 -j MASQUERADE

# Enable routing.
#echo -n '1' > /proc/sys/net/ipv4/ip_forward
echo -n '0' > /proc/sys/net/ipv4/conf/all/accept_source_route
echo -n '0' > /proc/sys/net/ipv4/conf/all/accept_redirects
echo -n '1' > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo -n '1' > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses

#iptables        -A INPUT        -j LOG --log-level debug --log-prefix 'FIL INPUT       '
#iptables        -A OUTPUT       -j LOG --log-level debug --log-prefix 'FIL OUTPUT      '
#iptables        -A FORWARD      -j LOG --log-level debug --log-prefix 'FIL FORWARD     '
#iptables -t nat -A OUTPUT       -j LOG --log-level debug --log-prefix 'NAT OUTPUT      '
#iptables -t nat -A PREROUTING   -j LOG --log-level debug --log-prefix 'NAT PREROUTING  '
#iptables -t nat -A POSTROUTING  -j LOG --log-level debug --log-prefix 'NAT POSTROUTING '
