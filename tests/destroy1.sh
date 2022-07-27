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

_zfs_dataset_valid() {
	__monitor ZFSDATASETVALID "$@"
	if [ "$1" = "/fscomp/test-fscomp" ]; then
		return 0 # true
	fi
	return 1 # false
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

_fscomp_zfs_destroy()
{
	__monitor FSCOMPDESTROY "$@"
}

test_pot_destroy_001()
{
	pot-destroy
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS

	setUp
	pot-destroy -k bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS

	setUp
	pot-destroy -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS

	setUp
	pot-destroy -va
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_002()
{
	pot-destroy -p test-pot -b 11.1
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_003()
{
	pot-destroy -p test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_004()
{
	pot-destroy -p test-pot-0
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_005()
{
	pot-destroy -p test-pot-2 -f test-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_006()
{
	pot-destroy -f test-fscomp -b 11.1
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_010()
{
	# error - recursion is needed
	pot-destroy -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_011()
{
	# error - still running, force is needed
	pot-destroy -p test-pot-run-2
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "1" POTDESTROY_CALLS
	assertEqualsMon "_pot_zfs_destroy arg1" "test-pot-run-2" POTDESTROY_CALL1_ARG1
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_020()
{
	pot-destroy -p test-pot -r
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "2" POTDESTROY_CALLS
	assertEqualsMon "_pot_zfs_destroy arg1" "test-pot-2" POTDESTROY_CALL1_ARG1
	assertEqualsMon "_pot_zfs_destroy arg2" "" POTDESTROY_CALL1_ARG2
	assertEqualsMon "_pot_zfs_destroy arg1" "test-pot" POTDESTROY_CALL2_ARG1
	assertEqualsMon "_pot_zfs_destroy arg2" "" POTDESTROY_CALL2_ARG2
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_021()
{
	pot-destroy -p test-pot-run-2 -F
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "1" POTDESTROY_CALLS
	assertEqualsMon "_pot_zfs_destroy arg1" "test-pot-run-2" POTDESTROY_CALL1_ARG1
	assertEqualsMon "_pot_zfs_destroy arg2" "YES" POTDESTROY_CALL1_ARG2
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_022()
{
	pot-destroy -p test-pot-2
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "1" POTDESTROY_CALLS
	assertEqualsMon "_pot_zfs_destroy arg1" "test-pot-2" POTDESTROY_CALL1_ARG1
	assertEqualsMon "_pot_zfs_destroy arg2" "" POTDESTROY_CALL1_ARG2
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_060()
{
	pot-destroy -f test-no-fscomp
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "0" FSCOMPDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy arg1" "" FSCOMPDESTROY_CALL1_ARG1
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}

test_pot_destroy_061()
{
	pot-destroy -f test-fscomp
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_pot_zfs_destroy calls" "0" POTDESTROY_CALLS
	assertEqualsMon "_base_zfs_destroy calls" "0" BASEDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy calls" "1" FSCOMPDESTROY_CALLS
	assertEqualsMon "_fscomp_zfs_destroy arg1" "test-fscomp" FSCOMPDESTROY_CALL1_ARG1
	assertEqualsMon "_zfs_dataset_destroy calls" "0" ZFSDDESTROY_CALLS
}
setUp()
{
	common_setUp
}

. shunit/shunit2
