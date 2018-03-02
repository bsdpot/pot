#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/create.sh

# common stubs
. common-stub.sh

_cj_zfs()
{
	__monitor CJZFS "$@"
}

_cj_conf()
{
	__monitor CJCONF "$@"
}

_cj_flv()
{
	__monitor CJFLV "$@"
}

# app specific stubs
create-help()
{
	__monitor HELP "$@"
}

test_pot_create_001()
{
	pot-create
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"

	setUp
	pot-create -vL
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"

	setUp
	pot-create -L bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"

	setUp
	pot-create -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"

	setUp
	pot-create -S
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"
}

test_pot_create_002()
{
	pot-create -p test-pot -b 11.1
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"
}

test_pot_create_003()
{
	pot-create -p new-pot -P test-pot -l 0
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"

	setUp
	pot-create -p new-pot -b 11.1 -P test-pot -l 0
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"
}

test_pot_create_004()
{
	pot-create -p new-pot -P test-pot2
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"

	setUp
	pot-create -p new-pot -P test-pot2 -l 1
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"

	setUp
	pot-create -p new-pot -b 11.1 -l 2
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"
}

test_pot_create_020()
{
	pot-create -p new-pot -b 11.1
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "1" "$CJZFS_CALLS"
	assertEquals "_cj_zfs arg1" "new-pot" "$CJZFS_CALL1_ARG1"
	assertEquals "_cj_zfs arg2" "11.1" "$CJZFS_CALL1_ARG2"
	assertEquals "_cj_zfs arg3" "1" "$CJZFS_CALL1_ARG3"
	assertEquals "_cj_zfs arg4" "" "$CJZFS_CALL1_ARG4"
	assertEquals "_cj_conf calls" "1" "$CJCONF_CALLS"
	assertEquals "_cj_conf arg1" "new-pot" "$CJCONF_CALL1_ARG1"
	assertEquals "_cj_conf arg2" "11.1" "$CJCONF_CALL1_ARG2"
	assertEquals "_cj_conf arg3" "inherit" "$CJCONF_CALL1_ARG3"
	assertEquals "_cj_conf arg4" "1" "$CJCONF_CALL1_ARG4"
	assertEquals "_cj_conf arg5" "inherit" "$CJCONF_CALL1_ARG5"
	assertEquals "_cj_conf arg6" "" "$CJCONF_CALL1_ARG6"
	assertEquals "_cj_flv calls" "1" "$CJFLV_CALLS"

	setUp
	pot-create -p new-pot -P test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "1" "$CJZFS_CALLS"
	assertEquals "_cj_zfs arg1" "new-pot" "$CJZFS_CALL1_ARG1"
	assertEquals "_cj_zfs arg2" "11.1" "$CJZFS_CALL1_ARG2"
	assertEquals "_cj_zfs arg3" "1" "$CJZFS_CALL1_ARG3"
	assertEquals "_cj_zfs arg4" "test-pot" "$CJZFS_CALL1_ARG4"
	assertEquals "_cj_conf calls" "1" "$CJCONF_CALLS"
	assertEquals "_cj_conf arg1" "new-pot" "$CJCONF_CALL1_ARG1"
	assertEquals "_cj_conf arg2" "11.1" "$CJCONF_CALL1_ARG2"
	assertEquals "_cj_conf arg3" "inherit" "$CJCONF_CALL1_ARG3"
	assertEquals "_cj_conf arg4" "1" "$CJCONF_CALL1_ARG4"
	assertEquals "_cj_conf arg5" "inherit" "$CJCONF_CALL1_ARG5"
	assertEquals "_cj_conf arg6" "test-pot" "$CJCONF_CALL1_ARG6"
	assertEquals "_cj_flv calls" "1" "$CJFLV_CALLS"
}

test_pot_create_021()
{
	pot-create -p new-pot -P test-pot -S
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"
}

test_pot_create_022()
{
	pot-create -p new-pot -P test-pot -b 10.4
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"
}

test_pot_create_040()
{
	pot-create -p new-pot -P test-pot -l 2
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "1" "$CJZFS_CALLS"
	assertEquals "_cj_zfs arg1" "new-pot" "$CJZFS_CALL1_ARG1"
	assertEquals "_cj_zfs arg2" "11.1" "$CJZFS_CALL1_ARG2"
	assertEquals "_cj_zfs arg3" "2" "$CJZFS_CALL1_ARG3"
	assertEquals "_cj_zfs arg4" "test-pot" "$CJZFS_CALL1_ARG4"
	assertEquals "_cj_conf calls" "1" "$CJCONF_CALLS"
	assertEquals "_cj_conf arg1" "new-pot" "$CJCONF_CALL1_ARG1"
	assertEquals "_cj_conf arg2" "11.1" "$CJCONF_CALL1_ARG2"
	assertEquals "_cj_conf arg3" "inherit" "$CJCONF_CALL1_ARG3"
	assertEquals "_cj_conf arg4" "2" "$CJCONF_CALL1_ARG4"
	assertEquals "_cj_conf arg5" "inherit" "$CJCONF_CALL1_ARG5"
	assertEquals "_cj_conf arg6" "test-pot" "$CJCONF_CALL1_ARG6"
	assertEquals "_cj_flv calls" "1" "$CJFLV_CALLS"

	setUp
	pot-create -p new-pot -b 11.1 -P test-pot -l 2
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "1" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "1" "$CJZFS_CALLS"
	assertEquals "_cj_zfs arg1" "new-pot" "$CJZFS_CALL1_ARG1"
	assertEquals "_cj_zfs arg2" "11.1" "$CJZFS_CALL1_ARG2"
	assertEquals "_cj_zfs arg3" "2" "$CJZFS_CALL1_ARG3"
	assertEquals "_cj_zfs arg4" "test-pot" "$CJZFS_CALL1_ARG4"
	assertEquals "_cj_conf calls" "1" "$CJCONF_CALLS"
	assertEquals "_cj_conf arg1" "new-pot" "$CJCONF_CALL1_ARG1"
	assertEquals "_cj_conf arg2" "11.1" "$CJCONF_CALL1_ARG2"
	assertEquals "_cj_conf arg3" "inherit" "$CJCONF_CALL1_ARG3"
	assertEquals "_cj_conf arg4" "2" "$CJCONF_CALL1_ARG4"
	assertEquals "_cj_conf arg5" "inherit" "$CJCONF_CALL1_ARG5"
	assertEquals "_cj_conf arg6" "test-pot" "$CJCONF_CALL1_ARG6"
	assertEquals "_cj_flv calls" "1" "$CJFLV_CALLS"
}

test_pot_create_041()
{
	pot-create -p new-pot -P test-pot -b 10.4 -l 2
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_uid0 calls" "0" "$ISUID0_CALLS"
	assertEquals "_cj_zfs calls" "0" "$CJZFS_CALLS"
	assertEquals "_cj_conf calls" "0" "$CJCONF_CALLS"
	assertEquals "_cj_flv calls" "0" "$CJFLV_CALLS"
}


setUp()
{
	common_setUp
	CJZFS_CALLS=0
	CJZFS_CALL1_ARG4=
	CJCONF_CALLS=0
	CJCONF_CALL1_ARG6=
	CJFLV_CALLS=0
	HELP_CALLS=0
}

. shunit/shunit2
