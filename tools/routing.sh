#!/usr/bin/env bash
#
# tools/routing.sh
#
# Discover IPv4 and IPv6 routes for nft-config.sh.
#
# Intended use:
#   source "${SCRIPT_DIR}/tools/routing.sh"
#   routing_discover
#
# The script does not modify routing state.  It only reads the kernel
# routing tables with iproute2 and exports the discovered values.
#
# Requires: bash, iproute2
#
# Exported variables:
#   ROUTING_IPV4_ROUTES              All IPv4 routes (one route per line)
#   ROUTING_IPV6_ROUTES              All IPv6 routes (one route per line)
#   ROUTING_IPV4_DEFAULT_ROUTES      IPv4 default routes (one per line)
#   ROUTING_IPV6_DEFAULT_ROUTES      IPv6 default routes (one per line)
#   ROUTING_IPV4_DEFAULT_GATEWAY     First IPv4 default-route gateway, if any
#   ROUTING_IPV4_DEFAULT_INTERFACE  First IPv4 default-route interface, if any
#   ROUTING_IPV4_DEFAULT_METRIC      First IPv4 default-route metric, if any
#   ROUTING_IPV4_DEFAULT_TABLE       First IPv4 default-route table, if any
#   ROUTING_IPV6_DEFAULT_GATEWAY     First IPv6 default-route gateway, if any
#   ROUTING_IPV6_DEFAULT_INTERFACE  First IPv6 default-route interface, if any
#   ROUTING_IPV6_DEFAULT_METRIC      First IPv6 default-route metric, if any
#   ROUTING_IPV6_DEFAULT_TABLE       First IPv6 default-route table, if any
#   ROUTING_IPV4_ROUTE_COUNT         Number of discovered IPv4 routes
#   ROUTING_IPV6_ROUTE_COUNT         Number of discovered IPv6 routes
#
# A route may have no gateway (for example, a directly connected route).
# Default routes may also have no gateway (for example, a point-to-point
# interface); in that case the gateway variable is empty.

# Prevent execution when this file is sourced with a non-Bash shell.
if [[ -z ${BASH_VERSION:-} ]]; then
    printf '%s\n' "routing.sh: this script requires Bash." >&2
    return 1 2>/dev/null || exit 1
fi

_routing_reset_family()
{
    local family=$1

    printf -v "ROUTING_${family}_ROUTES" '%s' ''
    printf -v "ROUTING_${family}_DEFAULT_ROUTES" '%s' ''
    printf -v "ROUTING_${family}_DEFAULT_GATEWAY" '%s' ''
    printf -v "ROUTING_${family}_DEFAULT_INTERFACE" '%s' ''
    printf -v "ROUTING_${family}_DEFAULT_METRIC" '%s' ''
    printf -v "ROUTING_${family}_DEFAULT_TABLE" '%s' ''
    printf -v "ROUTING_${family}_ROUTE_COUNT" '%s' '0'
}

