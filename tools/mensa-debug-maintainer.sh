#!/bin/bash


# Add our own library path to LD_LIBRARY_PATH
LD_LIBRARY_PATH="/home/wolfe/work/nft/netfilter.org/nftables/src/.libs:$LD_LIBRARY_PATH"

# Some systems cannot cope with colon-terminated LD_LIBRARY_PATH
# The second colon is a workaround for a bug in BeOS R4 sed
#LD_LIBRARY_PATH=`$ECHO "$LD_LIBRARY_PATH" | /usr/bin/sed 's/::*$//'`


export LD_LIBRARY_PATH

sudo sh -c '
    ulimit -Hn 65536 || exit 1
    ulimit -Sn 65536 || exit 1
    gdb -q -nx \
    -x /home/wolfe/work/git/mensa-nftables/src/.gdbinit /home/wolfe/work/nft/netfilter.org/nftables/src/.libs/nft
'
