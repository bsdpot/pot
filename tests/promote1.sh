#!/bin/sh

EXIT="return"

# system utilities stubs
zfs()
{
	__monitor ZFS "$@"
	if [ "$1" = "get" ]; then
		case "$4" in
		"${POT_ZFS_ROOT}/jails/test-pot/usr.local")
			echo "${POT_ZFS_ROOT}/jails/test-pot/usr.local origin ${POT_ZFS_ROOT}/jails/pot-father/usr.local@4321"
			;;
		"${POT_ZFS_ROOT}/jails/test-pot/custom")
			echo "${POT_ZFS_ROOT}/jails/test-pot/custom origin ${POT_ZFS_ROOT}/jails/pot-father/custom@4321"
		esac
	fi
}

# UUT
. ../share/pot/promote.sh

# common stubs
. common-stub.sh

# app specific stubs
promote-help()
{
	HELP_CALLS=$(( HELP_CALLS + 1 ))
}

test_pot_promote_001()
{
	pot-promote
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"

	setUp
	pot-promote -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-promote -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"

	setUp
	pot-promote -va
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
}

test_pot_promote_002()
{
	pot-promote -p test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
}

test_pot_promote_020()
{
	pot-promote -p test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "zfs calls" "2" "$ZFS_CALLS"
	assertEquals "zfs arg1" "promote" "$ZFS_CALL1_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/test-pot/usr.local" "$ZFS_CALL1_ARG2"
	assertEquals "zfs arg1" "promote" "$ZFS_CALL2_ARG1"
	assertEquals "zfs arg2" "${POT_ZFS_ROOT}/jails/test-pot/custom" "$ZFS_CALL2_ARG2"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	ZFS_CALLS=0

	POT_ZFS_ROOT=zpot
}

. shunit/shunit2
