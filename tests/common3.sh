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
	elif [ "$1" = "bridge0" ]; then
		cat << EOF--
bridge0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	inet 10.192.0.111 netmask 0xffc00000 broadcast 10.255.255.255 
EOF--
	elif [ "$1" = "bridge1" ]; then
		cat << EOF--
bridge1: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	inet 10.192.0.11 netmask 0xffc00000 broadcast 10.255.255.255 
EOF--
	elif [ "$1" = "bridge2" ]; then
		cat << EOF--
bridge2: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	inet 10.192.0.1 netmask 0xffc00000 broadcast 10.255.255.255 
EOF--
	fi
}

# UUT
. ../share/pot/common.sh

# app specific stubs

test_pot_bridge_001()
{
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

. shunit/shunit2
