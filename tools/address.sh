#!/usr/bin/env bash
#
# tools/address.sh
#
# IPv4 / IPv6 interface address discovery.
#
# Source:
#   source "${SCRIPT_DIR}/tools/address.sh"
#
# Dependencies:
#   Bash 4+
#   iproute2
#
# Public functions:
#   nft_ipv4_network ADDRESS PREFIX
#   nft_ipv6_network ADDRESS PREFIX
#   nft_discover_addresses
#
# Results:
#   NFT_INTERFACE_IPV4
#   NFT_INTERFACE_IPV6
#   NFT_INTERFACE_IPV4_PREFIX
#   NFT_INTERFACE_IPV6_PREFIX
#   NFT_INTERFACE_IPV4_NETWORK
#   NFT_INTERFACE_IPV6_NETWORK
#   NFT_INTERFACE_IPV4_BROADCAST
#

declare -gA NFT_INTERFACE_IPV4=()
declare -gA NFT_INTERFACE_IPV6=()

declare -gA NFT_INTERFACE_IPV4_PREFIX=()
declare -gA NFT_INTERFACE_IPV6_PREFIX=()

declare -gA NFT_INTERFACE_IPV4_NETWORK=()
declare -gA NFT_INTERFACE_IPV6_NETWORK=()

declare -gA NFT_INTERFACE_IPV4_BROADCAST=()


# ------------------------------------------------------
# IPv4 network calculation
# ------------------------------------------------------

