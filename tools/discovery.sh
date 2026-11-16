#!/usr/bin/env bash
#
# discovery.sh
#
# Network discovery coordinator for nft-config.sh.
#
# Sources individual discovery modules and invokes their
# discovery functions. Discovered variables remain available
# to the calling shell when this script is sourced.
#

# This script must be sourced, not executed.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    printf 'Error: discovery.sh must be sourced.\n' >&2
    exit 1
fi

# Resolve tools directory.
DISCOVERY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Overall discovery status.
DISCOVERY_STATUS=0

# Discovery modules and their corresponding functions.
_discovery_modules=(
    interfaces.sh:_nft_discover_interfaces
    address.sh:nft_discover_addresses
    routing.sh:routing_discover
)

# Load and execute discovery modules.
for entry in "${_discovery_modules[@]}"; do
    module="${entry%%:*}"
    function="${entry##*:}"
    module_path="${DISCOVERY_DIR}/${module}"

    if [[ ! -r "$module_path" ]]; then
        printf 'Error: discovery module unavailable: %s\n' \
            "$module_path" >&2
        DISCOVERY_STATUS=1
        continue
    fi

    if ! source "$module_path"; then
        printf 'Error: failed to load module: %s\n' \
            "$module_path" >&2
        DISCOVERY_STATUS=1
        continue
    fi

    if ! declare -F "$function" >/dev/null; then
        printf 'Error: discovery function not defined: %s\n' \
            "$function" >&2
        DISCOVERY_STATUS=1
        continue
    fi

    if ! "$function"; then
        printf 'Warning: discovery function failed: %s\n' \
            "$function" >&2
        DISCOVERY_STATUS=1
    fi
done

# Export overall discovery status.
export DISCOVERY_STATUS

# Clean up coordinator variables.
unset entry module function module_path
unset _discovery_modules
