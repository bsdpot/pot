#!/bin/sh

# system utilities stubs
ifconfig() {
	if [ -z "$1" ]; then
		cat << EOF--
em0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	options=200080<VLAN_HWCSUM,RXCSUM_IPV6>
	inet 192.168.0.1 netmask 0xffffff00 broadcast 192.168.178.255
	ether e4:b3:18:d8:4d:25
	hwaddr c8:5b:76:3a:2f:96
	nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
	media: Ethernet autoselect
	status: no carrier
em1: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	options=200080<VLAN_HWCSUM,RXCSUM_IPV6>
	inet 10.192.168.2 netmask 0xffffff00 broadcast 10.192.168.255
	ether e4:b3:18:d8:4d:45
	hwaddr c8:5b:76:3a:2f:a6
	nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
	media: Ethernet autoselect
	status: no carrier
bce0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	options=200080<VLAN_HWCSUM,RXCSUM_IPV6>
	inet 10.192.168.3 netmask 0xffffff00 broadcast 10.192.168.255
	ether e4:b3:18:d8:4d:35
	hwaddr c8:5b:76:3a:2f:b6
	nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
	media: Ethernet autoselect
	status: no carrier
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> metric 0 mtu 16384
	options=600003<RXCSUM,TXCSUM,RXCSUM_IPV6,TXCSUM_IPV6>
	inet6 ::1 prefixlen 128
	inet6 fe80::1%lo0 prefixlen 64 scopeid 0x2
	inet 127.0.0.1 netmask 0xff000000
	nd6 options=21<PERFORMNUD,AUTO_LINKLOCAL>
	groups: lo
bridge0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	ether 02:87:a9:03:d7:00
	inet 10.192.0.111 netmask 0xffc00000 broadcast 10.255.255.255
	nd6 options=1<PERFORMNUD>
	groups: bridge
	id 00:00:00:00:00:00 priority 32768 hellotime 2 fwddelay 15
	maxage 20 holdcnt 6 proto rstp maxaddr 2000 timeout 1200
	root id 00:00:00:00:00:00 priority 32768 ifcost 0 port 0
bridge1: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	ether 02:87:a9:03:d7:00
	inet 10.192.0.11 netmask 0xffc00000 broadcast 10.255.255.255
	nd6 options=1<PERFORMNUD>
	groups: bridge
	id 00:00:00:00:00:00 priority 32768 hellotime 2 fwddelay 15
	maxage 20 holdcnt 6 proto rstp maxaddr 2000 timeout 1200
	root id 00:00:00:00:00:00 priority 32768 ifcost 0 port 0
bridge2: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	ether 02:87:a9:03:d7:00
	inet 10.192.0.1 netmask 0xffc00000 broadcast 10.255.255.255
	nd6 options=1<PERFORMNUD>
	groups: bridge
	id 00:00:00:00:00:00 priority 32768 hellotime 2 fwddelay 15
	maxage 20 holdcnt 6 proto rstp maxaddr 2000 timeout 1200
	root id 00:00:00:00:00:00 priority 32768 ifcost 0 port 0
EOF--
		return 0 # true
	elif [ "$1" = "-g" ] && [ "$2" = "bridge" ]; then
		cat << EOF--
bridge0
bridge1
bridge2
EOF--
		return 0 # true
	elif [ "$1" = "bridge0" ]; then
		cat << EOF--
bridge0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	inet 10.192.0.111 netmask 0xffc00000 broadcast 10.255.255.255
EOF--
		return 0 # true
	elif [ "$1" = "bridge1" ]; then
		cat << EOF--
bridge1: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	inet 10.192.0.11 netmask 0xffc00000 broadcast 10.255.255.255
EOF--
		return 0 # true
	elif [ "$1" = "bridge2" ]; then
		cat << EOF--
bridge2: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	inet 10.192.0.1 netmask 0xffc00000 broadcast 10.255.255.255
EOF--
		return 0 # true
	elif [ "$1" = "em0" ]; then
		cat << EOF--
em0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	options=200080<VLAN_HWCSUM,RXCSUM_IPV6>
	inet 192.168.0.1 netmask 0xffffff00 broadcast 192.168.178.255
	ether e4:b3:18:d8:4d:25
	hwaddr c8:5b:76:3a:2f:96
	nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
	media: Ethernet autoselect
	status: no carrier
EOF--
		return 0 # true
	elif [ "$1" = "em1" ]; then
		cat << EOF--
em1: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	options=200080<VLAN_HWCSUM,RXCSUM_IPV6>
	inet 10.192.168.1 netmask 0xffffff00 broadcast 10.192.168.255
	ether e4:b3:18:d8:4d:25
	hwaddr c8:5b:76:3a:2f:96
	nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
	media: Ethernet autoselect
	status: no carrier
EOF--
		return 0 # true
	elif [ "$1" = "bce0" ]; then
		cat << EOF--
bce0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	options=200080<VLAN_HWCSUM,RXCSUM_IPV6>
	inet 10.192.168.3 netmask 0xffffff00 broadcast 10.192.168.255
	ether e4:b3:18:d8:4d:35
	hwaddr c8:5b:76:3a:2f:b6
	nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
	media: Ethernet autoselect
	status: no carrier
EOF--
		return 0 # true
	else
		return 1 # false
	fi
}

