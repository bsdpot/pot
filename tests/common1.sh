#!/bin/sh

# system utilities stubs
. monitor.sh

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

umount()
{
	__monitor UMOUNT "$@"
}

jls()
{
	if [ "$1" = "-j" ]; then
		case "$2" in
		"pot-test"|\
		"pot-test-2")
			return 0 ## return true
		esac
		return 1
	fi
	cat << EOF--
 JID             IP Address      Hostname                      Path
 pot-test                  pot-test.pot-net       /opt/pot/jails/pot-test/m
 pot-test-2                pot-test-2.pot-net     /opt/pot/jails/pot-test-2/m
EOF--
}

sysctl()
{
	if [ -n "$SYSCTL_OUTPUT" ]; then
		echo $SYSCTL_OUTPUT
	fi
	return $SYSCTL_RC
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

test_is_pot_running()
{
	_is_pot_running
	assertNotEquals "0" "$?"

	_is_pot_running pot
	assertNotEquals "0" "$?"

	_is_pot_running pot-test
	assertNotEquals "1" "$?"

	_is_pot_running pot-test-2
	assertNotEquals "1" "$?"
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

test_is_cmd_flavorable_01()
{
	_is_cmd_flavorable
	assertNotEquals "$?" "0"

	_is_cmd_flavorable help
	assertNotEquals "$?" "0"

	_is_cmd_flavorable help create
	assertNotEquals "$?" "0"

	_is_cmd_flavorable create -p help
	assertNotEquals "$?" "0"
}

test_is_cmd_flavorable_02()
{
	_is_cmd_flavorable add-dep
	assertEquals "$?" "0"

	_is_cmd_flavorable add-dep -v -p me -P you
	assertEquals "$?" "0"

	_is_cmd_flavorable set-rss
	assertEquals "$?" "0"

	_is_cmd_flavorable add-fscomp
	assertEquals "$?" "0"
}


test_is_rctl_available()
{
	_is_rctl_available
	assertEquals "$?" "0"

	SYSCTL_OUTPUT="0"
	_is_rctl_available
	assertNotEquals "$?" "0"

	SYSCTL_OUTPUT=""
	SYSCTL_RC=1
	_is_rctl_available
	assertNotEquals "$?" "0"
}

setUp()
{
	_POT_VERBOSITY=1
	UMOUNT_CALLS=0
	SYSCTL_OUTPUT="1"
	SYSCTL_RC=0
}

. shunit/shunit2
