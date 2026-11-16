

nftables/
├── nftables.conf
├── definitions/
└── zones/
    ├── red/
    │   └── interfaces/
    │       └── wan/
    │           └── inet/
    │               └── filter/
    │                   ├── prerouting.nft
    │                   ├── input.nft
    │                   ├── forward.nft
    │                   ├── output.nft
    │                   ├── postrouting.nft
    │                   ├── ingress.nft
    │                   └── egress.nft
    ├── dmz/
    ├── docker/
    ├── libvirt/
    └── closed-net/
