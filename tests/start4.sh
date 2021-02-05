#!/bin/sh

# system utilities stubs
potnet()
{
	if [ -z "$3" ]; then
		# public bridge
		echo "10.1.2.3 test-pot-2"
		echo "10.1.2.4 test-single"
	fi
	if [ "$3" = "test-bridge" ]; then
		# private-bridge
		echo "10.1.3.3 test-pot-multi-private"
	fi
}

# UUT
. ../share/pot/start.sh

# common stubs
. common-stub.sh

test_js_etc_hosts_000()
{
	_js_etc_hosts test-pot-2
	assertTrue "/etc/hosts" "[ -r /tmp/jails/test-pot-2/m/etc ]"
	assertEquals "/etc/hosts length" "4" "$( awk 'END {print NR}' /tmp/jails/test-pot-2/m/etc/hosts)"
	assertEquals "127.0.0.1" "127.0.0.1 localhost test-pot-2.test-domain" "$( grep "^127.0.0.1" /tmp/jails/test-pot-2/m/etc/hosts)"
	assertEquals "::1" "::1 localhost test-pot-2.test-domain" "$( grep "^::1" /tmp/jails/test-pot-2/m/etc/hosts)"
	assertEquals "test-pot-2" "10.1.2.3 test-pot-2" "$( grep "^10.1.2.3 " /tmp/jails/test-pot-2/m/etc/hosts)"
	assertEquals "test-single" "10.1.2.4 test-single" "$( grep "^10.1.2.4 " /tmp/jails/test-pot-2/m/etc/hosts)"
}

test_js_etc_hosts_001()
{
	_js_etc_hosts test-pot-multi-private
	assertTrue "/etc/hosts" "[ -r /tmp/jails/test-pot-multi-private/m/etc ]"
	assertEquals "/etc/hosts length" "3" "$( awk 'END {print NR}' /tmp/jails/test-pot-multi-private/m/etc/hosts)"
	assertEquals "127.0.0.1" "127.0.0.1 localhost test-pot-multi-private.test-domain" "$( grep "^127.0.0.1" /tmp/jails/test-pot-multi-private/m/etc/hosts)"
	assertEquals "::1" "::1 localhost test-pot-multi-private.test-domain" "$( grep "^::1" /tmp/jails/test-pot-multi-private/m/etc/hosts)"
	assertEquals "test-pot-multi-private" "10.1.3.3 test-pot-multi-private" "$( grep "^10.1.3.3 " /tmp/jails/test-pot-multi-private/m/etc/hosts)"
}

test_js_etc_hosts_020()
{
	echo "pot.hosts=10.10.10.1 test-pot-custom" > /tmp/jails/test-pot-2/conf/pot.conf
	echo "pot.hosts=10.10.10.2 test-pot-custom-2" >> /tmp/jails/test-pot-2/conf/pot.conf
	_js_etc_hosts test-pot-2
	assertTrue "/etc/hosts" "[ -r /tmp/jails/test-pot-2/m/etc ]"
	assertEquals "/etc/hosts length" "6" "$( awk 'END {print NR}' /tmp/jails/test-pot-2/m/etc/hosts)"
	assertEquals "127.0.0.1" "127.0.0.1 localhost test-pot-2.test-domain" "$( grep "^127.0.0.1" /tmp/jails/test-pot-2/m/etc/hosts)"
	assertEquals "::1" "::1 localhost test-pot-2.test-domain" "$( grep "^::1" /tmp/jails/test-pot-2/m/etc/hosts)"
	assertEquals "test-pot-2" "10.1.2.3 test-pot-2" "$( grep "^10.1.2.3 " /tmp/jails/test-pot-2/m/etc/hosts)"
	assertEquals "test-single" "10.1.2.4 test-single" "$( grep "^10.1.2.4 " /tmp/jails/test-pot-2/m/etc/hosts)"
	assertEquals "test-pot-custom" "10.10.10.1 test-pot-custom" "$( grep "^10.10.10.1 " /tmp/jails/test-pot-2/m/etc/hosts)"
	assertEquals "test-pot-custom-2" "10.10.10.2 test-pot-custom-2" "$( grep "^10.10.10.2 " /tmp/jails/test-pot-2/m/etc/hosts)"
}

