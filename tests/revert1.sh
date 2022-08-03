#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/revert.sh

# common stubs
. common-stub.sh

# app specific stubs
revert-help()
{
	__monitor HELP "$@"
}

_pot_zfs_rollback()
{
	__monitor POTZFSROLL "$@"
}

_pot_zfs_rollback_full()
{
	__monitor POTZFSROLLFULL "$@"
}

_fscomp_zfs_rollback()
{
	__monitor FSCOMPZFSROLL "$@"
}

test_pot_revert_001()
{
	pot-revert
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS

	setUp
	pot-revert -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS

	setUp
	pot-revert -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS

	setUp
	pot-revert -va
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS
}

test_pot_revert_002()
{
	pot-revert -f test-fscomp -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_zfs_exist calls" "0" ZFSEXIST_CALLS
	assertEqualsMon "Info calls" "0" INFO_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS

	setUp
	pot-revert -p test-pot -f test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_zfs_exist calls" "0" ZFSEXIST_CALLS
	assertEqualsMon "Info calls" "0" INFO_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS
}

test_pot_revert_020()
{
	pot-revert -p
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS

	setUp
	pot-revert -p not-a-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS

	setUp
	pot-revert -p test-pot-run
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "1" ISPOTRUN_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS
}

test_pot_revert_021()
{
	pot-revert -p test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "1" ISPOTRUN_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "1" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback arg" "test-pot" POTZFSROLL_CALL1_ARG1
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
}

test_pot_revert_022()
{
	pot-revert -p test-pot -a
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full arg" "" POTZFSROLLFULL_CALL1_ARG1
}

test_pot_revert_040()
{
	pot-revert -f
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS

	setUp
	pot-revert -f not-a-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_zfs_exist calls" "1" ZFSEXIST_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS
}

test_pot_revert_041()
{
	pot-revert -f test-fscomp
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_zfs_exist calls" "1" ZFSEXIST_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "1" FSCOMPZFSROLL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback arg" "test-fscomp" FSCOMPZFSROLL_CALL1_ARG1
	assertEqualsMon "Info calls" "0" INFO_CALLS
}

test_pot_revert_042()
{
	pot-revert -f test-fscomp -a
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_pot_running calls" "0" ISPOTRUN_CALLS
	assertEqualsMon "_pot_zfs_rollback calls" "0" POTZFSROLL_CALLS
	assertEqualsMon "_pot_zfs_rollback_full calls" "0" POTZFSROLLFULL_CALLS
	assertEqualsMon "_zfs_exist calls" "0" ZFSEXIST_CALLS
	assertEqualsMon "_fscomp_zfs_rollback calls" "0" FSCOMPZFSROLL_CALLS
	assertEqualsMon "_fscomp_zfs_rollback arg" "" FSCOMPZFSROLL_CALL1_ARG1
	assertEqualsMon "Info calls" "0" INFO_CALLS
}

setUp()
{
	common_setUp
}

. shunit/shunit2