nft_ipv4_network() {
    local addr="${1:-}"
    local prefix="${2:-}"
    local a b c d
    local ip mask network octet

    [[ "$prefix" =~ ^[0-9]+$ ]] || return 1
    prefix=$((10#$prefix))
    (( prefix >= 0 && prefix <= 32 )) || return 1

    [[ "$addr" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1

    IFS=. read -r a b c d <<< "$addr"

    for octet in "$a" "$b" "$c" "$d"; do
        [[ "$octet" =~ ^[0-9]{1,3}$ ]] || return 1
        (( 10#$octet <= 255 )) || return 1
    done

    ip=$(( (10#$a << 24) | (10#$b << 16) |
           (10#$c << 8) | 10#$d ))

    if (( prefix == 0 )); then
        mask=0
    else
        mask=$(( (0xFFFFFFFF << (32-prefix)) & 0xFFFFFFFF ))
    fi

    network=$(( ip & mask ))

    printf '%d.%d.%d.%d\n' \
        "$(( (network >> 24) & 255 ))" \
        "$(( (network >> 16) & 255 ))" \
        "$(( (network >> 8) & 255 ))" \
        "$(( network & 255 ))"
}


# ------------------------------------------------------
# IPv6 network calculation
# ------------------------------------------------------

nft_ipv6_network() {

    local addr="${1:-}"
    local prefix="${2:-}"

    local left right missing
    local -a groups=()
    local -a result=()
    local -a l=()
    local -a r=()

    local i value bits mask network
    local output=""
    local remaining

    [[ -n "$addr" && -n "$prefix" ]] || return 1
    [[ "$prefix" =~ ^[0-9]+$ ]] || return 1

    prefix=$((10#$prefix))
    (( prefix >= 0 && prefix <= 128 )) || return 1

    [[ "$addr" =~ ^[0-9a-fA-F:]+$ ]] || return 1
    [[ "$addr" != *.* ]] || return 1

    # Expand compressed notation.
    if [[ "$addr" == *::* ]]; then

        local remainder="${addr#*::}"
        [[ "$remainder" != *::* ]] || return 1

        left="${addr%%::*}"
        right="${addr#*::}"

        if [[ -n "$left" ]]; then
            IFS=: read -r -a l <<< "$left"
        fi

        if [[ -n "$right" ]]; then
            IFS=: read -r -a r <<< "$right"
        fi

        (( ${#l[@]} + ${#r[@]} < 8 )) || return 1

        missing=$(( 8 - ${#l[@]} - ${#r[@]} ))

        groups=("${l[@]}")

        for ((i=0; i<missing; i++)); do
            groups+=(0)
        done

        groups+=("${r[@]}")

    else

        IFS=: read -r -a groups <<< "$addr"
        (( ${#groups[@]} == 8 )) || return 1

    fi

    (( ${#groups[@]} == 8 )) || return 1

    # Convert hexadecimal groups to integers.
    for ((i=0; i<8; i++)); do

        [[ "${groups[i]}" =~ ^[0-9a-fA-F]{1,4}$ ]] || return 1

        groups[i]=$(( 16#${groups[i]} ))

    done

    # Apply prefix mask.
    remaining=$prefix

    for ((i=0; i<8; i++)); do

        if (( remaining >= 16 )); then
            mask=65535
            remaining=$(( remaining - 16 ))

        elif (( remaining > 0 )); then
            bits=$remaining
            mask=$(( (65535 << (16-bits)) & 65535 ))
            remaining=0

        else
            mask=0
        fi

        value=${groups[i]}
        network=$(( value & mask ))

        printf -v result[i] '%x' "$network"

    done

    # Find longest zero run.
    local best_start=-1
    local best_length=1
    local run_start run_length

    i=0

    while (( i < 8 )); do

        if [[ "${result[i]}" == "0" ]]; then

            run_start=$i
            run_length=0

            while (( i < 8 )) && [[ "${result[i]}" == "0" ]]; do
                run_length=$((run_length + 1))
                i=$((i + 1))
            done

            if (( run_length > best_length )); then
                best_start=$run_start
                best_length=$run_length
            fi

        else
            i=$((i + 1))
        fi

    done

    # Compress address.
    if (( best_start >= 0 )); then

        local before=""
        local after=""

        for ((i=0; i<best_start; i++)); do
            [[ -n "$before" ]] && before+=":"
            before+="${result[i]}"
        done

        for ((i=best_start+best_length; i<8; i++)); do
            [[ -n "$after" ]] && after+=":"
            after+="${result[i]}"
        done

        if [[ -n "$before" && -n "$after" ]]; then
            output="${before}::${after}"
        elif [[ -n "$before" ]]; then
            output="${before}::"
        elif [[ -n "$after" ]]; then
            output="::${after}"
        else
            output="::"
        fi

    else
        output=$(IFS=:; echo "${result[*]}")
    fi

    printf '%s\n' "$output"
}


# ------------------------------------------------------
# Discover interface addresses
# ------------------------------------------------------

nft_discover_addresses() {

    local family output
    local line iface cidr rest
    local address prefix network broadcast
    local -a fields=()

    command -v ip >/dev/null 2>&1 || {
        echo "ERROR: ip command not found." >&2
        return 1
    }

    # Clear previous results.
    NFT_INTERFACE_IPV4=()
    NFT_INTERFACE_IPV6=()

    NFT_INTERFACE_IPV4_PREFIX=()
    NFT_INTERFACE_IPV6_PREFIX=()

    NFT_INTERFACE_IPV4_NETWORK=()
    NFT_INTERFACE_IPV6_NETWORK=()

    NFT_INTERFACE_IPV4_BROADCAST=()

    for family in 4 6; do

        output=$(ip -o "-$family" address show) || {
            echo "ERROR: Unable to retrieve IPv$family addresses." >&2
            return 1
        }

        while IFS= read -r line; do

            # Format:
            # index: interface family address/prefix ...

            read -r _ iface _ cidr rest <<< "$line"

            [[ -n "$iface" && -n "$cidr" ]] || continue

            iface="${iface%%@*}"

            address="${cidr%/*}"
            prefix="${cidr##*/}"

            [[ "$cidr" == */* ]] || continue

            broadcast=""

            if [[ "$family" == 4 ]]; then

                if [[ "$rest" =~ (^|[[:space:]])brd[[:space:]]+([^[:space:]]+) ]]; then
                    broadcast="${BASH_REMATCH[2]}"
                fi

                network=$(nft_ipv4_network "$address" "$prefix") || {
                    echo "WARNING: IPv4 calculation failed: $address/$prefix" >&2
                    continue
                }

                NFT_INTERFACE_IPV4["$iface"]+="${address}"$'\n'
                NFT_INTERFACE_IPV4_PREFIX["$iface"]+="${prefix}"$'\n'
                NFT_INTERFACE_IPV4_NETWORK["$iface"]+="${network}"$'\n'

                if [[ -n "$broadcast" ]]; then
                    NFT_INTERFACE_IPV4_BROADCAST["$iface"]+="${broadcast}"$'\n'
                fi

            else

                network=$(nft_ipv6_network "$address" "$prefix") || {
                    echo "WARNING: IPv6 calculation failed: $address/$prefix" >&2
                    continue
                }

                NFT_INTERFACE_IPV6["$iface"]+="${address}"$'\n'
                NFT_INTERFACE_IPV6_PREFIX["$iface"]+="${prefix}"$'\n'
                NFT_INTERFACE_IPV6_NETWORK["$iface"]+="${network}"$'\n'

            fi

        done <<< "$output"

    done

    return 0
}



# ---------------------------------------------------------------------------
# Unit tests
# ---------------------------------------------------------------------------

address_test() {
    local failures=0

    printf '%s\n' 'Testing address discovery...'

    nft_discover_addresses

    if (( ${#NFT_INTERFACE_IPV4[@]} == 0 )); then
        printf 'FAIL: No IPv4 address discovered.\n' >&2
        ((failures++))
    else
        printf 'PASS: IPv4 address(es) discovered (%d).\n' \
            "${#NFT_INTERFACE_IPV4[@]}"
    fi

    if (( ${#NFT_INTERFACE_IPV6[@]} == 0 )); then
        printf 'FAIL: No IPv6 address discovered.\n' >&2
        ((failures++))
    else
        printf 'PASS: IPv6 address(e) discovered (%d).\n' \
            "${#NFT_INTERFACE_IPV6[@]}"
    fi

    if (( failures == 0 )); then
        printf '%s\n' 'All address tests passed.'
    else
        printf 'Address tests failed: %d\n' "$failures" >&2
    fi

    return "$failures"
}

# ---------------------------------------------------------------------------
# Standalone execution
# ---------------------------------------------------------------------------

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    address_test
    exit $?
fi

