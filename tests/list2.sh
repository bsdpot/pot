#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/list.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
zfs()
{
	if [ "$1" = "list" ]; then
		if [ "$6" = "zroot/pot1/fscomp" ]; then
			echo "zroot/pot1/fscomp"
			echo "zroot/pot1/fscomp/fscomp1"
		elif [ "$6" = "zroot/pot2/fscomp" ]; then
			echo "zroot/pot1/fscomp"
			echo "zroot/pot2/fscomp/fscomp1"
			echo "zroot/pot2/fscomp/fscomp2"
		elif [ "$6" = "zroot/pot3/fscomp" ]; then
			echo "zroot/pot1/fscomp"
			echo "zroot/pot3/fscomp/fscomp1"
			echo "zroot/pot3/fscomp/fscomp2"
			echo "zroot/pot3/fscomp/fscomp3"
		else
			echo "error2"
		fi
	else
		echo "error"
	fi
}

test_pot_list_fscomp001()
{
	POT_ZFS_ROOT=zroot/pot1
	rc=$( _ls_fscomp )
	assertEquals "rc" "fscomp: fscomp1" "$rc"
}

test_pot_list_fscomp002()
{
	POT_ZFS_ROOT=zroot/pot2
	rc=$( _ls_fscomp | tr '\n' ' ')
	assertEquals "rc" "fscomp: fscomp1 fscomp: fscomp2 " "$rc"
}

test_pot_list_fscomp003()
{
	POT_ZFS_ROOT=zroot/pot3
	rc=$( _ls_fscomp | tr '\n' ' ')
	assertEquals "rc" "fscomp: fscomp1 fscomp: fscomp2 fscomp: fscomp3 " "$rc"
}

setUp()
{
	common_setUp
}

. shunit/shunit2
