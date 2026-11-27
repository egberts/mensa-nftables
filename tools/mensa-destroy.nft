#!/usr/sbin/nft -f

# Removed 'flush ruleset' as to co-exist with libvirtd's /etc/libvirt/nwfilter/*.xml
# flush ruleset

flush table netdev netdev_filter
flush table inet inet_filter
flush table ip ip_filter
flush table ip6 ip6_filter
flush table arp arp_filter
flush table bridge bridge_filter
flush table inet inet_nat
flush table ip ip_nat
flush table ip6 ip6_nat
flush table inet inet_route
flush table ip ip_route
flush table ip6 ip6_route

# we do not touch 'forward', 'guest_nat' hooks defined by libvirtd's /etc/libvirt/nwfilter/*.xml

delete table netdev netdev_filter
delete table inet inet_filter
delete table ip ip_filter
delete table ip6 ip6_filter
delete table arp arp_filter
delete table bridge bridge_filter
delete table inet inet_nat
delete table ip ip_nat
delete table ip6 ip6_nat
delete table inet inet_route
delete table ip ip_route
delete table ip6 ip6_route

# we do not touch 'forward', 'guest_nat' hooks defined by libvirtd's /etc/libvirt/nwfilter/*.xml



