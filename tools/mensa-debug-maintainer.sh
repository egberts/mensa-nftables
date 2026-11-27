#!/bin/bash

echo "WARNING: nft arguments are defined in .gdbinit 'set args'"

# Add our own library path to LD_LIBRARY_PATH
LD_LIBRARY_PATH="/home/wolfe/work/nft/netfilter.org/nftables/src/.libs:/home/wolfe/work/nft/netfilter.org/libnftnl/src/.libs:$LD_LIBRARY_PATH"

export LD_LIBRARY_PATH

sudo sh -c '
    ulimit -Hn 65536 || exit 1
    ulimit -Sn 65536 || exit 1
    gdb -q -nx \
    -x /home/wolfe/work/git/mensa-nftables/src/.gdbinit /home/wolfe/work/nft/netfilter.org/nftables/src/.libs/nft
'
