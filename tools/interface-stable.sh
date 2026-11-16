
nft_if_stmt() {
    local iface="${1:-}"
    local direction="${2:-iif}"

    local sys="/sys/class/net/$iface"
    local json kind master parent
    local ifindex iflink iftype driver
    local has_device=0 has_wireless=0
    local managed_by=""
    local classification="unknown"
    local confidence="low"
    local reason=""
    local quoted expr
    local container_evidence=0

    if [[ -z "$iface" ]]; then
        echo "Usage: nft_if_stmt INTERFACE [iif|oif]" >&2
        return 2
    fi

    if [[ "$direction" != "iif" && "$direction" != "oif" ]]; then
        echo "Direction must be iif or oif" >&2
        return 2
    fi

    if [[ ! -e "$sys" ]]; then
        echo "ERROR: Interface not found: $iface" >&2
        return 1
    fi

    json=$(ip -j -d link show dev "$iface" 2>/dev/null)

    ifindex=$(cat "$sys/ifindex" 2>/dev/null)
    iflink=$(cat "$sys/iflink" 2>/dev/null)
    iftype=$(cat "$sys/type" 2>/dev/null)

    [[ -e "$sys/device" ]] && has_device=1
    [[ -e "$sys/wireless" ]] && has_wireless=1

    driver=""
    if [[ -L "$sys/device/driver" ]]; then
        driver=$(basename "$(readlink -f "$sys/device/driver")")
    fi

    kind=""
    master=""
    parent=""

    if command -v jq >/dev/null 2>&1 && [[ -n "$json" ]]; then
        kind=$(jq -r '.[0].linkinfo.info_kind // ""' <<< "$json")
        master=$(jq -r '.[0].master // ""' <<< "$json")
        parent=$(jq -r '.[0].link // ""' <<< "$json")
    fi

    # Detect Docker/container-related interfaces.
    if [[ "$iface" == docker0 || "$iface" == br-* ||
          "$iface" == veth* ]]; then
        container_evidence=1
    fi

    if [[ -n "$master" && "$master" == br-* ]]; then
        container_evidence=1
    fi

    if [[ -n "$kind" ]]; then
        case "$kind" in
            veth|macvlan|macvtap|ipvlan)
                container_evidence=1
                ;;
        esac
    fi

    # Interface classification and confidence.
    case "$kind" in
        veth)
            classification="veth"
            confidence="low"
            reason="Ephemeral peer interface."
            ;;

        bridge)
            classification="bridge"
            confidence="medium"
            reason="Logical bridge; may be recreated by network manager."
            ;;

        vlan)
            classification="vlan"
            confidence="medium"
            reason="Logical VLAN; often provisioned at boot."
            ;;

        bond|team)
            classification="$kind"
            confidence="medium"
            reason="Logical aggregation device."
            ;;

        tun|tap)
            classification="$kind"
            confidence="low"
            reason="Typically application-created."
            ;;

        wireguard|vxlan|geneve|gre|gretap|ipip|sit)
            classification="$kind"
            confidence="medium"
            reason="Tunnel interface; lifecycle depends on configuration."
            ;;

        macvlan|macvtap|ipvlan)
            classification="$kind"
            confidence="low"
            reason="Dynamically managed virtual interface."
            ;;

        dummy|ifb|vrf)
            classification="$kind"
            confidence="medium"
            reason="Logical kernel interface."
            ;;

        *)
            if [[ "$iftype" == 772 ]]; then
                classification="loopback"
                confidence="high"
                reason="Kernel loopback interface."
            elif (( has_wireless )); then
                classification="wireless"
                confidence="high"
                reason="Hardware-backed wireless interface."
            elif (( has_device )); then
                classification="physical"
                confidence="high"
                reason="Device-backed interface."
            else
                classification="unknown"
                confidence="low"
                reason="No reliable persistence evidence."
            fi
            ;;
    esac

    # Container indicators override optimistic assumptions.
    if (( container_evidence )); then
        confidence="low"
        reason+=" Container-related naming or topology detected."
    fi

    # Numeric index only when confidence is high or medium
    # and the interface is not container-related.
    if [[ "$confidence" == high || "$confidence" == medium ]] &&
       (( ! container_evidence )); then
        expr="$direction $ifindex"
    else
        quoted="${iface//\\/\\\\}"
        quoted="${quoted//\"/\\\"}"
        expr="${direction}name \"$quoted\""
    fi

    echo "Interface:      $iface" >&2
    echo "Classification: $classification" >&2
    echo "Confidence:     $confidence" >&2
    echo "Kind:           ${kind:-none}" >&2
    echo "Ifindex:        $ifindex" >&2
    echo "Iflink:         $iflink" >&2
    echo "Driver:         ${driver:-none}" >&2
    echo "Master:         ${master:-none}" >&2
    echo "Parent:         ${parent:-none}" >&2
    echo "Reason:         $reason" >&2
    echo "NFT expression: $expr" >&2

    printf '%s\n' "$expr"
}


nft_if_stmt "eno2" "iif"
nft_if_stmt "eno2" "oif"
nft_if_stmt "wlo1" "iif"
nft_if_stmt "wlo1" "oif"
nft_if_stmt "docker0" "iif"
nft_if_stmt "docker0" "oif"
nft_if_stmt "br0" "iif"
nft_if_stmt "br0" "oif"
nft_if_stmt "virbr2" "iif"
nft_if_stmt "virbr2" "oif"
nft_if_stmt "virbr1" "iif"
nft_if_stmt "virbr1" "oif"
nft_if_stmt "virbr0" "iif"
nft_if_stmt "virbr0" "oif"
nft_if_stmt "vnet0" "iif"
nft_if_stmt "vnet0" "oif"
nft_if_stmt "br-c63fe14b8b62" "iif"
nft_if_stmt "br-c63fe14b8b62" "oif"
nft_if_stmt "lo" "iif"
nft_if_stmt "lo" "oif"
