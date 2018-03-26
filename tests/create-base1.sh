#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/create-base.sh

# common stubs
. common-stub.sh

_is_init()
{
	__monitor ISINIT "$@"
}

# app specific stubs

create-base-help()
{
	__monitor HELP "$@"
}

_cb_fetch()
{
	__monitor CBFETCH "$@"
	if [ "$1" = "10.1" ]; then
		return 1 # false
	fi
}

_cb_zfs()
{
	__monitor CBZFS "$@"
	if [ "$1" = "11.0" ]; then
		return 1 # false
	fi
}

_cb_tar_dir()
{
	__monitor CBTAR "$@"
}

_cb_base_pot()
{
	__monitor CBPOT "$@"
}

test_base_create_base_001()
{
	pot-create-base
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cb_fetch calls" "0" "$CBFETCH_CALLS"
	assertEquals "_cb_zfs calls" "0" "$CBZFS_CALLS"
	assertEquals "_cb_tar_dir calls" "0" "$CBTAR_CALLS"
	assertEquals "_cb_base_pot calls" "0" "$CBPOT_CALLS"

	setUp
	pot-create-base -vL
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cb_fetch calls" "0" "$CBFETCH_CALLS"
	assertEquals "_cb_zfs calls" "0" "$CBZFS_CALLS"
	assertEquals "_cb_tar_dir calls" "0" "$CBTAR_CALLS"
	assertEquals "_cb_base_pot calls" "0" "$CBPOT_CALLS"

	setUp
	pot-create-base -L bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cb_fetch calls" "0" "$CBFETCH_CALLS"
	assertEquals "_cb_zfs calls" "0" "$CBZFS_CALLS"
	assertEquals "_cb_tar_dir calls" "0" "$CBTAR_CALLS"
	assertEquals "_cb_base_pot calls" "0" "$CBPOT_CALLS"

	setUp
	pot-create-base -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cb_fetch calls" "0" "$CBFETCH_CALLS"
	assertEquals "_cb_zfs calls" "0" "$CBZFS_CALLS"
	assertEquals "_cb_tar_dir calls" "0" "$CBTAR_CALLS"
	assertEquals "_cb_base_pot calls" "0" "$CBPOT_CALLS"
}

test_base_create_base_002()
{
	pot-create-base -r 1234
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cb_fetch calls" "0" "$CBFETCH_CALLS"
	assertEquals "_cb_zfs calls" "0" "$CBZFS_CALLS"
	assertEquals "_cb_tar_dir calls" "0" "$CBTAR_CALLS"
	assertEquals "_cb_base_pot calls" "0" "$CBPOT_CALLS"
}

test_nase_create_base_010()
{
	# simulate fetch issue
	pot-create-base -r 10.1
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cb_fetch calls" "1" "$CBFETCH_CALLS"
	assertEquals "_cb_zfs calls" "0" "$CBZFS_CALLS"
	assertEquals "_cb_tar_dir calls" "0" "$CBTAR_CALLS"
	assertEquals "_cb_base_pot calls" "0" "$CBPOT_CALLS"
}

test_nase_create_base_011()
{
	# simulate zfs issue
	pot-create-base -r 11.0
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cb_fetch calls" "1" "$CBFETCH_CALLS"
	assertEquals "_cb_zfs calls" "1" "$CBZFS_CALLS"
	assertEquals "_cb_tar_dir calls" "0" "$CBTAR_CALLS"
	assertEquals "_cb_base_pot calls" "0" "$CBPOT_CALLS"
}

test_nase_create_base_020()
{
	pot-create-base -r 11.1
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cb_fetch calls" "1" "$CBFETCH_CALLS"
	assertEquals "_cb_zfs calls" "1" "$CBZFS_CALLS"
	assertEquals "_cb_tar_dir calls" "1" "$CBTAR_CALLS"
	assertEquals "_cb_base_pot calls" "1" "$CBPOT_CALLS"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	CBFETCH_CALLS=0
	CBZFS_CALLS=0
	CBTAR_CALLS=0
	CBPOT_CALLS=0
}

. shunit/shunit2
