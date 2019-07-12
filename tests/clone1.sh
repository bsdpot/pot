#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/clone.sh

# common stubs
. common-stub.sh

potnet()
{
	# no monitor, potnet is called in a subshell
	if [ "$1" = "next" ]; then
		echo "10.123.123.123"
		return 0 # true
	fi
	if [ "$1" = "validate" ] && [ "$2" = "-H" ] ; then
		if [ "$3" = "10.123.123.123" ] || [ "$3" = "10.1.2.4" ]; then
			return 0 # true
		fi
	fi
	if [ "$1" = "ipcheck" ]; then
		return 0 # true
	fi
	return 1 # false
}

_is_potnet_available()
{
	return 0 # true
}

# app specific stubs
_cj_zfs()
{
	__monitor CJZFS "$@"
}

_cj_conf()
{
	__monitor CJCONF "$@"
}

clone-help()
{
	__monitor HELP "$@"
}

test_pot_clone_001()
{
	pot-clone
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"

	setUp
	pot-clone -vL
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"

	setUp
	pot-clone -L bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"

	setUp
	pot-clone -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"

	setUp
	pot-clone -S
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
}

test_pot_clone_002()
{
	pot-clone -p new-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"

	setUp
	pot-clone -P test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
}

test_pot_clone_003()
{
	pot-clone -p new-pot -P no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"

	setUp
	pot-clone -p test-pot -P test-pot-2
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
}

test_pot_clone_004()
{
	# missing -i parameter
	pot-clone -p new-pot -P test-pot-2
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
}

test_pot_clone_005()
{
	# test-pot has inherit network type
	pot-clone -p new-pot -P test-pot -i 10.1.2.3
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
}

test_pot_clone_006()
{
	# ip address already in use
	pot-clone -p new-pot -P test-pot-2 -i 10.1.2.3
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
}

test_pot_clone_020()
{
	pot-clone -p new-pot -P test-pot-0
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
}

test_pot_clone_021()
{
	pot-clone -p new-pot -P test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "1" "$CJZFS_CALLS"
	assertEquals "_cj_zfs arg1" "new-pot" "$CJZFS_CALL1_ARG1"
	assertEquals "_cj_zfs arg2" "test-pot" "$CJZFS_CALL1_ARG2"
	assertEquals "_cj_zfs arg3" "NO" "$CJZFS_CALL1_ARG3"
	assertEquals "_cj_conf calls" "1" "$CJCONF_CALLS"
	assertEquals "_cj_conf arg1" "new-pot" "$CJCONF_CALL1_ARG1"
	assertEquals "_cj_conf arg2" "test-pot" "$CJCONF_CALL1_ARG2"
	assertEquals "_cj_conf arg3" "inherit" "$CJCONF_CALL1_ARG3"
	assertEquals "_cj_conf arg4" "" "$CJCONF_CALL1_ARG4"
}

test_pot_clone_022()
{
	pot-clone -p new-pot-2 -P test-pot-2 -i 10.1.2.4
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "1" "$CJZFS_CALLS"
	assertEquals "_cj_zfs arg0" "new-pot-2" "$CJZFS_CALL1_ARG1"
	assertEquals "_cj_zfs arg1" "test-pot-2" "$CJZFS_CALL1_ARG2"
	assertEquals "_cj_conf calls" "1" "$CJCONF_CALLS"
	assertEquals "_cj_conf arg1" "new-pot-2" "$CJCONF_CALL1_ARG1"
	assertEquals "_cj_conf arg2" "test-pot-2" "$CJCONF_CALL1_ARG2"
	assertEquals "_cj_conf arg3" "public-bridge" "$CJCONF_CALL1_ARG3"
	assertEquals "_cj_conf arg4" "10.1.2.4" "$CJCONF_CALL1_ARG4"
}

test_pot_clone_023()
{
	pot-clone -p new-pot -P test-pot -F
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "1" "$CJZFS_CALLS"
	assertEquals "_cj_zfs arg1" "new-pot" "$CJZFS_CALL1_ARG1"
	assertEquals "_cj_zfs arg2" "test-pot" "$CJZFS_CALL1_ARG2"
	assertEquals "_cj_zfs arg3" "YES" "$CJZFS_CALL1_ARG3"
	assertEquals "_cj_conf calls" "1" "$CJCONF_CALLS"
	assertEquals "_cj_conf arg1" "new-pot" "$CJCONF_CALL1_ARG1"
	assertEquals "_cj_conf arg2" "test-pot" "$CJCONF_CALL1_ARG2"
	assertEquals "_cj_conf arg3" "inherit" "$CJCONF_CALL1_ARG3"
	assertEquals "_cj_conf arg4" "" "$CJCONF_CALL1_ARG4"
}

test_pot_clone_024()
{
	pot-clone -p new-pot-2 -P test-pot-2 -i auto
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "1" "$CJZFS_CALLS"
	assertEquals "_cj_zfs arg0" "new-pot-2" "$CJZFS_CALL1_ARG1"
	assertEquals "_cj_zfs arg1" "test-pot-2" "$CJZFS_CALL1_ARG2"
	assertEquals "_cj_conf calls" "1" "$CJCONF_CALLS"
	assertEquals "_cj_conf arg1" "new-pot-2" "$CJCONF_CALL1_ARG1"
	assertEquals "_cj_conf arg2" "test-pot-2" "$CJCONF_CALL1_ARG2"
	assertEquals "_cj_conf arg3" "public-bridge" "$CJCONF_CALL1_ARG3"
	assertEquals "_cj_conf arg4" "10.123.123.123" "$CJCONF_CALL1_ARG4"
}

test_pot_clone_040()
{
	pot-clone -p new-pot-single -P test-pot-single -i auto
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "1" "$CJZFS_CALLS"
	assertEquals "_cj_zfs arg0" "new-pot-single" "$CJZFS_CALL1_ARG1"
	assertEquals "_cj_zfs arg1" "test-pot-single" "$CJZFS_CALL1_ARG2"
	assertEquals "_cj_conf calls" "1" "$CJCONF_CALLS"
	assertEquals "_cj_conf arg1" "new-pot-single" "$CJCONF_CALL1_ARG1"
	assertEquals "_cj_conf arg2" "test-pot-single" "$CJCONF_CALL1_ARG2"
	assertEquals "_cj_conf arg3" "public-bridge" "$CJCONF_CALL1_ARG3"
	assertEquals "_cj_conf arg4" "10.123.123.123" "$CJCONF_CALL1_ARG4"
}

setUp()
{
	common_setUp
	CJZFS_CALLS=0
	CJCONF_CALLS=0
	CJCONF_CALL1_ARG4=
	HELP_CALLS=0
}

. shunit/shunit2
