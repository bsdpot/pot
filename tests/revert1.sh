#!/bin/sh

EXIT="return"

# system utilities stubs

# UUT
. ../share/pot/revert.sh

# app specific stubs
revert-help()
{
	HELP_CALLS=$(( HELP_CALLS + 1 ))
}

_error()
{
	ERROR_CALLS=$(( ERROR_CALLS + 1 ))
	#echo "_error: $*"
}

_info()
{
	INFO_CALLS=$(( INFO_CALLS + 1 ))
}

_is_pot()
{
	ISPOT_CALLS=$(( ISPOT_CALLS + 1 ))
	if [ "$1" = "test-pot" -o "$1" = "test-pot-run" ]; then
		return 0 # true
	fi
	return 1 # false
}

_is_pot_running()
{
	ISPOTRUN_CALLS=$(( ISPOTRUN_CALLS + 1 ))
	if [ "$1" = "test-pot-run" ]; then
		return 0 # true
	fi
	return 1 # false
}

_zfs_exist()
{
	ZFSEXIST_CALLS=$(( ZFSEXIST_CALLS + 1 ))
	if [ "$1" = "/fscomp/test-fscomp" ]; then
		return 0 # true
	fi
	return 1 # false
}

_pot_zfs_rollback()
{
	POTZFSROLL_CALLS=$(( POTZFSROLL_CALLS + 1 ))
	POTZFSROLL_CALL1_ARG1=$1
}

_pot_zfs_rollback_full()
{
	POTZFSROLLFULL_CALLS=$(( POTZFSROLLFULL_CALLS + 1 ))
	POTZFSROLLFULL_CALL1_ARG1=$1
}

_fscomp_zfs_rollback()
{
	FSCOMPZFSROLL_CALLS=$(( FSCOMPZFSROLL_CALLS + 1 ))
	FSCOMPZFSROLL_CALL1_ARG1=$1
}

test_pot_revert_001()
{
	pot-revert
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "0" "$FSCOMPZFSROLL_CALLS"

	setUp
	pot-revert -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "0" "$FSCOMPZFSROLL_CALLS"

	setUp
	pot-revert -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "0" "$FSCOMPZFSROLL_CALLS"

	setUp
	pot-revert -va
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "0" "$FSCOMPZFSROLL_CALLS"
}

test_pot_revert_002()
{
	pot-revert -f test-fscomp -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_zfs_exist calls" "0" "$ZFSEXIST_CALLS"
	assertEquals "Info calls" "0" "$INFO_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "0" "$FSCOMPZFSROLL_CALLS"

	setUp
	pot-revert -p test-pot -f test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_zfs_exist calls" "0" "$ZFSEXIST_CALLS"
	assertEquals "Info calls" "0" "$INFO_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "0" "$FSCOMPZFSROLL_CALLS"
}

test_pot_revert_020()
{
	pot-revert -p
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "0" "$FSCOMPZFSROLL_CALLS"

	setUp
	pot-revert -p not-a-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "0" "$FSCOMPZFSROLL_CALLS"

	setUp
	pot-revert -p test-pot-run
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "1" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "0" "$FSCOMPZFSROLL_CALLS"
}

test_pot_revert_021()
{
	pot-revert -p test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "1" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_rollback calls" "1" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback arg" "test-pot" "$POTZFSROLL_CALL1_ARG1"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
}

test_pot_revert_022()
{
	pot-revert -p test-pot -a
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "1" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "1" "$POTZFSROLLFULL_CALLS"
	assertEquals "_pot_zfs_rollback_full arg" "test-pot" "$POTZFSROLLFULL_CALL1_ARG1"
}

test_pot_revert_040()
{
	pot-revert -f
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"

	setUp
	pot-revert -f not-a-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_zfs_exist calls" "1" "$ZFSEXIST_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "0" "$FSCOMPZFSROLL_CALLS"
}

test_pot_revert_041()
{
	pot-revert -f test-fscomp
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_zfs_exist calls" "1" "$ZFSEXIST_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "1" "$FSCOMPZFSROLL_CALLS"
	assertEquals "_fscomp_zfs_rollback arg" "test-fscomp" "$FSCOMPZFSROLL_CALL1_ARG1"
	assertEquals "Info calls" "0" "$INFO_CALLS"
}

test_pot_revert_042()
{
	pot-revert -f test-fscomp -a
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_rollback calls" "0" "$POTZFSROLL_CALLS"
	assertEquals "_pot_zfs_rollback_full calls" "0" "$POTZFSROLLFULL_CALLS"
	assertEquals "_zfs_exist calls" "1" "$ZFSEXIST_CALLS"
	assertEquals "_fscomp_zfs_rollback calls" "1" "$FSCOMPZFSROLL_CALLS"
	assertEquals "_fscomp_zfs_rollback arg" "test-fscomp" "$FSCOMPZFSROLL_CALL1_ARG1"
	assertEquals "Info calls" "1" "$INFO_CALLS"
}

setUp()
{
	_POT_VERBOSITY=1
	HELP_CALLS=0
	ERROR_CALLS=0
	INFO_CALLS=0
	ISPOT_CALLS=0
	ISPOTRUN_CALLS=0
	POTZFSROLL_CALLS=0
	POTZFSROLLFULL_CALLS=0
	ZFSEXIST_CALLS=0
	FSCOMPZFSROLL_CALLS=0
}

. shunit/shunit2
