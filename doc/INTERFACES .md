
'iif' or 'iifname'?

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