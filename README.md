# wandog
Scripts to load balance and fail-over multiple wan connections

Due to outage in my service provider, I had to connect to multiple wireless stations in my appartment (with their permission) and load balance/failover to make sure that my work is not interrupted.
I had a dockstar and two USB wifi adapters laying around and wanted to make use of this to overcome the outage. But these scripts should work very well for regular wan connections too.

Many examples in the internet pointed me in the right direction but they all had some shortcomings for my purpose. Here are some advantages of this script

- Ping to a well known internet IP using the wan interface to decide if the internet status on that link. Just pinging the gateway is not sufficient here. I had very poor SNR for some connections where pings packets are lost some times but still be able to access internet.
- Linux ping has a limitation to select an interface if the default gateway is not added in the routing table. specially when the subnets overlap for dual wan.
- Using netfilter alone for load balancing in non stable wan links is very annoying as everyt time ip tables is updated, there is a short delay in accessing internet. so ip tables has to be kept as stable as possible without frequent changes
- Using policy based routing with multiple gateway is erratic and did not work for me. I had frequent ping response losses due to route cache invalidation.
- Should handle link failure cases gracefully (kind of failover)

##### add below lines to /etc/iproute2/rt_tables
```
10 wlan0
11 wlan1
```
##### Install
copy all the files to /opt/scripts

make all of them executable

run "bash wandog install" ; this will symlink wandog to /etc/init.d/wandog

run "udpate-rc.d wandog defaults" to make it run every time you start the system


symlink or copy dhcp_rt_tables under /etc/dhcp/dhclient-exit-hooks.d/

symlink or copy iptables.sh to /etc/network/if-up.d/, alternatively you can run this script once and use iptables-persistent package to make it survive restarts

you need to configure interfaces and wpasupplicant etc on your own to connect to different network

Hope you enjoy.