# system utilities stubs
potnet()
{
	if [ "$1" = "next" ]; then
		if [ -n "$3" ]; then
			echo "10.192.123.234"
		else
			echo "10.192.123.123"
		fi
		return 0 # true
	fi
	if [ "$1" = "validate" ] && [ "$2" = "-H" ] ; then
		if [ "$3" = "10.192.123.123" ] || [ "$3" = "10.192.123.234" ] ||
			[ "$3" = "10.1.10.10" ]; then
			return 0 # true
		fi
	fi
	if [ "$1" = "ipcheck" ]; then
		case "$3" in
			192.168.200.200|10.192.123.234|10.1.10.10)
				;;
			2a0a:fade:dead:01e::80|2a0a:fade:dead:01e::443)
				;;
			*)
				return 1
				;;
		esac
		return 0 # true
	fi
	if [ "$1" = "ip4check" ]; then
		case "$3" in
			192.168.200.200|10.192.123.234|10.1.10.10)
				;;
			*)
				return 1
				;;
		esac
		return 0 # true
	fi
	if [ "$1" = "ip6check" ]; then
		case "$3" in
			2a0a:fade:dead:01e::80|2a0a:fade:dead:01e::443)
				;;
			*)
				return 1
				;;
		esac
		return 0 # true
	fi
	return 1 # false
}

# UUT
. ../share/pot/network.sh

. ../share/pot/common.sh

# add common stub

_is_vnet_available()
{
	return 0 # true
}

_is_potnet_available()
{
	return 0 # true
}

_get_network_stack()
{
	if [ -z "$STUB_STACK" ]; then
		echo dual
	else
		echo "$STUB_STACK"
	fi
}

_get_pot_network_stack()
{
	_get_network_stack
}

_is_bridge()
{
	case "$1" in
		test-bridge)
			return 0 # return true
			;;
	esac
	return 1 # false
}

# app specific stubs

test_get_pot_rdr_anchor_name_001()
{
	_rc="$(_get_pot_rdr_anchor_name "test-pot" )"
	assertEquals "test-pot" "$_rc"
}

test_get_pot_rdr_anchor_name_002()
{
	_rc="$(_get_pot_rdr_anchor_name "0123456789012345678901234567890123456789012345678901234" )"
	assertEquals "0123456789012345678901234567890123456789012345678901234" "$_rc"
}

test_get_pot_rdr_anchor_name_003()
{
	_rc="$(_get_pot_rdr_anchor_name "01234567890123456789012345678901234567890123456789012345" )"
	assertEquals "1234567890123456789012345678901234567890123456789012345" "$_rc"
}

test_get_pot_rdr_anchor_name_004()
{
	_rc="$(_get_pot_rdr_anchor_name "012345678901234567890123456789012345678901234567890123456789" )"
	assertEquals "5678901234567890123456789012345678901234567890123456789" "$_rc"
}

test_get_pot_rdr_anchor_name_005()
{
	_rc="$(_get_pot_rdr_anchor_name "01234_678901234567890123456789012345678901234567890123456789" )"
	assertEquals "678901234567890123456789012345678901234567890123456789" "$_rc"
}

