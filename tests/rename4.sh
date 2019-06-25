#!/bin/sh

# system utilities stubs
ls()
{
	cat << LS_EOL
/opt/pot/jails/test-pot/
/opt/pot/jails/test-pot-2/
/opt/pot/jails/test-pot-nosnap/
LS_EOL
}

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

test_rn_recursive_001()
{
	_rn_recursive test-pot new-pot
	assertEquals "fscomp base" "zpot/bases/11.1 /tmp/jails/test-pot-2/m ro" "$(sed '1!d' /tmp/jails/test-pot-2/conf/fscomp.conf)"
	assertEquals "fscomp usr.local" "zpot/jails/new-pot/usr.local /tmp/jails/test-pot-2/m/usr/local ro" "$(sed '2!d' /tmp/jails/test-pot-2/conf/fscomp.conf)"
	assertEquals "fscomp custom" "zpot/jails/test-pot-2/custom /tmp/jails/test-pot-2/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/test-pot-2/conf/fscomp.conf)"
	assertEquals "pot.conf potbase" "pot.potbase=new-pot" "$(grep ^pot.potbase= /tmp/jails/test-pot-2/conf/pot.conf)"
	assertEquals "pot.conf depende" "pot.depend=new-pot" "$(grep ^pot.depend= /tmp/jails/test-pot-nosnap/conf/pot.conf)"
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
