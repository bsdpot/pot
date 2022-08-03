#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/rename.sh

# common stubs
. common-stub.sh

# app specific stubs
rename-help()
{
	__monitor HELP "$@"
}

_rn_conf()
{
	__monitor RNCONF "$@"
}

_rn_zfs()
{
	__monitor RNZFS "$@"
}

_rn_recursive()
{
	__monitor RNRECURSIVE "$@"
}

test_pot_rename_001()
{
	pot-rename
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS

	setUp
	pot-rename -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS

	setUp
	pot-rename -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS

	setUp
	pot-rename -va
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS
}

test_pot_rename_002()
{
	pot-rename -p test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS

	setUp
	pot-rename -n test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS
}

test_pot_rename_003()
{
	pot-rename -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS

	setUp
	pot-rename -n test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS
}

test_pot_rename_004()
{
	pot-rename -p test-pot -n test-pot-2
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS
}

test_pot_rename_005()
{
	pot-rename -p no-test-pot -n no-test-pot-2
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS
}

test_pot_rename_006()
{
	pot-rename -p test-pot-run -n test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "0" RNCONF_CALLS
	assertEqualsMon "_rn_zfs calls" "0" RNZFS_CALLS
	assertEqualsMon "_rn_recursive calls" "0" RNRECURSIVE_CALLS
}

test_pot_rename_020()
{
	pot-rename -p test-pot -n test-no-pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_rn_conf calls" "1" RNCONF_CALLS
	assertEqualsMon "_rn_conf args" "test-pot" RNCONF_CALL1_ARG1
	assertEqualsMon "_rn_conf args" "test-no-pot" RNCONF_CALL1_ARG2
	assertEqualsMon "_rn_zfs calls" "1" RNZFS_CALLS
	assertEqualsMon "_rn_zfs args" "test-pot" RNZFS_CALL1_ARG1
	assertEqualsMon "_rn_zfs args" "test-no-pot" RNZFS_CALL1_ARG2
	assertEqualsMon "_rn_recursive calls" "1" RNRECURSIVE_CALLS
	assertEqualsMon "_rn_recursive args" "test-pot" RNRECURSIVE_CALL1_ARG1
	assertEqualsMon "_rn_recursive args" "test-no-pot" RNRECURSIVE_CALL1_ARG2
}

setUp()
{
	common_setUp
}

. shunit/shunit2
