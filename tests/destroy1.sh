#!/bin/sh

# system utilities stubs

ls()
{
	cat << LS_EOL
/opt/pot/jails/base-11_1/
/opt/pot/jails/test-pot/
/opt/pot/jails/test-pot-2/
/opt/pot/jails/test-pot-run/
/opt/pot/jails/test-pot-run-2/
LS_EOL
}

# UUT
. ../share/pot/destroy.sh

# common stubs
. common-stub.sh

# app specific stubs
destroy-help()
{
	__monitor HELP "$@"
}

_zfs_dataset_destroy()
{
	__monitor ZFSDDESTROY "$@"
}

_pot_zfs_destroy()
{
	__monitor POTDESTROY "$@"
	if [ "$1" = "test-pot-run-2" ]; then
		if [ "$2" != "YES" ]; then
			return 1 # false
		fi
	fi
	return 0 # true
}

_base_zfs_destroy()
{
	__monitor BASEDESTROY "$@"
}

test_pot_destroy_001()
{
	pot-destroy
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "0" "$POTDESTROY_CALLS"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"

	setUp
	pot-destroy -k bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "0" "$POTDESTROY_CALLS"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"

	setUp
	pot-destroy -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "0" "$POTDESTROY_CALLS"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"

	setUp
	pot-destroy -va
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "0" "$POTDESTROY_CALLS"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"
}

test_pot_destroy_002()
{
	pot-destroy -p test-pot -b 11.1
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "0" "$POTDESTROY_CALLS"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"
}

test_pot_destroy_003()
{
	pot-destroy -p test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "0" "$POTDESTROY_CALLS"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"
}

test_pot_destroy_004()
{
	pot-destroy -p test-pot-0
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "0" "$POTDESTROY_CALLS"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"
}

test_pot_destroy_010()
{
	# error - recursion is needed
	pot-destroy -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "0" "$POTDESTROY_CALLS"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"
}

test_pot_destroy_011()
{
	# error - still running, force is needed
	pot-destroy -p test-pot-run-2
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "1" "$POTDESTROY_CALLS"
	assertEquals "_pot_zfs_destroy arg1" "test-pot-run-2" "$POTDESTROY_CALL1_ARG1"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"
}

test_pot_destroy_020()
{
	pot-destroy -p test-pot -r
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "2" "$POTDESTROY_CALLS"
	assertEquals "_pot_zfs_destroy arg1" "test-pot-2" "$POTDESTROY_CALL1_ARG1"
	assertEquals "_pot_zfs_destroy arg2" "" "$POTDESTROY_CALL1_ARG2"
	assertEquals "_pot_zfs_destroy arg1" "test-pot" "$POTDESTROY_CALL2_ARG1"
	assertEquals "_pot_zfs_destroy arg2" "" "$POTDESTROY_CALL2_ARG2"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"
}

test_pot_destroy_021()
{
	pot-destroy -p test-pot-run-2 -f
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_pot_zfs_destroy calls" "1" "$POTDESTROY_CALLS"
	assertEquals "_pot_zfs_destroy arg1" "test-pot-run-2" "$POTDESTROY_CALL1_ARG1"
	assertEquals "_pot_zfs_destroy arg2" "YES" "$POTDESTROY_CALL1_ARG2"
	assertEquals "_base_zfs_destroy calls" "0" "$BASEDESTROY_CALLS"
	assertEquals "_zfs_dataset_destroy calls" "0" "$ZFSDDESTROY_CALLS"
}
setUp()
{
	common_setUp
	HELP_CALLS=0
	ZFSDDESTROY_CALLS=0
	POTDESTROY_CALLS=0
	BASEDESTROY_CALLS=0
}

. shunit/shunit2
