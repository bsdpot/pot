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

umount() {
	__monitor UMOUNT "$@"
}

# UUT
. ../share/pot/copy-in.sh

# common stubs
. common-stub.sh

# app specific stubs
copy-in-help()
{
	__monitor HELP "$@"
	return 0 # true
}

_source_validation()
{
	__monitor SRCVALID "$@"
	if [ "$1" = "test-file" ]; then
		return 0 # true
	elif [ "$1" = "test-dir" ]; then
		return 0 # true
	fi
	return 1 # false
}

_mount_source_into_potroot()
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

test_pot_copy_in_001()
{
	pot-copy-in
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-copy-in -vb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-copy-in -b bb
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"

	setUp
	pot-copy-in -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
}

test_pot_copy_in_002()
{
	pot-copy-in -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-copy-in -s test-file
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-copy-in -d test-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-copy-in -p test-pot -s test-file
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-copy-in -d test-mnt -s test-file
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"

	setUp
	pot-copy-in -d test-mnt -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
}

test_pot_copy_in_003()
{
	pot-copy-in -p test-no-pot -s test-no-file -d /test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
}

test_pot_copy_in_004()
{
	pot-copy-in -p test-no-pot -s test-file -d /test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
}

test_pot_copy_in_005()
{
	pot-copy-in -p test-pot -s test-no-file -d /test-no-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_source_validation calls" "1" "$SRCVALID_CALLS"
}

test_pot_copy_in_006()
{
	pot-copy-in -p test-pot-run -s test-file -d /test-mnt
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_source_validation calls" "1" "$SRCVALID_CALLS"
	assertEquals "_pot_mount calls" "0" "$PMOUNT_CALLS"
	assertEquals "_jexec calls" "0" "$JEXEC_CALLS"
	assertEquals "_jail calls" "0" "$JAIL_CALLS"
}

test_pot_copy_in_020()
{
	pot-copy-in -p test-pot -s test-file -d /test-mnt
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_source_validation calls" "1" "$SRCVALID_CALLS"
	assertEquals "_pot_mount calls" "1" "$PMOUNT_CALLS"
	assertEquals "_jexec calls" "0" "$JEXEC_CALLS"
	assertEquals "_jail calls" "1" "$JAIL_CALLS"
	assertEquals "_jail args" "-c" "$JAIL_CALL1_ARG1"
	assertEquals "_jail args" "/tmp/tmp/test-file" "$JAIL_CALL1_ARG5"
	assertEquals "_jail args" "/test-mnt" "$JAIL_CALL1_ARG6"
	assertEquals "_pot_umount calls" "1" "$PUMOUNT_CALLS"
}

test_pot_copy_in_021()
{
	pot-copy-in -p test-pot-run -s test-file -d /test-mnt -F
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_source_validation calls" "1" "$SRCVALID_CALLS"
	assertEquals "_pot_mount calls" "0" "$PMOUNT_CALLS"
	assertEquals "_jexec calls" "1" "$JEXEC_CALLS"
	assertEquals "_jexec args" "test-pot-run" "$JEXEC_CALL1_ARG1"
	assertEquals "_jexec args" "-a" "$JEXEC_CALL1_ARG3"
	assertEquals "_jexec args" "/tmp/tmp/test-file" "$JEXEC_CALL1_ARG4"
	assertEquals "_jexec args" "/test-mnt" "$JEXEC_CALL1_ARG5"
	assertEquals "_jail calls" "0" "$JAIL_CALLS"
	assertEquals "_pot_umount calls" "0" "$PUMOUNT_CALLS"
}

test_pot_copy_in_022()
{
	pot-copy-in -p test-pot-run -s test-file -d /test-mnt -vF
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_source_validation calls" "1" "$SRCVALID_CALLS"
	assertEquals "_pot_mount calls" "0" "$PMOUNT_CALLS"
	assertEquals "_jexec calls" "1" "$JEXEC_CALLS"
	assertEquals "_jexec args" "test-pot-run" "$JEXEC_CALL1_ARG1"
	assertEquals "_jexec args" "-va" "$JEXEC_CALL1_ARG3"
	assertEquals "_jexec args" "/tmp/tmp/test-file" "$JEXEC_CALL1_ARG4"
	assertEquals "_jexec args" "/test-mnt" "$JEXEC_CALL1_ARG5"
	assertEquals "_jail calls" "0" "$JAIL_CALLS"
	assertEquals "_pot_umount calls" "0" "$PUMOUNT_CALLS"
}

test_pot_copy_in_023()
{
	pot-copy-in -p test-pot -s test-dir -d /test-mnt -v
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_source_validation calls" "1" "$SRCVALID_CALLS"
	assertEquals "_pot_mount calls" "1" "$PMOUNT_CALLS"
	assertEquals "_jexec calls" "0" "$JEXEC_CALLS"
	assertEquals "_jail calls" "1" "$JAIL_CALLS"
	assertEquals "_jail args" "-c" "$JAIL_CALL1_ARG1"
	assertEquals "_jail args" "/tmp/tmp" "$JAIL_CALL1_ARG5"
	assertEquals "_jail args" "/test-mnt" "$JAIL_CALL1_ARG6"
	assertEquals "_pot_umount calls" "1" "$PUMOUNT_CALLS"
}

setUp()
{
	common_setUp
	ERROR_DEBUG="NO"
	DEBUG_DEBUG="NO"
	HELP_CALLS=0
	SRCVALID_CALLS=0
	JAIL_CALLS=0
	JEXEC_CALLS=0
	UMOUNT_CALLS=0
	PMOUNT_CALLS=0
	PUMOUNT_CALLS=0

	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
}

. shunit/shunit2