test_get_pot_rdr_anchor_name_006()
{
	_rc="$(_get_pot_rdr_anchor_name "01234___8901234567890123456789012345678901234567890123456789" )"
	assertEquals "8901234567890123456789012345678901234567890123456789" "$_rc"
}

test_pot_bridge_001()
{
	# shellcheck disable=SC2039
	local _rc
	POT_GATEWAY=10.192.0.111
	_rc="$(_pot_bridge )"
	assertEquals "bridge0" "$_rc"

	POT_GATEWAY=192.168.0.1
	_rc="$(_pot_bridge )"
	assertEquals "" "$_rc"

	POT_GATEWAY=10.192.0.1
	_rc="$(_pot_bridge )"
	assertEquals "bridge2" "$_rc"
}

test_pot_is_valid_netif_001()
{
	_is_valid_netif bridge2
	assertTrue "netif not recognized" "$?"
}

test_pot_is_valid_netif_002()
{
	_is_valid_netif not-netif
	assertFalse "netif wrongly recognized" "$?"
}

test_validate_alias_ipaddr_001()
{
	assertTrue "address not recognized" '_validate_alias_ipaddr "192.168.200.200" "dual"'
}

test_get_alias_ipv4_001()
{
	ipaddr="192.168.200.200"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "bce0|192.168.200.200" "$output"

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "bce0|192.168.200.200" "$output"

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "bce0|192.168.200.200" "$output"

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "" "$output"
}

test_validate_alias_ipaddr_002()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "em0|192.168.200.200" "dual"'
}

test_get_alias_ipv4_002()
{
	ipaddr="em0|192.168.200.200"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200" "$output"

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200" "$output"

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200" "$output"

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "" "$output"
}

test_validate_alias_ipaddr_003()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "em0|192.168.200.200 10.1.10.10" "dual"'
}

test_get_alias_ipv4_003()
{
	ipaddr="em0|192.168.200.200 10.1.10.10"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200,bce0|10.1.10.10" "$output"

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200,bce0|10.1.10.10" "$output"

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200,bce0|10.1.10.10" "$output"

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "" "$output"
}

test_validate_alias_ipaddr_004()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "10.1.10.10 em0|192.168.200.200" "dual"'
}

test_get_alias_ipv4_004()
{
	ipaddr="10.1.10.10 em0|192.168.200.200"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "bce0|10.1.10.10,em0|192.168.200.200" "$output"

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "bce0|10.1.10.10,em0|192.168.200.200" "$output"

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "bce0|10.1.10.10,em0|192.168.200.200" "$output"

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "" "$output"
}

test_validate_alias_ipaddr_005()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "em0|192.168.200.200 em1|10.1.10.10" "dual"'
}

test_get_alias_ipv4_005()
{
	ipaddr="em0|192.168.200.200 em1|10.1.10.10"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200,em1|10.1.10.10" "$output"

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200,em1|10.1.10.10" "$output"

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200,em1|10.1.10.10" "$output"

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "" "$output"
}

test_validate_alias_ipaddr_006()
{
	assertFalse "NIC|address shouldn't be accepted" '_validate_alias_ipaddr "em0|192.168.200.200 em1|10.1.10.10" "ipv6"'
}

test_validate_alias_ipaddr_010()
{
	assertTrue "address not recognized" '_validate_alias_ipaddr "2a0a:fade:dead:01e::80" "dual"'
}

test_get_alias_ipv4_010()
{
	ipaddr="2a0a:fade:dead:01e::80"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'
}

test_validate_alias_ipaddr_011()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "em0|2a0a:fade:dead:01e::80" "dual"'
}

test_get_alias_ipv4_011()
{
	ipaddr="em0|2a0a:fade:dead:01e::80"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'
}

test_validate_alias_ipaddr_012()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "em0|2a0a:fade:dead:01e::80 2a0a:fade:dead:01e::443" "dual"'
}

test_get_alias_ipv4_012()
{
	ipaddr="em0|2a0a:fade:dead:01e::80 2a0a:fade:dead:01e::443"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'
}

test_validate_alias_ipaddr_013()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "2a0a:fade:dead:01e::443 em0|2a0a:fade:dead:01e::80" "dual"'
}

