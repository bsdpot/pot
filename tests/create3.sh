#!/bin/sh

# system utilities stubs
mkdir()
{
	__monitor MKDIR "$@"
	/bin/mkdir $@
}

SED=sed_stub
sed_stub()
{
	__monitor SED "$@"
}

# UUT
. ../share/pot/create.sh

# common stubs
. common-stub.sh

test_cj_conf_001()
{
	# level 0
	_cj_conf new-pot 11.1 inherit NO 0 inherit
	assertEquals "return code" "0" "$?"
	assertEquals "echo args1" "/tmp/bases/11.1 /tmp/jails/new-pot/m" "$(sed '1!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args2" "/tmp/bases/11.1/usr/local /tmp/jails/new-pot/m/usr/local" "$(sed '2!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args3" "/tmp/bases/11.1/opt/custom /tmp/jails/new-pot/m/opt/custom" "$(sed '3!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "pot.level" "pot.level=0" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip4" "ip4=inherit" "$(grep ^ip4= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_002()
{
	_cj_conf new-pot 11.1 inherit NO 1 inherit
	assertEquals "return code" "0" "$?"
	assertEquals "echo args1" "/tmp/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args2" "/tmp/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args3" "/tmp/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip4" "ip4=inherit" "$(grep ^ip4= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_003()
{
	_cj_conf new-pot 11.1 inherit NO 1 inherit test-pot
	assertEquals "return code" "0" "$?"
	assertEquals "echo args1" "/tmp/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args2" "/tmp/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args3" "/tmp/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=test-pot" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip4" "ip4=inherit" "$(grep ^ip4= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_004()
{
	_cj_conf new-pot 11.1 inherit NO 2 inherit test-pot
	assertEquals "return code" "0" "$?"
	assertEquals "echo args1" "/tmp/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args2" "/tmp/jails/test-pot/usr.local /tmp/jails/new-pot/m/usr/local ro" "$(sed '2!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args3" "/tmp/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "pot.level" "pot.level=2" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=test-pot" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip4" "ip4=inherit" "$(grep ^ip4= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "1" "$SED_CALLS"
}

test_cj_conf_005()
{
	_cj_conf new-pot 11.1 inherit NO 2 inherit test-pot-2
	assertEquals "return code" "0" "$?"
	assertEquals "echo args1" "/tmp/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args2" "/tmp/jails/test-pot/usr.local /tmp/jails/new-pot/m/usr/local ro" "$(sed '2!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args3" "/tmp/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "pot.level" "pot.level=2" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=test-pot-2" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip4" "ip4=inherit" "$(grep ^ip4= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_006()
{
	_cj_conf new-pot 11.1 10.1.2.3 NO 1 inherit
	assertEquals "return code" "0" "$?"
	assertEquals "echo args1" "/tmp/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args2" "/tmp/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args3" "/tmp/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip4" "ip4=10.1.2.3" "$(grep ^ip4= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=true" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_007()
{
	_cj_conf new-pot 11.1 inherit NO 1 pot
	assertEquals "return code" "0" "$?"
	assertEquals "echo args1" "/tmp/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args2" "/tmp/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args3" "/tmp/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip4" "ip4=inherit" "$(grep ^ip4= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "pot.depend=${POT_DNS_NAME}" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_008()
{
	_cj_conf new-pot 11.1 10.1.2.3 NO 1 pot
	assertEquals "return code" "0" "$?"
	assertEquals "echo args1" "/tmp/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args2" "/tmp/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args3" "/tmp/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip4" "ip4=10.1.2.3" "$(grep ^ip4= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=true" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "pot.depend=${POT_DNS_NAME}" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_009()
{
	_cj_conf new-pot 11.1 10.1.2.3 YES 1 pot
	assertEquals "return code" "0" "$?"
	assertEquals "echo args1" "/tmp/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args2" "/tmp/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args3" "/tmp/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip4" "ip4=10.1.2.3" "$(grep ^ip4= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "pot.depend=${POT_DNS_NAME}" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_020()
{
	_cj_conf new-pot 11.1 inherit YES 1 pot
	assertEquals "return code" "0" "$?"
	assertEquals "echo args1" "/tmp/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args2" "/tmp/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "echo args3" "/tmp/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fs.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip4" "ip4=inherit" "$(grep ^ip4= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "pot.depend=${POT_DNS_NAME}" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
}
setUp()
{
	common_setUp
	MKDIR_CALLS=0
	SED_CALLS=0

	POT_FS_ROOT=/tmp
	POT_DNS_NAME=foobar-dns
}

tearDown()
{
	rm -rf /tmp/jails
}

. shunit/shunit2
