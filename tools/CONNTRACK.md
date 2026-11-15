Classify as `notrack` in base chain declaration based on whether it needs connection tracking.

Usage criteria of `notrack`:
* typically used in `prerouting` and `output` base chain type.

A useful rule of thumb:

* Stateless, predictable UDP: Consider `notrack`.
* UDP requiring bidirectional state awareness: Keep conntrack.
* UDP involving NAT: Keep conntrack unless deliberately implementing stateless NAT.
* Dynamic UDP protocols: Generally keep conntrack.


UDP protocol
====
Ephemeral ports are not the deciding factor
Consider these examples:

| UDP traffic | Typical ports | notrack suitability |
|----|----|----|
| DNS queries | 53 → ephemeral | Depends |
| NTP | ephemeral → 123 | Often suitable |
| SNMP polling | ephemeral → 161 | Often suitable |
| Syslog | ephemeral → 514 | Often suitable |
| DHCP | 68 → 67 | Depends |
| VoIP / RTP | Dynamic port ranges | Usually track |
| WireGuard | Ephemeral → 51820 | Usually track |
| QUIC | Ephemeral → 443 | Usually track |

Why 'notrack' works only in `prerouting` and `output` hooks?:

* `prerouting` allows you to bypass conntrack for incoming packets.
* `output` allows you to bypass conntrack for locally generated packets.
* `input` and `postrouting` are too late.


Example ruleset:

```
#!/usr/sbin/nft -f

table inet filter {

    #
    # NOTRACK: bypass connection tracking
    #

    chain prerouting_raw {
        type filter hook prerouting priority raw;
        policy accept;

        # NTP requests from approved client
        ip saddr 192.0.2.20 \
            udp sport 1024-65535 udp dport 123 \
            notrack
    }

    chain output_raw {
        type filter hook output priority raw;
        policy accept;

        # NTP responses to approved client
        ip daddr 192.0.2.20 \
            udp sport 123 udp dport 1024-65535 \
            notrack
    }

    #
    # INPUT: default-deny ingress policy
    #

    chain input {
        type filter hook input priority filter;
        policy drop;

        # Reject invalid tracked packets
        ct state invalid drop

        # Regular connection tracking
        ct state established,related accept

        # Stateless NTP requests
        ip saddr 192.0.2.20 \
            udp sport 1024-65535 udp dport 123 \
            ct state untracked accept

        # Stateful SSH connections
        ip saddr 198.51.100.10 \
            tcp dport 22 ct state new accept
    }

    #
    # OUTPUT: default-deny egress policy
    #

    chain output {
        type filter hook output priority filter;
        policy drop;

        # Reject invalid tracked packets
        ct state invalid drop

        # Regular connection tracking
        ct state established,related accept

        # Stateless NTP responses
        ip daddr 192.0.2.20 \
            udp sport 123 udp dport 1024-65535 \
            ct state untracked accept
    }
}
```

TCP protocol
====
'notrack' is used less so in TCP protocol.

Some criteria:

| Protocol / application | Recommendation
|------------------------|---|
| TCP SSH                | Keep conntrack
| TCP HTTPS              | Keep conntrack
| TCP SMTP               | Keep conntrack
| TCP FTP | Keep conntrack (especially when helpers are involved)
| TCP high-volume specialized traffic | Consider notrack if genuinely necessary
| TCP SYN flood protection | Consider SYNPROXY

With normal TCP connection tracking:

```commandline
ct state established,related accept
ct state invalid drop
ct state new tcp dport 22 accept
```

With `notrack`, it becomes:
```commandline
ct state untracked
```

SYNPROXY
----

One particularly interesting TCP application of `notrack`: `SYNPROXY`.

`SYNPROXY` is designed to mitigate TCP SYN-flood attacks.

It deliberately marks incoming SYN packets as untracked:

```
table inet synproxy_example {

    chain prerouting_raw {
        type filter hook prerouting priority raw;
        policy accept;

        tcp dport 443 tcp flags syn notrack
    }

    chain input {
        type filter hook input priority filter;
        policy drop;

        ct state invalid,untracked \
            tcp dport 443 \
            synproxy mss 1460 wscale 7 timestamp sack-perm

        ct state invalid drop

        ct state established,related accept
    }
}
```