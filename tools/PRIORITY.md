Priority principle:

    default DENY, 
    with sysadmin-controlled early ingress rejection and final egress rejection.

first opportunity to reject and,
final opportunity to reject.
Those are two different security properties,

* INPUT: Sysadmin goes first. An administrative drop prevents Docker and Libvirt from processing the packet at that hook.
* OUTPUT: Sysadmin goes last. An administrative drop prevents the packet from proceeding beyond that hook.

Also at input, INET family get first priority before ip/ip6 
Also at output, INET family get last priority after ip/ip6 

Combining both the overall authoritative stance and inet vs. ip/ip6, we get this sysadmin nftables:

# Netfilter Hook Priority Reference

## 1. Priority table

| Priority | Hook | Owner | Family | Type / reference |
|---:|---|---|---|---|
| -311 | ingress | Sysadmin | netdev | filter (0) - 311 |
| -310 | ingress | Sysadmin | inet | filter (0) - 310 |
| -310 | prerouting | Sysadmin | bridge | dstnat (-300) - 10 |
| -300 | prerouting | Netfilter | bridge | dstnat |
| -300 | prerouting | Docker | ip, ip6 | raw (where registered) |
| -225 | prerouting | Netfilter | ip, ip6, inet | SELinux first |
| -210 | prerouting | Sysadmin | bridge | filter (-200) - 10 |
| -210 | prerouting | Sysadmin | ip, ip6, inet | conntrack (-200) - 10 |
| -201 | prerouting | Sysadmin | ip, ip6, inet | conntrack (-200) - 1 |
| -200 | prerouting | Netfilter | ip, ip6, inet | conntrack |
| -160 | prerouting | Sysadmin | ip, ip6, inet | mangle (-150) - 10 |
| -150 | prerouting | Netfilter | ip, ip6, inet | mangle |
| -110 | prerouting | Sysadmin | ip, ip6, inet | dstnat (-100) - 10 |
| -100 | prerouting | Docker / Libvirt | ip, ip6 | dstnat (where registered) |
| -10 | input | Sysadmin | inet, bridge, arp | filter - 10 |
| -1 | input | Sysadmin | ip, ip6, inet, arp | filter (0) - 1 |
| 0 | input / forward / output | Other applications | Varies | filter |
| +1 | output | Sysadmin | ip, ip6, inet, arp | filter (0) + 1 |
| +10 | output | Sysadmin | bridge | filter (-200) + 10 |
| +50 | postrouting | Netfilter | ip, ip6, inet | security |
| +55 | postrouting | Sysadmin | ip, ip6 | security (50) + 5 |
| +60 | postrouting | Sysadmin | inet | security (50) + 10 |
| +100 | output | Netfilter | bridge | out |
| +100 | postrouting | Docker / Libvirt | ip, ip6 | srcnat (where registered) |
| +105 | postrouting | Sysadmin | ip, ip6 | srcnat (100) + 5 |
| +110 | postrouting | Sysadmin | inet | srcnat (100) + 10 |
| +110 | output | Sysadmin | bridge | out (100) + 10 |
| +200 | postrouting | Sysadmin | bridge | filter |
| +205 | postrouting | Sysadmin | ip, ip6 | numeric priority |
| +210 | postrouting | Sysadmin | inet | numeric priority |
| +225 | postrouting | Netfilter | ip, ip6, inet | SELinux last |
| +300 | postrouting | Netfilter | bridge | srcnat |
| +300 | postrouting | Netfilter | ip, ip6, inet | conntrack helper |
| +305 | egress | Sysadmin | netdev | numeric priority |
| +310 | egress | Sysadmin | netdev | numeric priority |
| +310 | postrouting | Sysadmin | bridge | srcnat (300) + 10 |

## 2. Standard priority reference

### IP, IPv6 and INET families

| Priority | Name | Purpose |
|---:|---|---|
| -300 | raw | Raw table processing |
| -225 | SELinux first | Security processing |
| -200 | conntrack | Connection tracking |
| -150 | mangle | Packet alteration |
| -100 | dstnat | Destination NAT |
| -50 | filter | Security processing (SELinux) |
| 0 | filter | Packet filtering |
| +50 | security | Security processing |
| +100 | srcnat | Source NAT |
| +225 | SELinux last | Security processing |
| +300 | helper | Connection-tracking helpers |
| INT_MAX | conntrack confirmation | Connection tracking confirmation |