test_get_alias_ipv4_013()
{
	ipaddr="2a0a:fade:dead:01e::443 em0|2a0a:fade:dead:01e::80"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'
}

test_validate_alias_ipaddr_014()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "em0|2a0a:fade:dead:01e::80 em1|2a0a:fade:dead:01e::443" "dual"'
}

test_get_alias_ipv4_014()
{
	ipaddr="em0|2a0a:fade:dead:01e::80 em1|2a0a:fade:dead:01e::443"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'
}

test_validate_alias_ipaddr_015()
{
	assertFalse "NIC|address shouldn't be accepted" '_validate_alias_ipaddr "em0|2a0a:fade:dead:01e::80 em1|2a0a:fade:dead:01e::443" "ipv4"'
}

test_validate_alias_ipaddr_020()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "em0|2a0a:fade:dead:01e::80 em1|192.168.200.200" "dual"'
}

test_get_alias_ipv4_020()
{
	ipaddr="em0|2a0a:fade:dead:01e::80 em1|192.168.200.200"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em1|192.168.200.200" "$output"

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em1|192.168.200.200" "$output"

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em1|192.168.200.200" "$output"

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'
}

test_validate_alias_ipaddr_021()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "em0|2a0a:fade:dead:01e::80 em0|192.168.200.200" "dual"'
}

test_get_alias_ipv4_021()
{
	ipaddr="em0|2a0a:fade:dead:01e::80 em0|192.168.200.200"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200" "$output"

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200" "$output"

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "em0|192.168.200.200" "$output"

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'
}

test_validate_alias_ipaddr_022()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "2a0a:fade:dead:01e::80 192.168.200.200" "dual"'
}

test_get_alias_ipv4_022()
{
	ipaddr="2a0a:fade:dead:01e::80 192.168.200.200"
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "bce0|192.168.200.200" "$output"

	STUB_STACK=ipv4
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "bce0|192.168.200.200" "$output"

	STUB_STACK=dual
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertEquals "alias_ipv4 is wrong" "bce0|192.168.200.200" "$output"

	STUB_STACK=ipv6
	output="$( _get_alias_ipv4 test-pot "$ipaddr")"
	assertTrue "alias_ipv4 is wrong" '[ -z "$output"]'
}

test_validate_alias_ipaddr_023()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "2a0a:fade:dead:01e::80 192.168.200.200" "ipv4"'
}

test_validate_alias_ipaddr_024()
{
	assertTrue "NIC|address not recognized" '_validate_alias_ipaddr "2a0a:fade:dead:01e::80 192.168.200.200" "ipv6"'
}

test_validate_network_param_001()
{
	if ipaddr="$(_validate_network_param "no-network")" ; then
		fail "Invalid network type not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" 'no-network'
	fi
}

test_validate_network_param_002()
{
	if ipaddr="$(_validate_network_param "no-network" "ignored1" "ignored2")" ; then
		fail "Invalid network type not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" 'no-network'
	fi
}

test_validate_network_param_010()
{
	if ipaddr="$(_validate_network_param "inherit" "ignored1" "ignored2")" ; then
		assertTrue "ip addr should be empty" "[ -z $ipaddr ]"
	else
		fail "Valid inherit config not recognized"
	fi
}

test_validate_network_param_020()
{
	if ipaddr="$(_validate_network_param "alias" "" "")" ; then
		fail "Invalid alias config not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" 'mandatory'
	fi
}

test_validate_network_param_021()
{
	if ipaddr="$(_validate_network_param "alias" "auto" "no-bridge")" ; then
		fail "Invalid alias config not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" 'auto'
	fi
}

test_validate_network_param_022()
{
	if ipaddr="$(_validate_network_param "alias" "500.0.0.1" "no-bridge")" ; then
		fail "Invalid alias config not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" "500.0.0.1"
	fi
}

test_validate_network_param_023()
{
	if ipaddr="$(_validate_network_param "alias" "192.168.200.200" "no-bridge")" ; then
		assertEquals "Wrong ip returned " "192.168.200.200" "$ipaddr"
	else
		fail "Valid alias config not recognized"
	fi
}

