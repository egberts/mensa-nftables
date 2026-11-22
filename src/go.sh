#!/bin/bash

echo "Testing nft -c -I . -f nftables.nft ..."
sudo /usr/local/sbin/nft -c -I . -f nftables.nft
RETSTS=$?
if [[ $RETSTS == 0 ]]; then
  echo "Passed"
  # sudo /usr/local/sbin/nft -c -d scanner -I . -f nftables.nft 2>&1 | grep -E "{types|hooks|bindings|zones|devices}" | grep -E "accepting rule at line [0-9]{1,6} \(\"\""
  sudo strace -f /usr/local/sbin/nft -c -d scanner -I . -f nftables.nft 2>&1 | grep home | grep open
  RETSTS=$?
  if [[ $RETSTS == 0 ]]; then
    echo "Yep, passed"
  else
    echo "Scanner Error status $RETSTS"
  fi
else
  echo "Error status $RETSTS"
fi
