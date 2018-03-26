#!/bin/sh

# system utilities stubs
zfs()
{
	__monitor ZFS "$@"
	case "$5" in
	zroot/test-fscomp)
		echo "/zroot/test-fscomp"
		;;
	*)
		echo "zfs error"
		;;
	esac
}

ECHO=echo_stub
echo_stub()
{
	__monitor ECHO "$@"
}

# UUT
. ../share/pot/add-fscomp.sh

# common stubs
. common-stub.sh
. conf-stub.sh

test_pot_add_fscomp_101()
{
	_add_f_to_p test-fscomp test-pot test-mnt
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "$POT_ZFS_ROOT/fscomp/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt" "$ECHO_CALL1_ARG1"

	setUp
	_add_f_to_p test-fscomp test-pot test-mnt NO
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "$POT_ZFS_ROOT/fscomp/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt" "$ECHO_CALL1_ARG1"

	setUp
	_add_f_to_p zroot/test-fscomp test-pot test-mnt external
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "zroot/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt" "$ECHO_CALL1_ARG1"
}

test_pot_add_fscomp_102()
{
	_add_f_to_p test-fscomp test-pot test-mnt NO ro
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "$POT_ZFS_ROOT/fscomp/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt ro" "$ECHO_CALL1_ARG1"

	setUp
	_add_f_to_p test-fscomp test-pot test-mnt NO zfs-remount
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "$POT_ZFS_ROOT/fscomp/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt zfs-remount" "$ECHO_CALL1_ARG1"

	setUp
	_add_f_to_p zroot/test-fscomp test-pot test-mnt external ro
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "zroot/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt ro" "$ECHO_CALL1_ARG1"

	setUp
	_add_f_to_p zroot/test-fscomp test-pot test-mnt external zfs-remount
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "zroot/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt zfs-remount" "$ECHO_CALL1_ARG1"
}

test_pot_add_fscomp_103()
{
	_add_f_to_p test-fscomp test-pot /test-mnt
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "$POT_ZFS_ROOT/fscomp/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt" "$ECHO_CALL1_ARG1"
}

setUp()
{
	common_setUp
	conf_setUp
	ZFS_CALLS=0
	ECHO_CALLS=0
}

tearDown()
{
	conf_tearDown
}
. shunit/shunit2