test_validate_network_param_024()
{
	if ipaddr="$(_validate_network_param "alias" "em0|192.168.200.200" "no-bridge")" ; then
		assertEquals "Wrong ip returned " "em0|192.168.200.200" "$ipaddr"
	else
		fail "Valid alias config not recognized"
	fi
}

test_validate_network_param_025()
{
	if ipaddr="$(_validate_network_param "alias" "em0|192.168.200.200 10.1.10.10" "no-bridge")" ; then
		assertEquals "Wrong ip returned " "em0|192.168.200.200 10.1.10.10" "$ipaddr"
	else
		fail "Valid alias config not recognized"
	fi
}

test_validate_network_param_026()
{
	if ipaddr="$(_validate_network_param "alias" "em0|192.168.200.200 em1|10.1.10.10" "no-bridge")" ; then
		assertEquals "Wrong ip returned " "em0|192.168.200.200 em1|10.1.10.10" "$ipaddr"
	else
		fail "Valid alias config not recognized"
	fi
}

test_validate_network_param_027()
{
	if ipaddr="$(_validate_network_param "alias" "em0|192.168.200.200 em1|10.1.10.10" "" "dual")" ; then
		assertEquals "Wrong ip returned " "em0|192.168.200.200 em1|10.1.10.10" "$ipaddr"
	else
		fail "Valid alias config not recognized"
	fi
}

test_validate_network_param_028()
{
	if ipaddr="$(_validate_network_param "alias" "em0|192.168.200.200 em1|10.1.10.10" "" "ipv4")" ; then
		assertEquals "Wrong ip returned " "em0|192.168.200.200 em1|10.1.10.10" "$ipaddr"
	else
		fail "Valid alias config not recognized"
	fi
}

test_validate_network_param_029()
{
	if ipaddr="$(_validate_network_param "alias" "em0|192.168.200.200 em1|10.1.10.10" "" "ipv6")" ; then
		fail "Invalid alias config not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" "ipv6"
		assertContains "Wrong error message" "$ipaddr" "em0|192.168.200.200 em1|10.1.10.10"
	fi
}

test_validate_network_param_040()
{
	if ipaddr="$(_validate_network_param "public-bridge" "500.0.0.1" "no-bridge")" ; then
		fail "Invalid public-bridge config not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" "500.0.0.1"
	fi
}

test_validate_network_param_041()
{
	if ipaddr="$(_validate_network_param "public-bridge" "" "")" ; then
		assertEquals "Wrong ip returned " "10.192.123.123" "$ipaddr"
	else
		fail "Valid public-bridge config not recognized - $ipaddr"
	fi
}

test_validate_network_param_042()
{
	if ipaddr="$(_validate_network_param "public-bridge" "10.192.123.123" "no-bridge")" ; then
		assertEquals "Wrong ip returned " "10.192.123.123" "$ipaddr"
	else
		fail "Valid public-bridge config not recognized - $ipaddr"
	fi
}

test_validate_network_param_043()
{
	if ipaddr="$(_validate_network_param "public-bridge" "auto" "no-bridge")" ; then
		assertEquals "Wrong ip returned " "10.192.123.123" "$ipaddr"
	else
		fail "Valid public-bridge config not recognized - $ipaddr"
	fi
}

test_validate_network_param_060()
{
	if ipaddr="$(_validate_network_param "private-bridge" "auto" "")" ; then
		fail "Valid public-bridge config not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" "-B"
	fi
}

test_validate_network_param_061()
{
	if ipaddr="$(_validate_network_param "private-bridge" "auto" "no-bridge")" ; then
		fail "Valid public-bridge config not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" "no-bridge"
	fi
}

test_validate_network_param_062()
{
	STUB_STACK="ipv6"
	if ipaddr="$(_validate_network_param "private-bridge" "auto" "test-bridge")" ; then
		fail "Valid public-bridge config not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" "ipv6"
	fi
}

test_validate_network_param_063()
{
	if ipaddr="$(_validate_network_param "private-bridge" "500.0.0.1" "test-bridge")" ; then
		fail "Valid public-bridge config not recognized"
	else
		assertContains "Wrong error message" "$ipaddr" "500.0.0.1"
	fi
}

