#!/bin/sh

# system utilities stubs

cp() {
	__monitor CP "$@"
}

# UUT
. ../share/pot/add-file.sh

# common stubs
. common-stub.sh

# app specific stubs
add-file-help()
{
	__monitor HELP "$@"
	return 0 # true
}

_file_validation()
{
	__monitor FILEVALID "$@"
	if [ "$1" = "test-file" ]; then
		return 0 # true
	fi
	return 1 # false
}

_pot_mount()
{
	__monitor PMOUNT "$@"
}

_pot_umount()
{
	__monitor PUMOUNT "$@"
}

test_pot_add_file_001()
{
	pot-add-file
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-add-file -vb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-add-file -b bb
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-add-file -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
}

test_pot_add_file_002()
{
	pot-add-file -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-add-file -f test-file
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-add-file -m test-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-add-file -p test-pot -f test-file
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-add-file -m test-mnt -f test-file
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-add-file -m test-mnt -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
}

test_pot_add_file_003()
{
	pot-add-file -p test-no-pot -f test-no-file -m /test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
}

test_pot_add_file_004()
{
	pot-add-file -p test-no-pot -f test-file -m /test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
}

test_pot_add_file_005()
{
	pot-add-file -p test-pot -f test-no-file -m /test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_file_validation calls" "1" "$FILEVALID_CALLS"
}

test_pot_add_file_020()
{
	pot-add-file -p test-pot -f test-file -m /test-mnt
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_file_validation calls" "1" "$FILEVALID_CALLS"
	assertEquals "_pot_mount calls" "1" "$PMOUNT_CALLS"
	assertEquals "_cp calls" "1" "$CP_CALLS"
	assertEquals "_cp args" "-v" "$CP_CALL1_ARG1"
	assertEquals "_cp args" "test-file" "$CP_CALL1_ARG2"
	assertEquals "_cp args" "/tmp/jails/test-pot/m//test-mnt" "$CP_CALL1_ARG3"
	assertEquals "_pot_umount calls" "1" "$PUMOUNT_CALLS"
}

test_pot_add_file_021()
{
	pot-add-file -p test-pot-run -f test-file -m /test-mnt
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_file_validation calls" "1" "$FILEVALID_CALLS"
	assertEquals "_pot_mount calls" "0" "$PMOUNT_CALLS"
	assertEquals "_cp calls" "1" "$CP_CALLS"
	assertEquals "_cp args" "-v" "$CP_CALL1_ARG1"
	assertEquals "_cp args" "test-file" "$CP_CALL1_ARG2"
	assertEquals "_cp args" "/tmp/jails/test-pot-run/m//test-mnt" "$CP_CALL1_ARG3"
	assertEquals "_pot_umount calls" "0" "$PUMOUNT_CALLS"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	FILEVALID_CALLS=0
	CP_CALLS=0
	PMOUNT_CALLS=0
	PUMOUNT_CALLS=0

	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
}

. shunit/shunit2
