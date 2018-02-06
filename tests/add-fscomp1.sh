#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/add-fscomp.sh

# common stubs
. common-stub.sh

_zfs_is_dataset()
{
	__monitor ZDSET "$@"
	if [ "$1" = "/fscomp/test-fscomp" ]; then
		return 0 # true
	fi
	if [ "$1" = "/zroot/test-fscomp" ]; then
		return 0 # true
	fi
	return 1 # false
}

# app specific stubs
add-fscomp-help()
{
	__monitor HELP "$@"
}

_add_f_to_p()
{
	__monitor ADDF2P "$@"
}

test_pot_add_fscomp_001()
{
	pot-add-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -vb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"
}

test_pot_add_fscomp_002()
{
	pot-add-fscomp -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -f test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -m test-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -p test-pot -f test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -m test-mnt -f test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -m test-mnt -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "0" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"
}

test_pot_add_fscomp_003()
{
	pot-add-fscomp -p test-no-pot -f test-no-fscomp -m test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "1" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -p test-no-pot -f test-fscomp -m test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "1" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -p test-no-pot -f /zroot/test-no-fscomp -m test-no-mnt -e
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "1" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"

	setUp
	pot-add-fscomp -p test-no-pot -f /zroot/test-fscomp -m test-no-mnt -e
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "1" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "0" "$ADDF2P_CALLS"
}

test_pot_add_fscomp_020()
{
	pot-add-fscomp -p test-pot -f test-fscomp -m test-mnt
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "1" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "1" "$ADDF2P_CALLS"
	assertEquals "_add_f_to_p arg" "test-fscomp" "$ADDF2P_CALL1_ARG1"
	assertEquals "_add_f_to_p arg" "test-pot" "$ADDF2P_CALL1_ARG2"
	assertEquals "_add_f_to_p arg" "test-mnt" "$ADDF2P_CALL1_ARG3"
	assertEquals "_add_f_to_p arg" "" "$ADDF2P_CALL1_ARG4"

	setUp
	pot-add-fscomp -p test-pot -f /zroot/test-fscomp -m test-mnt -e
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_zfs_is_dataset calls" "1" "$ZDSET_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_add_f_to_p calls" "1" "$ADDF2P_CALLS"
	assertEquals "_add_f_to_p arg" "/zroot/test-fscomp" "$ADDF2P_CALL1_ARG1"
	assertEquals "_add_f_to_p arg" "test-pot" "$ADDF2P_CALL1_ARG2"
	assertEquals "_add_f_to_p arg" "test-mnt" "$ADDF2P_CALL1_ARG3"
	assertEquals "_add_f_to_p arg" "external" "$ADDF2P_CALL1_ARG4"
}

setUp()
{
	common_setUp
	ZDSET_CALLS=0
	HELP_CALLS=0
	ADDF2P_CALLS=0
}

. shunit/shunit2
