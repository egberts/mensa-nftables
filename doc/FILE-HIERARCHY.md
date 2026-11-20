

nftables/
├── nft-configure.sh
├── tools
├── distro/etc/nftables.conf
├── doc
│   ├── DESIGN.md
│   ├── AGENT.md
├── test
├── Makefile
├── README.md
├── opencode.json
├── src/
│   ├── nftables.nft  # our maintainable but template NFT script file
│   ├── 1-types/   # contains \*.table files
│   ├── 2-hooks/   # contains \*.table_block files
│   ├── 3-bindings/
│   │   ├── devices/
│   │   │   └── DEVICE/  # contains base \*.chain files
│   │   │       ├── rules/
│   │   │       │   └── (rules directory cloned from template-rules/)
│   │   │       └── zones/
│   │   │           └── ZONE/  # contains \*.chain files
│   │   │               └── rules/
│   │   │                   └── (rules directory cloned from template-rules/)
│   │   └── zones/
│   │        └── ZONE/  # contains base \*.chain files
│   │           ├── rules/
│   │           │   └── (rules directory cloned from template-rules/)
│   │           └── devices/
│   │               └── DEVICE/
│   │                   └── rules/
│   │                       └── (rules directory cloned from template-rules/)
│   └── template-rules/
│       ├── <family>-<type>-<hook>/
│       ├── <family>-<type>-<hook>/
│       ├── <family>-<type>-<hook>/
│       └── <family>-<type>-<hook>/
└── build
    ├── etc/
    │   ├── nftables.conf
    │   └── nftables.d/   (still debate on final nft script file count; single, for now)
    ├── types/
    ├── hooks/
    ├── bindings/
    └── devices/
        │   └── DEVICE1/
        │       ├── rules/
        │       │   └── <family>-<type>-<hook>( rules directory cloned from template-rules/)
        │       └── zones/
        │           ├── ZONE1/
        │           │   └── (rules directory cloned from template-rules/)
        │           └── ZONE2/
        │               └── (rules directory cloned from template-rules/)
        └── zones/
             ├── ZONE3/
             │    └── <family>-<type>-<hook>( rules directory cloned from template-rules/)
             ├── ZONE4/
             │    └── <family>-<type>-<hook>( rules directory cloned from template-rules/)
             └── ZONE5/
                 ├── <family>-<type>-<hook>( rules directory cloned from template-rules/)
                 └── devices/
                     ├── DEVICE2/
                     │  └── (rules directory cloned from template-rules/)
                     └── DEVICE3/
                        └── (rules directory cloned from template-rules/)
