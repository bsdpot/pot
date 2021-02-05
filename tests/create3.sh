#!/bin/sh

# system utilities stubs
mkdir()
{
	__monitor MKDIR "$@"
	/bin/mkdir "$@"
}

SED=sed_stub
sed_stub()
{
	__monitor SED "$@"
	if [ "$4" = "${POT_FS_ROOT}/jails/$_pname/custom/etc/crontab" ]; then
		return 0 # true
	fi
	if [ "$4" = "${POT_FS_ROOT}/jails/$_pname/custom/etc/syslog.conf" ]; then
		return 0 # true
	fi
	if [ "$(uname)" = "Linux" ]; then
		sed -i'' "$3" "$4"
	else
		sed "$@"
	fi
}

sysrc()
{
	__monitor SYSRC "$@"
}

service()
{
	__monitor SERVICE "$@"
}

cat()
{
	if [ "$1" = "${POT_FS_ROOT}/bases/11.1/.osrelease" ]; then
		echo 11.1
	fi
}

cp()
{
	__monitor CP "$@"
}

. pipefail-stub.sh

# UUT
. ../share/pot/create.sh

# common stubs
. common-stub.sh

_cj_internal_conf()
{
	__monitor ICONF "$@"
}

test_cj_conf_001()
{
	# level 0
	_cj_conf new-pot 11.1 inherit "" 0 inherit multi
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "zpot/bases/11.1 /tmp/jails/new-pot/m" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/bases/11.1/usr.local /tmp/jails/new-pot/m/usr/local" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "zpot/bases/11.1/custom /tmp/jails/new-pot/m/opt/custom" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.level" "pot.level=0" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "network_type" "network_type=inherit" "$(grep ^network_type= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip" "" "$(grep ^ip= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
	assertEquals "internal_conf calls" "1" "$ICONF_CALLS"
	assertEquals "internal_conf arg1" "new-pot" "$ICONF_CALL1_ARG1"
	assertEquals "internal_conf arg2" "multi" "$ICONF_CALL1_ARG2"
	assertEquals "internal_conf arg3" "0" "$ICONF_CALL1_ARG3"
	assertEquals "internal_conf arg4" "" "$ICONF_CALL1_ARG4"
}

