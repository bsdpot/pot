#!/bin/sh

conf_setUp()
{
	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot

	/bin/mkdir -p /tmp/jails/test-pot/conf
	{
		echo "zpot/bases/11.1 /tmp/jails/test-pot/m ro" 
		echo "zpot/jails/test-pot/usr.local /tmp/jails/test-pot/m/usr/local zfs-remount"
		echo "zpot/jails/test-pot/custom /tmp/jails/test-pot/m/opt/custom zfs-remount"
	} > /tmp/jails/test-pot/conf/fscomp.conf
	{
		echo "host.hostname=\"test-pot.test\""
		echo "pot.potbase="
	} > /tmp/jails/test-pot/conf/pot.conf

	/bin/mkdir -p /tmp/jails/test-pot-2/conf
	{
		echo "zpot/bases/11.1 /tmp/jails/test-pot-2/m ro"
		echo "zpot/jails/test-pot/usr.local /tmp/jails/test-pot-2/m/usr/local ro"
		echo "zpot/jails/test-pot-2/custom /tmp/jails/test-pot-2/m/opt/custom zfs-remount"
	} > /tmp/jails/test-pot-2/conf/fscomp.conf
	{
		echo "host.hostname=\"test-pot-2.test\""
		echo "pot.potbase=test-pot"
	} > /tmp/jails/test-pot-2/conf/pot.conf

	/bin/mkdir -p /tmp/jails/test-pot-nosnap/conf
	{
		echo "zpot/bases/11.1 /tmp/jails/test-pot-nosnap/m ro"
		echo "zpot/jails/test-pot-nosnap/usr.local /tmp/jails/test-pot-nosnap/m/usr/local zfs-remount"
		echo "zpot/jails/test-pot-nosnap/custom /tmp/jails/test-pot-nosnap/m/opt/custom zfs-remount"
	} > /tmp/jails/test-pot-nosnap/conf/fscomp.conf
	{
		echo "host.hostname=\"test-pot-nosnap.test\""
		echo "pot.potbase="
		echo "pot.depend=test-pot"
	} > /tmp/jails/test-pot-nosnap/conf/pot.conf

	/bin/mkdir -p /tmp/jails/test-pot-single/conf
	touch /tmp/jails/test-pot-single/conf/fscomp.conf
	{
		echo "host.hostname=\"test-pot-single.test\""
		echo "pot.potbase="
	} > /tmp/jails/test-pot-single/conf/pot.conf

	/bin/mkdir -p /tmp/jails/test-pot-single-run/conf
	{
		echo "zpot/fscomp/examples /tmp/jails/test-pot-single-run/m/tmp/examples ro"
	} > /tmp/jails/test-pot-single-run/conf/fscomp.conf
	{
		echo "host.hostname=\"test-pot-single-run.test\""
		echo "pot.potbase="
	} > /tmp/jails/test-pot-single-run/conf/pot.conf
}

conf_tearDown()
{
	rm -rf /tmp/jails
}

