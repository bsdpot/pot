#!/bin/sh

: ${MKTEMP_FILE:=/tmp/pot_pfrules_test}
# system utilities stubs
pfctl()
{
	__monitor PFCTL "$@"
}

mktemp()
{
	touch $MKTEMP_FILE
	echo $MKTEMP_FILE
}

rm()
{
	:
}

# UUT
. ../share/pot/start.sh

POT_MKTEMP_SUFFIX=XXX

# common stubs
. common-stub.sh

_get_pot_export_ports()
{
	__monitor GETEXPORTPORTS "$@"
}

_js_get_free_rnd_port()
{
	__monitor RNDPORT "$@"
	echo 3333
}

_get_ip_var()
{
	echo 1.2.3.4
}

_get_pot_export_ports()
{
	case $1 in
	"test-pot80")
		echo 80
		;;
	"test-pot80s3000")
		echo 80:3000
		;;
	"test-pot80433")
		echo 80 433:3000
		;;
	"test-pot53udp80433tcp")
		echo udp:53:53 tcp:80 tcp:433:3000
		;;
	*)
		;;
	esac
}

test_js_export_ports_001()
{
	_js_export_ports test-pot80
	assertEqualsMon "pfctl calls" "1" PFCTL_CALLS
	assertEquals "pfrules lines" "1" "$( wc -l $MKTEMP_FILE | awk '{print $1}')"
	assertEquals "rdr rule" "rdr pass on em2 proto tcp from any to (em2) port 3333 -> 1.2.3.4 port 80" "$(sed '1!d' $MKTEMP_FILE)"
}


test_js_export_ports_002()
{
	_js_export_ports test-pot80s3000
	assertEqualsMon "pfctl calls" "1" PFCTL_CALLS
	assertEquals "pfrules lines" "1" "$( wc -l $MKTEMP_FILE | awk '{print $1}')"
	assertEquals "rdr rule" "rdr pass on em2 proto tcp from any to (em2) port 3000 -> 1.2.3.4 port 80" "$(sed '1!d' $MKTEMP_FILE)"
}

test_js_export_ports_003()
{
	_js_export_ports test-pot80433
	assertEqualsMon "pfctl calls" "1" PFCTL_CALLS
	assertEquals "pfrules lines" "2" "$( wc -l $MKTEMP_FILE | awk '{print $1}')"
	assertEquals "rdr rule" "rdr pass on em2 proto tcp from any to (em2) port 3333 -> 1.2.3.4 port 80" "$(sed '1!d' $MKTEMP_FILE)"
	assertEquals "rdr rule" "rdr pass on em2 proto tcp from any to (em2) port 3000 -> 1.2.3.4 port 433" "$(sed '2!d' $MKTEMP_FILE)"
}

test_js_export_ports_004()
{
	_js_export_ports test-pot53udp80433tcp
	assertEqualsMon "pfctl calls" "1" PFCTL_CALLS
	assertEquals "pfrules lines" "3" "$( wc -l $MKTEMP_FILE | awk '{print $1}')"
	assertEquals "rdr rule" "rdr pass on em2 proto udp from any to (em2) port 53 -> 1.2.3.4 port 53" "$(sed '1!d' $MKTEMP_FILE)"
	assertEquals "rdr rule" "rdr pass on em2 proto tcp from any to (em2) port 3333 -> 1.2.3.4 port 80" "$(sed '2!d' $MKTEMP_FILE)"
	assertEquals "rdr rule" "rdr pass on em2 proto tcp from any to (em2) port 3000 -> 1.2.3.4 port 433" "$(sed '3!d' $MKTEMP_FILE)"
}
setUp()
{
	common_setUp
	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
	POT_EXTIF="em2"
}

tearDown()
{
	common_tearDown
	/bin/rm -f $MKTEMP_FILE
}
. shunit/shunit2
