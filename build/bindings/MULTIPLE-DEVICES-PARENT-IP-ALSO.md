Parent and child IP address support
===

| Interface technology | Parent can have IP? | Children can have IPs?
|----------------------|---|---|
| VLAN                 | Yes | Yes
| MACVLAN              | Yes, with caveats | Yes
| IPVLAN               | Yes, with caveats | Yes | 
| GRE                  | Yes | Yes | 
| VXLAN                | Yes | Yes | 
| TUN/TAP              | Yes | Yes | 
| Linux bridge         | Yes, depending on port configuration | Yes, via VLAN/other virtual interfaces | 
| Bonding              | Yes | Yes, via VLAN interfaces | 
| PPP                  | Yes | Yes, on separate PPP units | 
|  Frame Relay         | Yes, depending on encapsulation/configuration | Yes, via DLCIs | 

