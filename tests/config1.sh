#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/config.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
config-help()
{
	__monitor HELP "$@"
}

_config_echo()
{
	__monitor CONFECHO "$@"
}

test_pot_config_001()
{
	pot-config
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "config_echo calls" "0" "$CONFECHO_CALLS"

	setUp
	pot-config -k bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "config_echo calls" "0" "$CONFECHO_CALLS"

	setUp
	pot-config -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "config_echo calls" "0" "$CONFECHO_CALLS"
}

test_pot_config_002()
{
	pot-config -q
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "config_echo calls" "0" "$CONFECHO_CALLS"
}

test_pot_config_010()
{
	pot-config -g noname
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "config_echo calls" "0" "$CONFECHO_CALLS"
}

test_pot_config_020()
{
	pot-config -g gateway
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "config_echo calls" "1" "$CONFECHO_CALLS"
	assertEquals "config_echo arg" "NO" "$CONFECHO_CALL1_ARG1"
	assertEquals "config_echo arg" "gateway" "$CONFECHO_CALL1_ARG2"
	assertEquals "config_echo arg" "10.1.2.3" "$CONFECHO_CALL1_ARG3"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	CONFECHO_CALLS=0
	POT_GATEWAY=10.1.2.3
}

. shunit/shunit2
