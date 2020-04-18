#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/snapshot.sh

# common stubs
. common-stub.sh

# app specific stubs
snapshot-help()
{
	HELP_CALLS=$(( HELP_CALLS + 1 ))
}

test_pot_snapshot_001()
{
	pot-snapshot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"

	setUp
	pot-snapshot -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"

	setUp
	pot-snapshot -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"

	setUp
	pot-snapshot -va
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
}

test_pot_snapshot_002()
{
	pot-snapshot -f test-fscomp -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_zfs_exist calls" "0" "$ZFSEXIST_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
	assertEquals "Info calls" "0" "$INFO_CALLS"
}

test_pot_snapshot_003()
{
	pot-snapshot -p test-pot -f test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_zfs_exist calls" "0" "$ZFSEXIST_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
	assertEquals "Info calls" "0" "$INFO_CALLS"
}

test_pot_snapshot_004()
{
	pot-snapshot -p test-pot -n backup
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_zfs_exist calls" "0" "$ZFSEXIST_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
	assertEquals "Info calls" "0" "$INFO_CALLS"
}

test_pot_snapshot_020()
{
	pot-snapshot -p
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"

	setUp
	pot-snapshot -p not-a-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"

	setUp
	pot-snapshot -p test-pot-run
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "1" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
}

test_pot_snapshot_021()
{
	pot-snapshot -p test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "1" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "1" "$POTZFSSNAP_CALLS"
	assertEquals "_pot_zfs_snap arg" "test-pot" "$POTZFSSNAP_CALL1_ARG1"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
}

test_pot_snapshot_022()
{
	pot-snapshot -p test-pot -a
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_zfs_exist calls" "0" "$ZFSEXIST_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
	assertEquals "Info calls" "0" "$INFO_CALLS"
}

test_pot_snapshot_023()
{
	pot-snapshot -p test-pot -r
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "1" "$ISPOTRUN_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "1" "$RMVPOTSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap arg" "test-pot" "$RMVPOTSNAP_CALL1_ARG1"
	assertEquals "_pot_zfs_snap calls" "1" "$POTZFSSNAP_CALLS"
	assertEquals "_pot_zfs_snap arg" "test-pot" "$POTZFSSNAP_CALL1_ARG1"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
}

test_pot_snapshot_040()
{
	pot-snapshot -f
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"

	setUp
	pot-snapshot -f not-a-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_zfs_exist calls" "1" "$ZFSEXIST_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
	
}

test_pot_snapshot_041()
{
	pot-snapshot -f test-fscomp
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_zfs_exist calls" "1" "$ZFSEXIST_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "1" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_fscomp_zfs_snap arg" "test-fscomp" "$FSCOMPZFSSNAP_CALL1_ARG1"
	assertEquals "_fscomp_zfs_snap arg" "" "$FSCOMPZFSSNAP_CALL1_ARG2"
	assertEquals "Info calls" "0" "$INFO_CALLS"
}

test_pot_snapshot_042()
{
	pot-snapshot -f test-fscomp -a
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_zfs_exist calls" "0" "$ZFSEXIST_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
	assertEquals "Info calls" "0" "$INFO_CALLS"
}

test_pot_snapshot_043()
{
	pot-snapshot -f test-fscomp -n backup
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_zfs_exist calls" "0" "$ZFSEXIST_CALLS"
	assertEquals "_fscomp_zfs_snap calls" "0" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "0" "$RMVFSCOMPSNAP_CALLS"
	assertEquals "Info calls" "0" "$INFO_CALLS"
}

test_pot_snapshot_044()
{
	pot-snapshot -f test-fscomp -r
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_pot_running calls" "0" "$ISPOTRUN_CALLS"
	assertEquals "_pot_zfs_snap calls" "0" "$POTZFSSNAP_CALLS"
	assertEquals "_remove_oldest_pot_snap calls" "0" "$RMVPOTSNAP_CALLS"
	assertEquals "_pot_zfs_snap_full calls" "0" "$POTZFSSNAPFULL_CALLS"
	assertEquals "_zfs_exist calls" "1" "$ZFSEXIST_CALLS"
	assertEquals "_remove_oldest_fscomp_snap calls" "1" "$RMVFSCOMPSNAP_CALLS"
	assertEquals "_remove_oldest_fscomp_snap arg" "test-fscomp" "$RMVFSCOMPSNAP_CALL1_ARG1"
	assertEquals "_fscomp_zfs_snap calls" "1" "$FSCOMPZFSSNAP_CALLS"
	assertEquals "_fscomp_zfs_snap arg" "test-fscomp" "$FSCOMPZFSSNAP_CALL1_ARG1"
	assertEquals "_fscomp_zfs_snap arg" "" "$FSCOMPZFSSNAP_CALL1_ARG2"
	assertEquals "Info calls" "0" "$INFO_CALLS"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	FSCOMPZFSSNAP_CALL1_ARG1=""
	FSCOMPZFSSNAP_CALL1_ARG2=""
	RMVPOTSNAP_CALL1_ARG1=""
	RMVFSCOMPSNAP_CALL1_ARG1=""
}

. shunit/shunit2
