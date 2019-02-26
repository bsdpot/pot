#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/common.sh

# common stubs
. conf-stub.sh

test_get_conf_vnet_001()
{
	rc=$(_get_conf_var test-pot-vnet-ip4 vnet )
	assertEquals "vnet value" "true" "$rc"
}

test_is_pot_vnet()
{
	_is_pot_vnet test-pot-vnet-ip4
	rc=$?
	assertEquals "is_pot_vnet" "0" "$rc"
}

setUp()
{
	conf_setUp
}

tearDown()
{
	conf_tearDown
}
. shunit/shunit2
