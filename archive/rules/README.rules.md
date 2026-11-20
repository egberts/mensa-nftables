
To view all the rules within a subdirectory:

    cat *.rule | grep -v -E '^#' | grep -v -E '^$'


Suggested zone names:

  airgap, vpn-egress, private-l2, homelan, and wan-nat.

  arca - VMs on gateway (Latin: Box)
  red - WAN, public, Internet
  homelan - household LAN