### Bridge family

| Priority | Name | Purpose |
|---:|---|---|
| -300 | dstnat | Destination NAT |
| -200 | filter | Bridge filtering |
| 0 | brnf | Bridge netfilter processing |
| +100 | out | Bridge output |
| +200 | filter | Bridge filtering |
| +300 | srcnat | Source NAT |

### Netdev family

| Priority | Name | Purpose |
|---:|---|---|
| 0 | filter | Interface-level filtering |

## 3. Sysadmin priority convention

The administrative firewall uses asymmetric placement to establish early ingress rejection and final egress rejection.

| Hook | Sysadmin priority | Relative position | Objective |
|---|---:|---|---|
| ingress | -311 / -310 | Early | Reject packets before IP processing |
| prerouting | -210 / -160 / -110 | Early | Administrative packet processing |
| input | -1 | First | Reject before Docker/Libvirt |
| forward | To be determined | To be determined | Administrative forwarding policy |
| output | +1 | Last | Final administrative outbound filtering |
| postrouting | +55 / +60 / +105 / +110 | Late | Administrative postrouting processing |
| egress | +305 / +310 | Late | Final interface-level filtering |

### Intended INPUT ordering

| Owner | Priority |
|---|---:|
| Sysadmin | -1 |
| Libvirt | 0 |
| Docker | 0 |

### Intended OUTPUT ordering

| Owner | Priority |
|---|---:|
| Libvirt | 0 |
| Docker | 0 |
| Sysadmin | +1 |

**Verdict semantics:**

- `accept`: Terminates evaluation of the current base chain; subsequent base chains can still evaluate the packet.
- `drop`: Immediately terminates packet processing.
- `reject`: Terminates packet processing and generates an appropriate rejection response.

## 4. Family and hook compatibility

| Family | ingress | prerouting | input | forward | output | postrouting | egress |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `ip` | No | Yes | Yes | Yes | Yes | Yes | No |
| `ip6` | No | Yes | Yes | Yes | Yes | Yes | No |
| `inet` | Yes* | Yes | Yes | Yes | Yes | Yes | No |
| `bridge` | No | Yes | Yes | Yes | Yes | Yes | No |
| `arp` | No | No | Yes | No | Yes | No | No |
| `netdev` | Yes | No | No | No | No | No | Yes** |

\* Linux 5.10 and later.

\** Linux 5.16 and later.

## 5. Important implementation notes

- Numeric priority determines execution order. Lower values execute first.
- Equal priorities do not guarantee ordering between base chains.
- An `accept` verdict does not override a subsequent base-chain `drop`.
- A `drop` verdict prevents subsequent base chains at that hook from processing the packet.
- `mangle`, `dstnat`, `srcnat`, and `filter` are priority names, not nftables chain types.
- `filter` is a chain type; `nat` is another chain type.
- `inet` supports shared IPv4/IPv6 processing.
- `bridge` has its own priority namespace.
- `netdev` supports ingress and egress processing.
- `inet` ingress requires Linux 5.10 or later.
- `netdev` egress requires Linux 5.16 or later.
- Docker and Libvirt registrations must be verified against the installed firewall backend and software version.
- `postrouting` and `egress` are distinct hooks. Egress is not a substitute for postrouting.

## 6. References

- [nftables Wiki — Netfilter hooks](https://wiki.nftables.org/wiki-nftables/index.php/Netfilter_hooks)
- [nftables Wiki — Families](https://wiki.nftables.org/wiki-nftables/index.php/Nftables_families)
- [Debian nftables(8) manual](https://manpages.debian.org/trixie/nftables/nft.8.en.html)
- [Docker — Firewall with nftables](https://docs.docker.com/engine/network/firewall-nftables/)
- [Libvirt — Firewall and network filtering](https://libvirt.org/firewall.html)

**Editorial note:** This is a working design reference, not a verified inventory of registrations on the running host. The SELinux, connection-tracking helper, bridge, and vendor-owned entries should be checked against the applicable kernel and actual registrations before being treated as authoritative.

TODO: It is possible to have a dual-FORWARD (separate pre-forward/post-forward) here.