test_cj_conf_002()
{
	_cj_conf new-pot 11.1 inherit "" 1 inherit multi
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "zpot/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "zpot/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "network_type" "network_type=inherit" "$(grep ^network_type= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip" "" "$(grep ^ip= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "internal_conf calls" "1" "$ICONF_CALLS"
	assertEquals "internal_conf arg1" "new-pot" "$ICONF_CALL1_ARG1"
	assertEquals "internal_conf arg2" "multi" "$ICONF_CALL1_ARG2"
	assertEquals "internal_conf arg3" "1" "$ICONF_CALL1_ARG3"
	assertEquals "internal_conf arg4" "" "$ICONF_CALL1_ARG4"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_003()
{
	/bin/mkdir -p /tmp/jails/test-pot/conf
	echo "zpot/bases/11.1 /tmp/jails/test-pot/m ro" >> /tmp/jails/test-pot/conf/fscomp.conf
	echo "zpot/jails/test-pot/usr.local /tmp/jails/test-pot/m/usr/local zfs-remount" >> /tmp/jails/test-pot/conf/fscomp.conf
	echo "zpot/jails/test-pot/custom /tmp/jails/test-pot/m/opt/custom zfs-remount" >> /tmp/jails/test-pot/conf/fscomp.conf
	_cj_conf new-pot 11.1 inherit "" 1 inherit multi "" test-pot
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "zpot/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "zpot/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/test-pot/usr.local /tmp/jails/test-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/test-pot/conf/fscomp.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=test-pot" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "network_type" "network_type=inherit" "$(grep ^network_type= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip" "" "$(grep ^ip= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "internal_conf calls" "1" "$ICONF_CALLS"
	assertEquals "internal_conf arg1" "new-pot" "$ICONF_CALL1_ARG1"
	assertEquals "internal_conf arg2" "multi" "$ICONF_CALL1_ARG2"
	assertEquals "internal_conf arg3" "1" "$ICONF_CALL1_ARG3"
	assertEquals "internal_conf arg4" "" "$ICONF_CALL1_ARG4"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_004()
{
	/bin/mkdir -p /tmp/jails/test-pot/conf
	echo "zpot/bases/11.1 /tmp/jails/test-pot/m ro" >> /tmp/jails/test-pot/conf/fscomp.conf
	echo "zpot/jails/test-pot/usr.local /tmp/jails/test-pot/m/usr/local zfs-remount" >> /tmp/jails/test-pot/conf/fscomp.conf
	echo "zpot/jails/test-pot/custom /tmp/jails/test-pot/m/opt/custom zfs-remount" >> /tmp/jails/test-pot/conf/fscomp.conf
	_cj_conf new-pot 11.1 inherit "" 2 inherit multi "" test-pot
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "zpot/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/test-pot/usr.local /tmp/jails/new-pot/m/usr/local ro" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "zpot/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/test-pot/usr.local /tmp/jails/test-pot/m/usr/local" "$(sed '2!d' /tmp/jails/test-pot/conf/fscomp.conf)"
	assertEquals "pot.level" "pot.level=2" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=test-pot" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip" "" "$(grep ^ip= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "internal_conf calls" "1" "$ICONF_CALLS"
	assertEquals "internal_conf arg1" "new-pot" "$ICONF_CALL1_ARG1"
	assertEquals "internal_conf arg2" "multi" "$ICONF_CALL1_ARG2"
	assertEquals "internal_conf arg3" "2" "$ICONF_CALL1_ARG3"
	assertEquals "internal_conf arg4" "" "$ICONF_CALL1_ARG4"
	assertEquals "sed calls" "1" "$SED_CALLS"
}

test_cj_conf_005()
{
	_cj_conf new-pot 11.1 inherit "" 2 inherit multi "" test-pot-2
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "zpot/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/test-pot/usr.local /tmp/jails/new-pot/m/usr/local ro" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "zpot/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.level" "pot.level=2" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=test-pot-2" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "network_type" "network_type=inherit" "$(grep ^network_type= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip" "" "$(grep ^ip= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "internal_conf calls" "1" "$ICONF_CALLS"
	assertEquals "internal_conf arg1" "new-pot" "$ICONF_CALL1_ARG1"
	assertEquals "internal_conf arg2" "multi" "$ICONF_CALL1_ARG2"
	assertEquals "internal_conf arg3" "2" "$ICONF_CALL1_ARG3"
	assertEquals "internal_conf arg4" "" "$ICONF_CALL1_ARG4"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_006()
{
	_cj_conf new-pot 11.1 public-bridge 10.1.2.3 1 inherit multi
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "zpot/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "zpot/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "network_type" "network_type=public-bridge" "$(grep ^network_type= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip" "ip=10.1.2.3" "$(grep ^ip= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=true" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "internal_conf calls" "1" "$ICONF_CALLS"
	assertEquals "internal_conf arg1" "new-pot" "$ICONF_CALL1_ARG1"
	assertEquals "internal_conf arg2" "multi" "$ICONF_CALL1_ARG2"
	assertEquals "internal_conf arg3" "1" "$ICONF_CALL1_ARG3"
	assertEquals "internal_conf arg4" "10.1.2.3" "$ICONF_CALL1_ARG4"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_007()
{
	_cj_conf new-pot 11.1 inherit "" 1 pot multi
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "zpot/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "zpot/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "network_type" "network_type=inherit" "$(grep ^network_type= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip" "" "$(grep ^ip= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "pot.depend=${POT_DNS_NAME}" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "sed calls" "0" "$SED_CALLS"
	assertEquals "internal_conf calls" "1" "$ICONF_CALLS"
	assertEquals "internal_conf arg1" "new-pot" "$ICONF_CALL1_ARG1"
	assertEquals "internal_conf arg2" "multi" "$ICONF_CALL1_ARG2"
	assertEquals "internal_conf arg3" "1" "$ICONF_CALL1_ARG3"
	assertEquals "internal_conf arg4" "" "$ICONF_CALL1_ARG4"
}

test_cj_conf_008()
{
	_cj_conf new-pot 11.1 public-bridge 10.1.2.3 1 pot multi
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "zpot/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "zpot/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "network_type" "network_type=public-bridge" "$(grep ^network_type= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip" "ip=10.1.2.3" "$(grep ^ip= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=true" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "pot.depend=${POT_DNS_NAME}" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "internal_conf calls" "1" "$ICONF_CALLS"
	assertEquals "internal_conf arg1" "new-pot" "$ICONF_CALL1_ARG1"
	assertEquals "internal_conf arg2" "multi" "$ICONF_CALL1_ARG2"
	assertEquals "internal_conf arg3" "1" "$ICONF_CALL1_ARG3"
	assertEquals "internal_conf arg4" "10.1.2.3" "$ICONF_CALL1_ARG4"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_009()
{
	_cj_conf new-pot 11.1 alias 10.1.2.3 1 pot multi
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "zpot/bases/11.1 /tmp/jails/new-pot/m ro" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "zpot/jails/new-pot/usr.local /tmp/jails/new-pot/m/usr/local zfs-remount" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "zpot/jails/new-pot/custom /tmp/jails/new-pot/m/opt/custom zfs-remount" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.level" "pot.level=1" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "network_type" "network_type=alias" "$(grep ^network_type= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip" "ip=10.1.2.3" "$(grep ^ip= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "pot.depend=${POT_DNS_NAME}" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "internal_conf calls" "1" "$ICONF_CALLS"
	assertEquals "internal_conf arg1" "new-pot" "$ICONF_CALL1_ARG1"
	assertEquals "internal_conf arg2" "multi" "$ICONF_CALL1_ARG2"
	assertEquals "internal_conf arg3" "1" "$ICONF_CALL1_ARG3"
	assertEquals "internal_conf arg4" "10.1.2.3" "$ICONF_CALL1_ARG4"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_020()
{
	_cj_conf new-pot 11.1 inherit "" 0 pot single
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.level" "pot.level=0" "$(grep ^pot.level /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.base" "pot.base=11.1" "$(grep ^pot.base /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "osrelease" "osrelease=\"11.1-RELEASE\"" "$(grep ^osrelease /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.potbase" "pot.potbase=" "$(grep ^pot.potbase /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "network_type" "network_type=inherit" "$(grep ^network_type= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "ip" "" "$(grep ^ip= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "vnet" "vnet=false" "$(grep ^vnet= /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "pot.depend=${POT_DNS_NAME}" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "mkdir calls" "1" "$MKDIR_CALLS"
	assertEquals "mkdir arg2" "${POT_FS_ROOT}/jails/new-pot/conf" "$MKDIR_CALL1_ARG2"
	assertEquals "internal_conf calls" "0" "$ICONF_CALLS"
	assertEquals "sed calls" "0" "$SED_CALLS"
}

test_cj_conf_040()
{
	_cj_conf new-pot 11.1 inherit "" 0 pot single
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.dns" "pot.dns=pot" "$(grep ^pot.dns /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "pot.depend=${POT_DNS_NAME}" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "cp calls" "0" "$CP_CALLS"
}

test_cj_conf_041()
{
	_cj_conf new-pot 11.1 inherit "" 0 off single
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.dns" "pot.dns=off" "$(grep ^pot.dns /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "cp calls" "0" "$CP_CALLS"
}

test_cj_conf_042()
{
	_cj_conf new-pot 11.1 inherit "" 0 inherit single
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.dns" "pot.dns=inherit" "$(grep ^pot.dns /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "cp calls" "0" "$CP_CALLS"
}

test_cj_conf_043()
{
	_cj_conf new-pot 11.1 inherit "" 0 custom:/etc/resolv.conf single
	assertEquals "return code" "0" "$?"
	assertEquals "fscomp args1" "" "$(sed '1!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args2" "" "$(sed '2!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "fscomp args3" "" "$(sed '3!d' /tmp/jails/new-pot/conf/fscomp.conf)"
	assertEquals "pot.dns" "pot.dns=custom" "$(grep ^pot.dns /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "pot.depend" "" "$(grep ^pot.depend /tmp/jails/new-pot/conf/pot.conf)"
	assertEquals "cp calls" "1" "$CP_CALLS"
	assertEquals "cp arg1" "/etc/resolv.conf" "$CP_CALL1_ARG1"
	assertEquals "cp arg2" "/tmp/jails/new-pot/conf/resolv.conf" "$CP_CALL1_ARG2"
}

setUp()
{
	common_setUp
	MKDIR_CALLS=0
	SED_CALLS=0
	SYSRC_CALLS=0
	SERVICE_CALLS=0
	CP_CALLS=0
	ICONF_CALLS=0
	ICONF_CALL1_ARG4=

	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
	POT_DNS_NAME=foobar-dns
	/bin/mkdir -p /tmp/jails/new-pot/custom/etc/syslog.d
}

tearDown()
{
	rm -rf /tmp/jails
}

. shunit/shunit2
