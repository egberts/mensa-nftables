#!/usr/bin/env bash
# Create 000-error.rule in each listed subdirectory

set -euo pipefail

CONTENT='# File: 000-error.rule
# Path: *
# Title: Delete me once unit test passes
error "I errored right here."
'

DIRS=(
  arp-filter-input
  arp-filter-output
  bridge-filter-forward
  bridge-filter-input
  bridge-filter-output_filter
  bridge-filter-output_out
  bridge-filter-postrouting_filter
  bridge-filter-postrouting_srcnat
  bridge-filter-prerouting_dstnat
  bridge-filter-prerouting_filter
  inet-filter-forward-icmp
  inet-filter-forward-igmp
  inet-filter-forward-tcp
  inet-filter-forward-udp
  inet-filter-ingress
  inet-filter-input-icmp
  inet-filter-input-igmp
  inet-filter-input-tcp
  inet-filter-input-udp
  inet-filter-output_filter-icmp
  inet-filter-output_filter-tcp
  inet-filter-output_filter-udp
  inet-filter-output_raw-udp
  inet-filter-postrouting_filter
  inet-filter-postrouting_mangle
  inet-filter-postrouting_security
  inet-filter-postrouting_srcnat
  inet-filter-prerouting_conntrack
  inet-filter-prerouting_dstnat
  inet-filter-prerouting_filter-tcp
  inet-filter-prerouting_filter-udp
  inet-filter-prerouting_mangle
  inet-filter-prerouting_raw-udp
  inet-nat-input
  inet-nat-output
  inet-nat-postrouting
  inet-nat-prerouting
  inet-route-output
  ip6-filter-forward
  ip6-filter-input-icmp
  ip6-filter-input-igmp
  ip6-filter-input-tcp
  ip6-filter-input-udp
  ip6-filter-output_filter-icmp
  ip6-filter-output_filter-tcp
  ip6-filter-output_filter-udp
  ip6-filter-output_raw-udp
  ip6-filter-postrouting_filter
  ip6-filter-postrouting_mangle
  ip6-filter-postrouting_security
  ip6-filter-postrouting_srcnat
  ip6-filter-prerouting_conntrack
  ip6-filter-prerouting_dstnat
  ip6-filter-prerouting_filter-tcp
  ip6-filter-prerouting_filter-udp
  ip6-filter-prerouting_mangle
  ip6-filter-prerouting_raw-udp
  ip6-nat-input
  ip6-nat-output
  ip6-nat-postrouting
  ip6-nat-prerouting
  ip6-route-output
  ip-filter-forward
  ip-filter-input-icmp
  ip-filter-input-igmp
  ip-filter-input-tcp
  ip-filter-input-udp
  ip-filter-output_filter-icmp
  ip-filter-output_filter-udp
  ip-filter-output_filter-tcp
  ip-filter-output_raw-udp
  ip-filter-postrouting_filter
  ip-filter-postrouting_mangle
  ip-filter-postrouting_security
  ip-filter-postrouting_srcnat
  ip-filter-prerouting_conntrack
  ip-filter-prerouting_dstnat
  ip-filter-prerouting_filter-tcp
  ip-filter-prerouting_filter-udp
  ip-filter-prerouting_mangle
  ip-filter-prerouting_raw-udp
  ip-nat-input
  ip-nat-output
  ip-nat-postrouting
  ip-nat-prerouting
  ip-route-output
  netdev-filter-egress
  netdev-filter-ingress
)

for dir in "${DIRS[@]}"; do
  if [[ -e $dir ]]; then
    if [[ ! -d $dir ]]; then
      echo "Error, unexpected file type in $dir; aborted."
      exit -7
    fi
    # it's a directory, go ahead
  else
    mkdir -p "$dir"
    retsts=$?
    if [[ $retsts -ne 0 ]]; then
      echo "Error creating $dir subdirectory; aborted."
      exit -3
    fi
  fi
  printf '%s\n' "$CONTENT" > "$dir/000-error.rule"
  echo "Created $dir/000-error.file"
done

echo "Done."
