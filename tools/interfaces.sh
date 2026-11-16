#!/usr/bin/env bash
#
# interface.sh
#
# Discover network interfaces using iproute2.
#
# Usage:
#   source "${SCRIPT_DIR}/tools/interface.sh"
#
# Variables populated:
#   NFT_INTERFACES[]          Interface names
#   NFT_INTERFACE_INDEX[]    Kernel interface indices
#   NFT_INTERFACE_MAC[]      MAC addresses
#   NFT_INTERFACE_STATE[]    Operational states
#   NFT_INTERFACE_FLAGS[]    Interface flags
#   NFT_INTERFACE_LINK_TYPE[] Link-layer types
#   NFT_INTERFACE_COUNT      Number of discovered interfaces
#
# Requirements:
#   Bash 4+
#   iproute2
#

_nft_discover_interfaces()
{
    local output
    local line
    local index
    local name
    local flags
    local state
    local link_type
    local mac

    if ! command -v ip >/dev/null 2>&1; then
        printf 'ERROR: iproute2 command not found.\n' >&2
        return 1
    fi

    if ! output=$(ip -o link show 2>/dev/null); then
        printf 'ERROR: Unable to discover network interfaces.\n' >&2
        return 1
    fi

    # Initialize exported module data.
    declare -ga NFT_INTERFACES=()

    declare -gA NFT_INTERFACE_INDEX=()
    declare -gA NFT_INTERFACE_MAC=()
    declare -gA NFT_INTERFACE_STATE=()
    declare -gA NFT_INTERFACE_FLAGS=()
    declare -gA NFT_INTERFACE_LINK_TYPE=()

    NFT_INTERFACE_COUNT=0

    while IFS= read -r line; do

        # Extract interface index, name, and flags.
        if [[ ! $line =~ ^([0-9]+):[[:space:]]+([^:]+):[[:space:]]+\<([^>]*)\> ]]; then
            continue
        fi

        index=${BASH_REMATCH[1]}
        name=${BASH_REMATCH[2]}
        flags=${BASH_REMATCH[3]}

        # Remove peer-interface suffixes such as @if3.
        name=${name%%@*}

        # Extract operational state.
        state=UNKNOWN

        if [[ $line =~ [[:space:]]state[[:space:]]+([^[:space:]]+) ]]; then
            state=${BASH_REMATCH[1]}
        fi

        # Extract link-layer type and address.
        link_type=unknown
        mac=

        if [[ $line =~ link/([^[:space:]]+)[[:space:]]+([^[:space:]]+) ]]; then
            link_type=${BASH_REMATCH[1]}
            mac=${BASH_REMATCH[2]}

            # Do not treat broadcast addresses as MAC addresses.
            if [[ $mac == *:* ]]; then
                :
            else
                mac=
            fi
        fi

        # Populate discovery results.
        NFT_INTERFACES+=("$name")

        NFT_INTERFACE_INDEX["$name"]=$index
        NFT_INTERFACE_MAC["$name"]=$mac
        NFT_INTERFACE_STATE["$name"]=$state
        NFT_INTERFACE_FLAGS["$name"]=$flags
        NFT_INTERFACE_LINK_TYPE["$name"]=$link_type

        ((NFT_INTERFACE_COUNT += 1))

    done <<< "$output"

    return 0
}




routing_test() {
    local failures=0

    printf '%s\n' 'Testing interfaces discovery...'

    # Perform discovery when this module is sourced.
    _nft_discover_interfaces || return 1

    if (( ${#NFT_INTERFACES[@]} == 0 )); then
        printf 'FAIL: No IPv4 interface discovered.\n' >&2
        ((failures++))
    else
        printf 'PASS: IPv4 interface(s) discovered (%d).\n' \
            "${#NFT_INTERFACES[@]}"
    fi

    if (( failures == 0 )); then
        printf '%s\n' 'All interfaces tests passed.'
    else
        printf 'Interfaces tests failed: %d\n' "$failures" >&2
    fi

    return "$failures"
}

# ---------------------------------------------------------------------------
# Standalone execution
# ---------------------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    routing_test
    exit $?
fi

