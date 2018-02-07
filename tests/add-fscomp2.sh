#!/bin/sh

# system utilities stubs
zfs()
{
	__monitor ZFS "$@"
	case "$5" in
	/zroot/test-fscomp)
		echo "/zroot/test-fscomp"
		;;
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

test_pot_add_fscomp_101()
{
	_add_f_to_p test-fscomp test-pot test-mnt
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "$POT_FS_ROOT/fscomp/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt" "$ECHO_CALL1_ARG1"

	setUp
	_add_f_to_p /zroot/test-fscomp test-pot test-mnt external
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "/zroot/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt" "$ECHO_CALL1_ARG1"

	setUp
	_add_f_to_p zroot/test-fscomp test-pot test-mnt external
	assertEquals "echo calls" "1" "$ECHO_CALLS"
	assertEquals "zfs calls" "0" "$ZFS_CALLS"
	assertEquals "echo arg" "/zroot/test-fscomp $POT_FS_ROOT/jails/test-pot/m/test-mnt" "$ECHO_CALL1_ARG1"
}

setUp()
{
	common_setUp
	ZFS_CALLS=0
	ECHO_CALLS=0

	POT_FS_ROOT=/tmp
	mkdir -p /tmp/jails/test-pot/conf
}

tearDown()
{
	rm -rf /tmp/jails
}
. shunit/shunit2
