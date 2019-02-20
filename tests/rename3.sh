#!/bin/sh

# system utilities stubs
zfs()
{
	__monitor ZFS "$@"

}

# UUT
. ../share/pot/rename.sh

# common stubs
. common-stub.sh

_zfs_dataset_valid()
{
	__monitor ZDVALID "$@"
	case "$1" in 
		zpot/jails/test-pot|\
		zpot/jails/test-pot/usr.local|\
		zpot/jails/test-pot/custom|\
		zpot/jails/test-pot-2|\
		zpot/jails/test-pot-2/custom|\
		zpot/jails/new-pot/usr.local|\
		zpot/jails/test-pot-single|\
		zpot/jails/test-pot-single/m|\
		zpot/jails/new-pot-single/m)
			return 0 # true
			;;
	esac
	return 1 # false
}

# app specific stubs

test_rn_zfs_001()
{
	_rn_zfs test-pot new-pot
	assertEquals "_zfs_dataset_valid calls" "4" "${ZDVALID_CALLS}"
	assertEquals "zfs calls" "9" "${ZFS_CALLS}"
	assertEquals "zfs c1 args" "umount" "${ZFS_CALL1_ARG1}"
	assertEquals "zfs c1 args" "zpot/jails/test-pot/usr.local" "${ZFS_CALL1_ARG3}"
	assertEquals "zfs c3 args" "umount" "${ZFS_CALL3_ARG1}"
	assertEquals "zfs c3 args" "zpot/jails/test-pot/custom" "${ZFS_CALL3_ARG3}"
	assertEquals "zfs c5 args" "umount" "${ZFS_CALL5_ARG1}"
	assertEquals "zfs c5 args" "zpot/jails/test-pot" "${ZFS_CALL5_ARG3}"
	assertEquals "zfs c6 args" "rename" "${ZFS_CALL6_ARG1}"
	assertEquals "zfs c6 args" "zpot/jails/test-pot" "${ZFS_CALL6_ARG2}"
	assertEquals "zfs c6 args" "zpot/jails/new-pot" "${ZFS_CALL6_ARG3}"
}

test_rn_zfs_002()
{
	_rn_zfs test-pot-2 new-pot-2
	assertEquals "_zfs_dataset_valid calls" "4" "${ZDVALID_CALLS}"
	assertEquals "zfs calls" "6" "${ZFS_CALLS}"
	assertEquals "zfs c1 args" "umount" "${ZFS_CALL1_ARG1}"
	assertEquals "zfs c1 args" "zpot/jails/test-pot-2/custom" "${ZFS_CALL1_ARG3}"
	assertEquals "zfs c3 args" "umount" "${ZFS_CALL3_ARG1}"
	assertEquals "zfs c3 args" "zpot/jails/test-pot-2" "${ZFS_CALL3_ARG3}"
	assertEquals "zfs c4 args" "rename" "${ZFS_CALL4_ARG1}"
	assertEquals "zfs c4 args" "zpot/jails/test-pot-2" "${ZFS_CALL4_ARG2}"
	assertEquals "zfs c4 args" "zpot/jails/new-pot-2" "${ZFS_CALL4_ARG3}"
}

test_rn_zfs_003()
{
	_rn_zfs test-pot-single new-pot-single
	assertEquals "_zfs_dataset_valid calls" "3" "${ZDVALID_CALLS}"
	assertEquals "zfs calls" "6" "${ZFS_CALLS}"
	assertEquals "zfs c1 args" "umount" "${ZFS_CALL1_ARG1}"
	assertEquals "zfs c1 args" "zpot/jails/test-pot-single/m" "${ZFS_CALL1_ARG3}"
	assertEquals "zfs c3 args" "umount" "${ZFS_CALL3_ARG1}"
	assertEquals "zfs c3 args" "zpot/jails/test-pot-single" "${ZFS_CALL3_ARG3}"
	assertEquals "zfs c4 args" "rename" "${ZFS_CALL4_ARG1}"
	assertEquals "zfs c4 args" "zpot/jails/test-pot-single" "${ZFS_CALL4_ARG2}"
	assertEquals "zfs c4 args" "zpot/jails/new-pot-single" "${ZFS_CALL4_ARG3}"
}

setUp()
{
	common_setUp
	ZFS_CALLS=0
	ZDVALID_CALLS=0

	POT_ZFS_ROOT=zpot
}

. shunit/shunit2
