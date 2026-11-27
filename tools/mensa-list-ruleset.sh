#!/bin/bash

NFT_BINARY_DEFAULT=nft
RULESET_DEFAULT=nftables.conf

echo "$0: List ruleset ..."
echo "User-supplied RULESET: ${NFT_RULESET}"
echo "User-supplied NFT_BINARY: ${NFT_BINARY}"
# Default if $NFT_BINARY is missing or empty
NFT_BINARY="${NFT_BINARY:-${NFT_BINARY_DEFAULT}}"

# Default if $NFT_RULESET is missing or empty
RULESET="${1:-${NFT_RULESET:-${RULESET_DEFAULT}}}"

echo
echo "Current working directory: ${PWD}"
echo "Current nft script: ${RULESET}"
echo "Current nft binary: ${NFT_BINARY}"
if [[ ! -x "$NFT_BINARY" ]]; then
  echo "File $NFT_BINARY is not found nor an executable."
  exit -9
fi

if [[ ! -r "$RULESET" ]]; then
  echo "File $RULESET is not found nor readable."
  exit -9
fi
echo
echo "Testing $NFT_BINARY -I . -f ${RULESET} ..."
sudo sh -c '
    ulimit -Hn 65536 || exit 1
    ulimit -Sn 65536 || exit 1
    exec "$1" "$2" "$3"
' sh "$NFT_BINARY" "list" "ruleset"

RETSTS=$?
if [[ $RETSTS == 0 ]]; then
  echo "Passed"
else
  echo "Error status $RETSTS"
fi
