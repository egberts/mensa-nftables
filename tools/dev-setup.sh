#!/bin/bash
echo "Developer/maintainer setup"

# This file must be sourced, not executed.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    printf 'Error: %s must be sourced, not executed.\n' "$0" >&2
    exit 1
fi

read -e -r -i "$NFT_RULESET" -p "Enter in NFT script file: " RULESET_FILE
if [[ ! -e $RULESET_FILE ]]; then
  echo "File $RULESET_FILE does not exist"
  exit -9
fi
echo "File $RULESET_FILE exists."
if [[ ! -x $RULESET_FILE ]]; then
  echo "File $RULESET_FILE is not readable."
  exit -2
fi
echo "File $RULESET_FILE is readable."

read -e -r -i "$NFT_BINARY" -p "Enter  in NFT binary file: " NFT_BINARY
if [[ ! -e $NFT_BINARY ]]; then
  echo "File $NFT_BINARY does not exist"
  exit -9
fi
echo "File $NFT_BINARY exists."
if [[ ! -x $NFT_BINARY ]]; then
  echo "File $NFT_BINARY is not executable."
  exit -2
fi
echo "File $NFT_BINARY is executable."

binary_dir=$(dirname -- "$(realpath -- "$NFT_BINARY")") || exit 1
echo -e "Testing for $binary_dir directory ..."
if [[ -d $binary_dir ]]; then

  read -e -r \
    -i "${LIBNFTNL_DIRPATH:-}" \
    -p 'Enter libnftnl library directory: ' \
    LIBNFTNL_DIRPATH
  if [[ ! -z "$LIBNFTNL_DIRPATH" ]]; then
    if [[ ! -d "$LIBNFTNL_DIRPATH" ]]; then
      echo "Directory $LIBNFTNL_DIRPATH does not exist or not a directory."
      exit -11
    fi
    LD_LIBRARY_PATH="$LIBNFTNL_DIRPATH${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  fi
  # Add our own library path to LD_LIBRARY_PATH
  LD_LIBRARY_PATH="$binary_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

  # Add our other own library path to LD_LIBRARY_PATH

  export LD_LIBRARY_PATH
  echo "exported."
else
  echo "none found."
fi


export NFT_BINARY=${NFT_BINARY}
export NFT_RULESET=${RULESET_FILE}
