#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/info.sh

. ../share/pot/common.sh
# common stubs

_get_network_stack()
{

	echo "${_TEST_STACK:-"dual"}"
}

_get_pot_network_type()
{
	case "$1" in
		test-pot-alias*)
			echo "alias"
			;;
		*)
			echo "inherit"
			;;
	esac
}

_get_ip_var()
{
	case "$1" in
		*)
			echo ""
			;;
	esac
}

_get_alias_ipv4()
{
	case "$1" in
		test-pot-alias)
			echo "em0|192.168.0.1"
			;;
		*)
			echo ""
			;;
	esac
}

_get_alias_ipv6()
{
	case "$1" in
		test-pot-alias)
			echo "em0|fe80::0"
			;;
		*)
			echo ""
			;;
	esac
}
# app specific stubs

test_info_pot_env_001()
{
	assertEquals "inherit has IP" "$(_info_pot_env test-pot-inherit | grep _POT_IP= )" "export _POT_IP="
}

test_info_pot_env_020()
{
	assertEquals "alias has wrong IP"        "$( _info_pot_env test-pot-alias | grep _POT_IP= )" "export _POT_IP=192.168.0.1"
	assertEquals "alias has wrong IP LIST"   "$( _info_pot_env test-pot-alias | grep _POT_IP_LIST= )" "export _POT_IP_LIST=_POT_IP_0 _POT_IP_1"
	assertEquals "alias has wrong NIC LIST"  "$( _info_pot_env test-pot-alias | grep _POT_NIC_LIST= )" "export _POT_NIC_LIST=_POT_NIC_0 _POT_NIC_1"
	assertEquals "alias has wrong IP 0"      "$( _info_pot_env test-pot-alias | grep _POT_IP_0= )" "export _POT_IP_0=192.168.0.1"
	assertEquals "alias has wrong IP 1"      "$( _info_pot_env test-pot-alias | grep _POT_IP_1= )" "export _POT_IP_1=fe80::0"
	assertEquals "alias has wrong NIC 0"     "$( _info_pot_env test-pot-alias | grep _POT_NIC_0= )" "export _POT_NIC_0=em0"
	assertEquals "alias has wrong NIC 1"     "$( _info_pot_env test-pot-alias | grep _POT_NIC_1= )" "export _POT_NIC_1=em0"
}

test_info_pot_env_021()
{
	_TEST_STACK="ipv4"
	assertEquals "alias has wrong IP"        "$( _info_pot_env test-pot-alias | grep _POT_IP= )" "export _POT_IP=192.168.0.1"
	assertEquals "alias has wrong IP LIST"   "$( _info_pot_env test-pot-alias | grep _POT_IP_LIST= )" "export _POT_IP_LIST=_POT_IP_0"
	assertEquals "alias has wrong NIC LIST"  "$( _info_pot_env test-pot-alias | grep _POT_NIC_LIST= )" "export _POT_NIC_LIST=_POT_NIC_0"
	assertEquals "alias has wrong IP 0"      "$( _info_pot_env test-pot-alias | grep _POT_IP_0= )" "export _POT_IP_0=192.168.0.1"
	assertEquals "alias has wrong NIC 0"     "$( _info_pot_env test-pot-alias | grep _POT_NIC_0= )" "export _POT_NIC_0=em0"
}

test_info_pot_env_022()
{
	_TEST_STACK="ipv6"
	assertEquals "alias has wrong IP"        "$( _info_pot_env test-pot-alias | grep _POT_IP= )" "export _POT_IP=fe80::0"
	assertEquals "alias has wrong IP LIST"   "$( _info_pot_env test-pot-alias | grep _POT_IP_LIST= )" "export _POT_IP_LIST=_POT_IP_0"
	assertEquals "alias has wrong NIC LIST"  "$( _info_pot_env test-pot-alias | grep _POT_NIC_LIST= )" "export _POT_NIC_LIST=_POT_NIC_0"
	assertEquals "alias has wrong IP 0"      "$( _info_pot_env test-pot-alias | grep _POT_IP_0= )" "export _POT_IP_0=fe80::0"
	assertEquals "alias has wrong NIC 0"     "$( _info_pot_env test-pot-alias | grep _POT_NIC_0= )" "export _POT_NIC_0=em0"
}
. shunit/shunit2
