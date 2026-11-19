# mensa-nftables ARP zone rules

14 independent `.rule` fragments: one input and one output variant for each of seven ARP-related categories.

## Placement

These fragments are executed **after** the `arp` family input/output hook has dispatched to the relevant zone via an interface map/vmap. Do not add `iifname`, `oifname`, or other zone-selection matches to these rules. Fragments do not declare tables, chains, hooks, or maps.

## Zone substitutions

- `$ZONE_INTF_IPADDR`: zone interface IPv4 address
- `$ZONE_INTF_MACADDR`: zone interface hardware address
- `$ZONE_INTF_NETADDR_W_PREFIX`: zone network in CIDR form
- `$ZONE_INTF_NETADDR`, `$ZONE_INTF_NETMASK`: available but not needed for the included matches

These are template placeholders and must be expanded or defined by the deployment pipeline before nft parses the rules.

## Important semantics

- `counter` without `accept`/`drop` is observational and continues evaluation.
- GARP replies and RFC 5227 announcements are matched for a *specific* zone-interface IPv4 address; this is not generic GARP detection across all hosts.
- Proxy ARP cannot be identified from `arp operation reply` and a subnet match alone. These rules count candidate replies, not proven proxy replies.
- Incoming duplicate-address guard drops claims for the local IPv4 address with a nonmatching sender hardware address. Outgoing guard rejects inconsistent local address claims. Both require HA/virtual-MAC exceptions where applicable.
- ARP flux is not a protocol field. The corresponding rules are diagnostic matches, not ARP-flux prevention; map/vmap dispatch already selects the zone.
- `arp htype 15` matches a Frame Relay hardware-type field **only if** the packet reaches an nftables ARP hook. It does not provide Frame Relay encapsulation support.
- ARP probes (`0.0.0.0` sender) are accepted for targets in the zone network; make sure this terminal verdict is consistent with the rest of the zone policy.

## Validation

These are rule fragments, not a directly loadable complete nftables configuration. Assemble into your existing chains, substitute zone variables, then validate the resulting full ruleset with `nft -c -f assembled.nft` before deployment.