test_validate_network_param_070()
{
	if ipaddr="$(_validate_network_param "private-bridge" "auto" "test-bridge")" ; then
		assertEquals "Wrong ip returned " "10.192.123.234" "$ipaddr"
	else
		fail "Valid private-bridge config not recognized - $ipaddr"
	fi
}

test_validate_network_param_071()
{
	if ipaddr="$(_validate_network_param "private-bridge" "" "test-bridge")" ; then
		assertEquals "Wrong ip returned " "10.192.123.234" "$ipaddr"
	else
		fail "Valid private-bridge config not recognized - $ipaddr"
	fi
}

test_validate_network_param_072()
{
	if ipaddr="$(_validate_network_param "private-bridge" "10.192.123.234" "test-bridge")" ; then
		assertEquals "Wrong ip returned " "10.192.123.234" "$ipaddr"
	else
		fail "Valid private-bridge config not recognized - $ipaddr"
	fi
}

test_is_export_port_valid_001()
{
	_is_export_port_valid
	assertFalse "empty argument not recognized" "$?"
}

test_is_export_port_valid_002()
{
	_is_export_port_valid ssh
	assertFalse "port as a name should cause an error" "$?"

	_is_export_port_valid ssh:8080
	assertFalse "port as a name should cause an error" "$?"

	_is_export_port_valid 8080:ssh
	assertFalse "port as a name should cause an error" "$?"
}

test_is_export_port_valid_003()
{
	_is_export_port_valid 80000
	assertFalse "invalid port number should cause an error" "$?"

	_is_export_port_valid 80000:8080
	assertFalse "invalid port number should cause an error" "$?"

	_is_export_port_valid 8080:80000
	assertFalse "invalid port number should cause an error" "$?"

	_is_export_port_valid -22
	assertFalse "negative port number should cause an error" "$?"

	_is_export_port_valid -22:8080
	assertFalse "negative port number should cause an error" "$?"

	_is_export_port_valid 8080:-22
	assertFalse "negative port number should cause an error" "$?"
}

test_is_export_port_valid_004()
{
	_is_export_port_valid udp:80000
	assertFalse "invalid port number should cause an error" "$?"

	_is_export_port_valid udp:80000:8080
	assertFalse "invalid port number should cause an error" "$?"

	_is_export_port_valid udp:8080:80000
	assertFalse "invalid port number should cause an error" "$?"

	_is_export_port_valid udp:-22
	assertFalse "negative port number should cause an error" "$?"

	_is_export_port_valid udp:-22:8080
	assertFalse "negative port number should cause an error" "$?"

	_is_export_port_valid udp:8080:-22
	assertFalse "negative port number should cause an error" "$?"
}

test_is_export_port_valid_005()
{
	_is_export_port_valid tcp:80000
	assertFalse "invalid port number should cause an error" "$?"

	_is_export_port_valid tcp:80000:8080
	assertFalse "invalid port number should cause an error" "$?"

	_is_export_port_valid tcp:8080:80000
	assertFalse "invalid port number should cause an error" "$?"

	_is_export_port_valid tcp:-22
	assertFalse "negative port number should cause an error" "$?"

	_is_export_port_valid tcp:-22:8080
	assertFalse "negative port number should cause an error" "$?"

	_is_export_port_valid tcp:8080:-22
	assertFalse "negative port number should cause an error" "$?"
}

test_is_export_port_valid_010()
{
	_is_export_port_valid 8080
	assertTrue "valid port should be accepted" "$?"

	_is_export_port_valid 8080:8080
	assertTrue "valid port should be accepted" "$?"
}

test_is_export_port_valid_011()
{
	_is_export_port_valid udp:8080
	assertTrue "valid port should be accepted" "$?"

	_is_export_port_valid udp:8080:8080
	assertTrue "valid port should be accepted" "$?"
}

test_is_export_port_valid_012()
{
	_is_export_port_valid tcp:8080
	assertTrue "valid port should be accepted" "$?"

	_is_export_port_valid tcp:8080:8080
	assertTrue "valid port should be accepted" "$?"
}

setUp()
{
	_POT_VERBOSITY=1
	POT_EXTIF="bce0"
	STUB_STACK=
}

. shunit/shunit2
