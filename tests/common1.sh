#!/bin/sh -x

# system utilities stubs
mount()
{
	cat << EOF--
zroot on /zroot (zfs, local, noatime, nfsv4acls)
zroot/ROOT/default on / (zfs, local, noatime, nfsv4acls)
devfs on /dev (devfs, local, multilabel)
zroot/tmp on /tmp (zfs, local, noatime, nosuid, nfsv4acls)
zroot/usr/home on /usr/home (zfs, local, noatime, nfsv4acls)
zroot/usr/src on /usr/src (zfs, local, noatime, nfsv4acls)
zroot/var/audit on /var/audit (zfs, local, noatime, noexec, nosuid, nfsv4acls)
zroot/var/crash on /var/crash (zfs, local, noatime, noexec, nosuid, nfsv4acls)
zroot/var/log on /var/log (zfs, local, noatime, noexec, nosuid, nfsv4acls)
zroot/var/mail on /var/mail (zfs, local, nfsv4acls)
zroot/var/tmp on /var/tmp (zfs, local, noatime, nosuid, nfsv4acls)
/opt/pot/fscomp/distfiles on /opt/distfiles (nullfs, local)
EOF--
}

UMOUNT_CALLS=0
UMOUNT_CALL1_ARG1=
UMOUNT_CALL1_ARG2=
UMOUNT_CALL1_ARG3=
umount()
{
	UMOUNT_CALLS=$(( UMOUT_CALLS + 1 ))
	UMOUNT_CALL1_ARG1="$1"
	UMOUNT_CALL1_ARG2="$2"
	UMOUNT_CALL1_ARG3="$3"
}

# UUT
. ../share/pot/common.sh

# app specific stubs

test_is_verbose()
{
	_is_verbose
	assertNotEquals "0" "$?"

	_POT_VERBOSITY=2
	_is_verbose
	assertEquals "0" "$?"
}

test_is_in_list()
{
	_is_in_list
	assertNotEquals "0" "$?"
	_is_in_list "asdf"
	assertNotEquals "0" "$?"
	_is_in_list "asdf" ""
	assertNotEquals "0" "$?"
	_is_in_list "asdf" "asdf1 asdf2"
	assertNotEquals "0" "$?"

	_is_in_list "val" "val val1 val2"
	assertEquals "0" "$?"
	_is_in_list "val" "val1 val val2"
	assertEquals "0" "$?"
	_is_in_list "val" "val1 val2 val"
	assertEquals "0" "$?"
	_is_in_list "val" "val"
	assertEquals "0" "$?"
	_is_in_list "val" "val val"
	assertEquals "0" "$?"
}

test_is_mounted()
{
	_is_mounted
	assertNotEquals "0" "$?"
	_is_mounted /path/to/the/error
	assertNotEquals "0" "$?"
	_is_mounted /path/to/the/error ignored
	assertNotEquals "0" "$?"
	_is_mounted zroot/var/log
	assertNotEquals "0" "$?"

	_is_mounted /opt/distfiles
	assertEquals "0" "$?"
	_is_mounted /opt/distfiles ignored
	assertEquals "0" "$?"
}

test_umount()
{
	_umount
	assertEquals "0" "$UMOUNT_CALLS"

	_umount /path/to/the/error
	assertEquals "0" "$UMOUNT_CALLS"

	_umount /opt/distfiles
	assertEquals "1" "$UMOUNT_CALLS"
	assertEquals "-f" "$UMOUNT_CALL1_ARG1"
	assertEquals "/opt/distfiles" "$UMOUNT_CALL1_ARG2"

}

setUp()
{
	_POT_VERBOSITY=1
	UMOUNT_CALLS=0
}

if [ -r shunit/shunit2 ]; then
	. shunit/shunit2 
else
	echo "shunit2 not found :("
fi