test_js_etc_hosts_021()
{
	echo "pot.hosts=10.10.10.1 test-pot-custom" > /tmp/jails/test-pot-multi-private/conf/pot.conf
	echo "pot.hosts=10.10.10.2 test-pot-custom-2" >> /tmp/jails/test-pot-multi-private/conf/pot.conf
	_js_etc_hosts test-pot-multi-private
	assertTrue "/etc/hosts" "[ -r /tmp/jails/test-pot-multi-private/m/etc/hosts ]"
	assertEquals "/etc/hosts length" "5" "$( awk 'END {print NR}' /tmp/jails/test-pot-multi-private/m/etc/hosts)"
	assertEquals "127.0.0.1" "127.0.0.1 localhost test-pot-multi-private.test-domain" "$( grep "^127.0.0.1" /tmp/jails/test-pot-multi-private/m/etc/hosts)"
	assertEquals "::1" "::1 localhost test-pot-multi-private.test-domain" "$( grep "^::1" /tmp/jails/test-pot-multi-private/m/etc/hosts)"
	assertEquals "test-pot-multi-private" "10.1.3.3 test-pot-multi-private" "$( grep "^10.1.3.3 " /tmp/jails/test-pot-multi-private/m/etc/hosts)"
	assertEquals "test-pot-custom" "10.10.10.1 test-pot-custom" "$( grep "^10.10.10.1 " /tmp/jails/test-pot-multi-private/m/etc/hosts)"
	assertEquals "test-pot-custom-2" "10.10.10.2 test-pot-custom-2" "$( grep "^10.10.10.2 " /tmp/jails/test-pot-multi-private/m/etc/hosts)"
}

test_js_resolv_001()
{
	_js_resolv test-pot-dns-off
	assertFalse "off created a resolv.conf" "[ -r /tmp/jails/test-pot-dns-off/m/etc/resolv.conf ]"
}

test_js_resolv_002()
{
	_js_resolv test-pot-dns-inherit
	assertTrue "not created a resolv.conf" "[ -r /tmp/jails/test-pot-dns-inherit/m/etc/resolv.conf ]"
	assertTrue "wrong resolv.conf" "diff /tmp/jails/test-pot-dns-inherit/m/etc/resolv.conf /etc/resolv.conf"
}

test_js_resolv_003()
{
	_js_resolv test-pot-dns-custom
	assertTrue "off created a resolv.conf" "[ -r /tmp/jails/test-pot-dns-custom/m/etc/resolv.conf ]"
	assertTrue "wrong resolv.conf" "diff /tmp/jails/test-pot-dns-custom/m/etc/resolv.conf /tmp/jails/test-pot-dns-custom/conf/resolv.conf"
}

test_js_resolv_004()
{
	_js_resolv test-pot-dns-pot
	assertTrue "off created a resolv.conf" "[ -r /tmp/jails/test-pot-dns-pot/m/etc/resolv.conf ]"
	assertEquals "test-js-resolv-search" "search test-domain" "$( grep "^search " /tmp/jails/test-pot-dns-pot/m/etc/resolv.conf)"
	assertEquals "test-js-resolv-server" "nameserver 10.2.3.4" "$( grep "^nameserver " /tmp/jails/test-pot-dns-pot/m/etc/resolv.conf)"
}

setUp()
{
	common_setUp

	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
	POT_EXTIF="em2"
	POT_DNS_IP="10.2.3.4"

	mkdir -p /tmp/jails/test-pot-2/m/etc
	mkdir -p /tmp/jails/test-pot-2/conf
	touch /tmp/jails/test-pot-2/conf/pot.conf
	mkdir -p /tmp/jails/test-pot-multi-private/m/etc
	mkdir -p /tmp/jails/test-pot-multi-private/conf
	touch /tmp/jails/test-pot-multi-private/conf/pot.conf

	mkdir -p /tmp/jails/test-pot-dns-inherit/m/etc
	mkdir -p /tmp/jails/test-pot-dns-pot/m/etc
	mkdir -p /tmp/jails/test-pot-dns-custom/m/etc
	mkdir -p /tmp/jails/test-pot-dns-custom/conf
	touch /tmp/jails/test-pot-dns-custom/conf/resolv.conf
}

tearDown()
{
	rm -rf /tmp/jails
}
. shunit/shunit2
