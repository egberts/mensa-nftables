
'iif' or 'iifname'?
===

When deciding on 'iif' vs. 'iifname' statement from a
network cybersecurity versus '''nf_tables''' kernel
performance, the following table offers a guidelines:

| Interface category | Preferred selector | Reason                           |
|--------------------|--------------------|----------------------------------|
| Loopback (lo)      | `iif`                | Permanent, predictable interface |
| Physical WAN	| `iif`	| Stable interface identity
| Physical LAN | `iif` | Stable interface identity
| VLAN interfaces | `iif` | Normally stable configuration
| WireGuard interfaces | Depends | Dynamic lifecycle versus fixed identity
| Docker veth interfaces | `iifname` | Dynamically created and destroyed
| Libvirt tap/vnet interfaces | `iifname` | Dynamically created and destroyed
| PPP interfaces | iifname | Dynamic interface lifecycle

Subdevices
===

| Interface technology | Parent can have IP? | Children can have IPs?
|----------------------|---|---|
| VLAN                 | Yes | Yes
| MACVLAN              | Yes, with caveats | Yes
| IPVLAN               | Yes, with caveats | Yes |Â
| GRE                  | Yes | Yes |Â
| VXLAN                | Yes | Yes |Â
| TUN/TAP              | Yes | Yes |Â
| Linux bridge         | Yes, depending on port configuration | Yes, via VLAN/other virtual interfaces |Â
| Bonding              | Yes | Yes, via VLAN interfaces |Â
| PPP                  | Yes | Yes, on separate PPP units |Â
|  Frame Relay         | Yes, depending on encapsulation/configuration | Yes, via DLCIs |Â

~
~
