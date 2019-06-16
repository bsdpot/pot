#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/set-attribute.sh

# common stubs
. common-stub.sh

# app specific stubs
set-attr-help()
{
	__monitor HELP "$@"
}

_set_start_at_boot()
{
	__monitor STARTBOOT "$@"
}

_set_persistent()
{
	__monitor PERSISTENT "$@"
}

_set_no_rc_script()
{
	__monitor NORCSCRIPT "$@"
}

test_pot_set_attr_001()
{
	pot-set-attribute
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"

	setUp
	pot-set-attribute -bv
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"

	setUp
	pot-set-attribute -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"

	setUp
	pot-set-attribute -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"
}

test_pot_set_attr_002()
{
	pot-set-attribute -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"

	setUp
	pot-set-attribute -A start-at-boot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"

	setUp
	pot-set-attribute -V ON
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"
}

test_pot_set_attr_003()
{
	pot-set-attribute -A start-at-boot -V ON
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"

	setUp
	pot-set-attribute -p test-pot -A start-at-boot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"

	setUp
	pot-set-attribute -p test-pot -V ON
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"
}

test_pot_set_attr_004()
{
	pot-set-attribute -p test-no-pot -A start-at-boot -V ON
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"
}

test_pot_set_attr_005()
{
	pot-set-attribute -p test-pot -A not-an-attribute -V ON
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "0" "$STARTBOOT_CALLS"
}

test_pot_set_attr_020()
{
	pot-set-attribute -p test-pot -A start-at-boot -V ON
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "1" "$STARTBOOT_CALLS"
	assertEquals "_set_attr arg1" "test-pot" "$STARTBOOT_CALL1_ARG1"
	assertEquals "_set_attr arg2" "ON" "$STARTBOOT_CALL1_ARG2"
}

test_pot_set_attr_021()
{
	pot-set-attribute -p test-pot -A persistent -V ON
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "1" "$PERSISTENT_CALLS"
	assertEquals "_set_attr arg1" "test-pot" "$PERSISTENT_CALL1_ARG1"
	assertEquals "_set_attr arg2" "ON" "$PERSISTENT_CALL1_ARG2"
}

test_pot_set_attr_022()
{
	pot-set-attribute -p test-pot -A no-rc-script -V ON
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_attr calls" "1" "$NORCSCRIPT_CALLS"
	assertEquals "_set_attr arg1" "test-pot" "$NORCSCRIPT_CALL1_ARG1"
	assertEquals "_set_attr arg2" "ON" "$NORCSCRIPT_CALL1_ARG2"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	STARTBOOT_CALLS=0
	STARTBOOT_CALL1_ARG=
	STARTBOOT_CALL2_ARG=
	PERSISTENT_CALLS=0
	PERSISTENT_CALL1_ARG=
	PERSISTENT_CALL2_ARG=
	NORCSCRIPT_CALLS=0
	NORCSCRIPT_CALL1_ARG=
	NORCSCRIPT_CALL2_ARG=
}

. shunit/shunit2
