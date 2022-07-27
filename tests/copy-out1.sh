#!/bin/sh

# system utilities stubs

if [ "$(uname)" = "Linux" ]; then
	TEST=/usr/bin/[
else
	TEST=/bin/[
fi

[()
{
	if ${TEST} "$1" = "-f" ]; then
		if ${TEST} "$2" = "test-file" ]; then
			return 0 # false
		fi
	fi
	${TEST} "$@"
	return $?
}

jexec() {
	__monitor JEXEC "$@"
}

jail() {
	__monitor JAIL "$@"
}

mktemp() {
	__monitor MKTEMP "$@"
	echo /tmp/copy-out.asdf
}

rmdir() {
	__monitor RMDIR "$@"
}

umount() {
	__monitor UMOUNT "$@"
}

# UUT
. ../share/pot/copy-out.sh

# common stubs
. common-stub.sh

# app specific stubs
copy-out-help()
{
	__monitor HELP "$@"
	return 0 # true
}

_destination_validation()
{
	__monitor DSTVALID "$@"
	if [ "$1" = "test-mnt" ]; then
		return 0 # true
	fi
	return 1 # false
}

_mount_destination_into_potroot()
{
	return 0 # true
}

_pot_mount()
{
	__monitor PMOUNT "$@"
}

_pot_umount()
{
	__monitor PUMOUNT "$@"
}

test_pot_copy_out_001()
{
	pot-copy-out
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS

	setUp
	pot-copy-out -vb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS

	setUp
	pot-copy-out -b bb
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS

	setUp
	pot-copy-out -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
}

test_pot_copy_out_002()
{
	pot-copy-out -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS

	setUp
	pot-copy-out -s test-file
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS

	setUp
	pot-copy-out -d test-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS

	setUp
	pot-copy-out -p test-pot -s test-file
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS

	setUp
	pot-copy-out -d test-mnt -s test-file
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS

	setUp
	pot-copy-out -d test-mnt -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
}

test_pot_copy_out_003()
{
	pot-copy-out -p test-no-pot -s /test-no-file -d test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
}

test_pot_copy_out_004()
{
	pot-copy-out -p test-no-pot -s /test-file -d test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
}

test_pot_copy_out_005()
{
	pot-copy-out -p test-pot -s /test-no-file -d test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_destination_validation calls" "1" DSTVALID_CALLS
}

test_pot_copy_out_006()
{
	pot-copy-out -p test-pot-run -s /test-file -d test-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_destination_validation calls" "1" DSTVALID_CALLS
	assertEqualsMon "_pot_mount calls" "0" PMOUNT_CALLS
	assertEqualsMon "_jexec calls" "0" JEXEC_CALLS
	assertEqualsMon "_jail calls" "0" JAIL_CALLS
}

test_pot_copy_out_020()
{
	pot-copy-out -p test-pot -s /test-file -d test-mnt
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_destination_validation calls" "1" DSTVALID_CALLS
	assertEqualsMon "_pot_mount calls" "1" PMOUNT_CALLS
	assertEqualsMon "_jexec calls" "0" JEXEC_CALLS
	assertEqualsMon "_jail calls" "1" JAIL_CALLS
	assertEqualsMon "_jail args" "-c" JAIL_CALL1_ARG1
	assertEqualsMon "_jail args" "/test-file" JAIL_CALL1_ARG5
	assertEqualsMon "_jail args" "/tmp/copy-out.asdf" JAIL_CALL1_ARG6
	assertEqualsMon "_pot_umount calls" "1" PUMOUNT_CALLS
	assertEqualsMon "_rmdir calls" "0" RMDIR_CALLS
}

test_pot_copy_out_021()
{
	pot-copy-out -p test-pot-run -s /test-file -d test-mnt -F
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_destination_validation calls" "1" DSTVALID_CALLS
	assertEqualsMon "_pot_mount calls" "0" PMOUNT_CALLS
	assertEqualsMon "_jexec calls" "1" JEXEC_CALLS
	assertEqualsMon "_jexec args" "test-pot-run" JEXEC_CALL1_ARG1
	assertEqualsMon "_jexec args" "-a" JEXEC_CALL1_ARG3
	assertEqualsMon "_jexec args" "/test-file" JEXEC_CALL1_ARG4
	assertEqualsMon "_jexec args" "/tmp/copy-out.asdf" JEXEC_CALL1_ARG5
	assertEqualsMon "_jail calls" "0" JAIL_CALLS
	assertEqualsMon "_pot_umount calls" "0" PUMOUNT_CALLS
	assertEqualsMon "_rmdir calls" "1" RMDIR_CALLS
}

test_pot_copy_out_022()
{
	pot-copy-out -p test-pot-run -s /test-file -d test-mnt -vF
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_destination_validation calls" "1" DSTVALID_CALLS
	assertEqualsMon "_pot_mount calls" "0" PMOUNT_CALLS
	assertEqualsMon "_jexec calls" "1" JEXEC_CALLS
	assertEqualsMon "_jexec args" "test-pot-run" JEXEC_CALL1_ARG1
	assertEqualsMon "_jexec args" "-va" JEXEC_CALL1_ARG3
	assertEqualsMon "_jexec args" "/test-file" JEXEC_CALL1_ARG4
	assertEqualsMon "_jexec args" "/tmp/copy-out.asdf" JEXEC_CALL1_ARG5
	assertEqualsMon "_jail calls" "0" JAIL_CALLS
	assertEqualsMon "_pot_umount calls" "0" PUMOUNT_CALLS
	assertEqualsMon "_rmdir calls" "1" RMDIR_CALLS
}

test_pot_copy_out_023()
{
	pot-copy-out -p test-pot -s /test-dir -d test-mnt -v
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_destination_validation calls" "1" DSTVALID_CALLS
	assertEqualsMon "_pot_mount calls" "1" PMOUNT_CALLS
	assertEqualsMon "_jexec calls" "0" JEXEC_CALLS
	assertEqualsMon "_jail calls" "1" JAIL_CALLS
	assertEqualsMon "_jail args" "-c" JAIL_CALL1_ARG1
	assertEqualsMon "_jail args" "/test-dir" JAIL_CALL1_ARG5
	assertEqualsMon "_jail args" "/tmp/copy-out.asdf" JAIL_CALL1_ARG6
	assertEqualsMon "_pot_umount calls" "1" PUMOUNT_CALLS
	assertEqualsMon "_rmdir calls" "0" RMDIR_CALLS
}

setUp()
{
	common_setUp
	ERROR_DEBUG="NO"
	DEBUG_DEBUG="NO"
	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
}

. shunit/shunit2