_routing_parse_default()
{
    # Parse one `ip route` line.  Output is tab-separated:
    # gateway, interface, metric, table.
    local line=$1
    local -a fields
    local gateway='' interface='' metric='' table='main'
    local i

    read -r -a fields <<< "$line"

    for ((i = 0; i < ${#fields[@]}; i++)); do
        case ${fields[i]} in
            via)
                ((i + 1 < ${#fields[@]})) && gateway=${fields[i + 1]}
                ;;
            dev)
                ((i + 1 < ${#fields[@]})) && interface=${fields[i + 1]}
                ;;
            metric)
                ((i + 1 < ${#fields[@]})) && metric=${fields[i + 1]}
                ;;
            table)
                ((i + 1 < ${#fields[@]})) && table=${fields[i + 1]}
                ;;
        esac
    done

    printf '%s|%s|%s|%s\n' "$gateway" "$interface" "$metric" "$table"
}

_routing_discover_family()
{
    local family=$1 ip_flag=$2
    local routes defaults line parsed
    local gateway interface metric table

    _routing_reset_family "$family"

    if ! command -v ip >/dev/null 2>&1; then
        printf '%s\n' "routing.sh: required command 'ip' was not found." >&2
        return 1
    fi

    if ! routes=$(ip "$ip_flag" route show table all 2>/dev/null); then
        printf 'routing.sh: unable to discover %s routes.\n' "$family" >&2
        return 1
    fi

    defaults=''
    while IFS= read -r line; do
        [[ -n $line ]] || continue
        if [[ -z ${defaults} ]]; then
            [[ $line == default || $line == default\ * ]] && defaults=$line
        elif [[ $line == default || $line == default\ * ]]; then
            defaults+=$'\n'"$line"
        fi
    done <<< "$routes"

    printf -v "ROUTING_${family}_ROUTES" '%s' "$routes"
    printf -v "ROUTING_${family}_DEFAULT_ROUTES" '%s' "$defaults"

    if [[ -n $routes ]]; then
        local count
        count=$(awk 'NF { n++ } END { print n+0 }' <<< "$routes")
        printf -v "ROUTING_${family}_ROUTE_COUNT" '%s' "$count"
    fi

    if [[ -n $defaults ]]; then
        IFS= read -r line <<< "$defaults"
        parsed=$(_routing_parse_default "$line")
        IFS='|' read -r gateway interface metric table <<< "$parsed"

        printf -v "ROUTING_${family}_DEFAULT_GATEWAY" '%s' "$gateway"
        printf -v "ROUTING_${family}_DEFAULT_INTERFACE" '%s' "$interface"
        printf -v "ROUTING_${family}_DEFAULT_METRIC" '%s' "$metric"
        printf -v "ROUTING_${family}_DEFAULT_TABLE" '%s' "$table"
    fi

    export "ROUTING_${family}_ROUTES"
    export "ROUTING_${family}_DEFAULT_ROUTES"
    export "ROUTING_${family}_DEFAULT_GATEWAY"
    export "ROUTING_${family}_DEFAULT_INTERFACE"
    export "ROUTING_${family}_DEFAULT_METRIC"
    export "ROUTING_${family}_DEFAULT_TABLE"
    export "ROUTING_${family}_ROUTE_COUNT"
}

routing_discover()
{
    local status=0

    _routing_discover_family IPV4 -4 || status=1
    _routing_discover_family IPV6 -6 || status=1

    return "$status"
}

# Initialize exported variables when sourced.  Discovery remains explicit so
# the caller controls when the system is queried.
_routing_reset_family IPV4
_routing_reset_family IPV6
export ROUTING_IPV4_ROUTES ROUTING_IPV4_DEFAULT_ROUTES
export ROUTING_IPV4_DEFAULT_GATEWAY ROUTING_IPV4_DEFAULT_INTERFACE
export ROUTING_IPV4_DEFAULT_METRIC ROUTING_IPV4_DEFAULT_TABLE
export ROUTING_IPV4_ROUTE_COUNT
export ROUTING_IPV6_ROUTES ROUTING_IPV6_DEFAULT_ROUTES
export ROUTING_IPV6_DEFAULT_GATEWAY ROUTING_IPV6_DEFAULT_INTERFACE
export ROUTING_IPV6_DEFAULT_METRIC ROUTING_IPV6_DEFAULT_TABLE
export ROUTING_IPV6_ROUTE_COUNT

# If executed directly, perform discovery and print a concise summary.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    routing_discover || exit $?

    printf 'IPv4 routes: %s\n' "$ROUTING_IPV4_ROUTE_COUNT"
    printf 'IPv4 default: gateway=%s interface=%s metric=%s table=%s\n' \
        "${ROUTING_IPV4_DEFAULT_GATEWAY:-<none>}" \
        "${ROUTING_IPV4_DEFAULT_INTERFACE:-<none>}" \
        "${ROUTING_IPV4_DEFAULT_METRIC:-<unset>}" \
        "${ROUTING_IPV4_DEFAULT_TABLE:-<none>}"

    printf 'IPv6 routes: %s\n' "$ROUTING_IPV6_ROUTE_COUNT"
    printf 'IPv6 default: gateway=%s interface=%s metric=%s table=%s\n' \
        "${ROUTING_IPV6_DEFAULT_GATEWAY:-<none>}" \
        "${ROUTING_IPV6_DEFAULT_INTERFACE:-<none>}" \
        "${ROUTING_IPV6_DEFAULT_METRIC:-<unset>}" \
        "${ROUTING_IPV6_DEFAULT_TABLE:-<none>}"
fi
