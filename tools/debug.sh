#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Discover network interfaces.
source "${SCRIPT_DIR}/tools/interfaces.sh" || exit 1
source "${SCRIPT_DIR}/tools/address.sh" || exit 1
source "${SCRIPT_DIR}/tools/routing.sh" || exit 1

# Display discovered interfaces.
printf 'Discovered interfaces: %d\n' "$NFT_INTERFACE_COUNT"

for iface in "${NFT_INTERFACES[@]}"; do
    printf '%-16s index=%-4s state=%-12s MAC=%s\n' \
        "$iface" \
        "${NFT_INTERFACE_INDEX[$iface]}" \
        "${NFT_INTERFACE_STATE[$iface]}" \
        "${NFT_INTERFACE_MAC[$iface]}"
done


# Discover interface addresses.
nft_discover_addresses || exit 1

# Display discovered addressing.
for iface in "${NFT_INTERFACES[@]}"; do

    printf '\n%-16s\n' "$iface"

    if [[ -n "${NFT_INTERFACE_IPV4[$iface]:-}" ]]; then
        while IFS= read -r address; do
            [[ -z "$address" ]] && continue
            printf '  IPv4:          %s\n' "$address"
        done <<< "${NFT_INTERFACE_IPV4[$iface]}"

        while IFS= read -r network; do
            [[ -z "$network" ]] && continue
            printf '  IPv4 network:  %s\n' "$network"
        done <<< "${NFT_INTERFACE_IPV4_NETWORK[$iface]}"
    fi

    if [[ -n "${NFT_INTERFACE_IPV6[$iface]:-}" ]]; then
        while IFS= read -r address; do
            [[ -z "$address" ]] && continue
            printf '  IPv6:          %s\n' "$address"
        done <<< "${NFT_INTERFACE_IPV6[$iface]}"

        while IFS= read -r network; do
            [[ -z "$network" ]] && continue
            printf '  IPv6 network:  %s\n' "$network"
        done <<< "${NFT_INTERFACE_IPV6_NETWORK[$iface]}"
    fi

done

routing_discover
printf 'Default gateway: %s\n' "$ROUTING_IPV4_DEFAULT_GATEWAY"
printf 'Default interface: %s\n' "$ROUTING_IPV4_DEFAULT_INTERFACE"

printf '%s\n' "$ROUTING_IPV4_DEFAULT_GATEWAY"
printf '%s\n' "$ROUTING_IPV4_DEFAULT_INTERFACE"

source "${SCRIPT_DIR}/tools/discovery.sh" || exit 1
if (( $DISCOVERY_STATUS != 0 )); then
    printf 'Warning: network discovery completed with errors.\n' >&2
fi
