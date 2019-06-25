#!/bin/sh

# system utilities stubs
SED=sed_stub
sed_stub()
{
	if [ "$(uname)" = "Linux" ]; then
		sed -i'' "$3" "$4"
	else
		sed "$@"
	fi
}

# UUT
. ../share/pot/rename.sh

# common stubs
. common-stub.sh
. conf-stub.sh

# app specific stubs


test_rn_conf_001()
{
	_rn_conf test-pot new-pot
	assertEquals "fscomp args1" "zpot/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/test-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/test-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "zpot/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/test-pot/conf/fscomp.conf)"
	assertEquals "host.hostname" "host.hostname=\"new-pot.test\"" "$(grep ^host.hostname /tmp/jails/test-pot/conf/pot.conf)"
}

setUp()
{
	common_setUp
	conf_setUp
}

tearDown()
{
	conf_tearDown
}
. shunit/shunit2
