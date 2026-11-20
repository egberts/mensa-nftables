#!/bin/bash

if [[ -z "$1" ]]; then
  echo "$0: syntax:  $0  new-zone-name [ 'template' ]"
  echo
  exit -1
fi
TEMPLATE_ZONE_NAME="template"
NEW_ZONE_NAME="${1}"
OLD_ZONE_NAME="${2:-${TEMPLATE_ZONE_NAME}}"


cp -rf zone-${OLD_ZONE_NAME}-arp-filter-input zone-${NEW_ZONE_NAME}-arp-filter-input
cp -rf zone-${OLD_ZONE_NAME}-arp-filter-output zone-${NEW_ZONE_NAME}-arp-filter-output

cp -rf zone-${OLD_ZONE_NAME}-inet-filter-input-icmp zone-${NEW_ZONE_NAME}-inet-filter-input-icmp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-input-igmp zone-${NEW_ZONE_NAME}-inet-filter-input-igmp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-input-tcp zone-${NEW_ZONE_NAME}-inet-filter-input-tcp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-input-udp zone-${NEW_ZONE_NAME}-inet-filter-input-udp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-forward-icmp zone-${NEW_ZONE_NAME}-inet-filter-forward-icmp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-forward-igmp zone-${NEW_ZONE_NAME}-inet-filter-forward-igmp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-forward-tcp zone-${NEW_ZONE_NAME}-inet-filter-forward-tcp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-forward-udp zone-${NEW_ZONE_NAME}-inet-filter-forward-udp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-output-icmp zone-${NEW_ZONE_NAME}-inet-filter-output-icmp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-output_raw-udp zone-${NEW_ZONE_NAME}-inet-filter-output_raw-udp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-output-tcp zone-${NEW_ZONE_NAME}-inet-filter-output-tcp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-output-udp zone-${NEW_ZONE_NAME}-inet-filter-output-udp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-prerouting_raw-udp zone-${NEW_ZONE_NAME}-inet-filter-prerouting_raw-udp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-prerouting-tcp zone-${NEW_ZONE_NAME}-inet-filter-prerouting-tcp
cp -rf zone-${OLD_ZONE_NAME}-inet-filter-prerouting-udp zone-${NEW_ZONE_NAME}-inet-filter-prerouting-udp

cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-input-icmp zone-${NEW_ZONE_NAME}-ip6-filter-input-icmp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-input-igmp zone-${NEW_ZONE_NAME}-ip6-filter-input-igmp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-input-tcp zone-${NEW_ZONE_NAME}-ip6-filter-input-tcp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-input-udp zone-${NEW_ZONE_NAME}-ip6-filter-input-udp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-forward-icmp zone-${NEW_ZONE_NAME}-ip6-filter-forward-icmp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-forward-igmp zone-${NEW_ZONE_NAME}-ip6-filter-forward-igmp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-forward-tcp zone-${NEW_ZONE_NAME}-ip6-filter-forward-tcp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-forward-udp zone-${NEW_ZONE_NAME}-ip6-filter-forward-udp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-output-icmp zone-${NEW_ZONE_NAME}-ip6-filter-output-icmp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-output_raw-udp zone-${NEW_ZONE_NAME}-ip6-filter-output_raw-udp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-output-tcp zone-${NEW_ZONE_NAME}-ip6-filter-output-tcp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-output-udp zone-${NEW_ZONE_NAME}-ip6-filter-output-udp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-prerouting_raw-udp zone-${NEW_ZONE_NAME}-ip6-filter-prerouting_raw-udp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-prerouting-tcp zone-${NEW_ZONE_NAME}-ip6-filter-prerouting-tcp
cp -rf zone-${OLD_ZONE_NAME}-ip6-filter-prerouting-udp zone-${NEW_ZONE_NAME}-ip6-filter-prerouting-udp

cp -rf zone-${OLD_ZONE_NAME}-ip-filter-input-icmp zone-${NEW_ZONE_NAME}-ip-filter-input-icmp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-input-igmp zone-${NEW_ZONE_NAME}-ip-filter-input-igmp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-input-tcp zone-${NEW_ZONE_NAME}-ip-filter-input-tcp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-input-udp zone-${NEW_ZONE_NAME}-ip-filter-input-udp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-forward-icmp zone-${NEW_ZONE_NAME}-ip-filter-forward-icmp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-forward-igmp zone-${NEW_ZONE_NAME}-ip-filter-forward-igmp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-forward-tcp zone-${NEW_ZONE_NAME}-ip-filter-forward-tcp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-forward-udp zone-${NEW_ZONE_NAME}-ip-filter-forward-udp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-output-icmp zone-${NEW_ZONE_NAME}-ip-filter-output-icmp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-output_raw-udp zone-${NEW_ZONE_NAME}-ip-filter-output_raw-udp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-output-tcp zone-${NEW_ZONE_NAME}-ip-filter-output-tcp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-prerouting_raw-udp zone-${NEW_ZONE_NAME}-ip-filter-prerouting_raw-udp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-prerouting-tcp zone-${NEW_ZONE_NAME}-ip-filter-prerouting-tcp
cp -rf zone-${OLD_ZONE_NAME}-ip-filter-prerouting-udp zone-${NEW_ZONE_NAME}-ip-filter-prerouting-udp

cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-input-icmp zone-${NEW_ZONE_NAME}-bridge-filter-input-icmp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-input-igmp zone-${NEW_ZONE_NAME}-bridge-filter-input-igmp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-input-tcp zone-${NEW_ZONE_NAME}-bridge-filter-input-tcp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-input-udp zone-${NEW_ZONE_NAME}-bridge-filter-input-udp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-forward-icmp zone-${NEW_ZONE_NAME}-bridge-filter-forward-icmp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-forward-igmp zone-${NEW_ZONE_NAME}-bridge-filter-forward-igmp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-forward-tcp zone-${NEW_ZONE_NAME}-bridge-filter-forward-tcp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-forward-udp zone-${NEW_ZONE_NAME}-bridge-filter-forward-udp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-output-icmp zone-${NEW_ZONE_NAME}-bridge-filter-output-icmp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-output_raw-udp zone-${NEW_ZONE_NAME}-bridge-filter-output_raw-udp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-output-tcp zone-${NEW_ZONE_NAME}-bridge-filter-output-tcp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-prerouting_raw-udp zone-${NEW_ZONE_NAME}-bridge-filter-prerouting_raw-udp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-prerouting-tcp zone-${NEW_ZONE_NAME}-bridge-filter-prerouting-tcp
cp -rf zone-${OLD_ZONE_NAME}-bridge-filter-prerouting-udp zone-${NEW_ZONE_NAME}-bridge-filter-prerouting-udp

cp -rf zone-${OLD_ZONE_NAME}-netdev-filter-ingress
cp -rf zone-${OLD_ZONE_NAME}-netdev-filter-egress zone-${NEW_ZONE_NAME}-netdev-filter-egress

