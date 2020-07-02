#!/bin/sh

# system utilities stubs
pfctl()
{
	__monitor PFCTL "$@"
}

# UUT
. ../share/pot/start.sh

POT_MKTEMP_SUFFIX=XX

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
	*)
		;;
	esac
}

test_js_export_ports_001()
{
	_js_export_ports test-pot80
	assertEquals "pfctl calls" "1" "$PFCTL_CALLS"
#	assertEquals "pfrules lines" "1" "$( wc -l /tmp/pot_test-pot80_pfrules | awk '{print $1}')"
#	assertEquals "rdr rule" "rdr pass on em2 proto tcp from any to em2 port 3333 -> 1.2.3.4 port 80" "$(sed '1!d' /tmp/pot_test-pot80_pfrules)"
}


test_js_export_ports_002()
{
	_js_export_ports test-pot80s3000
	assertEquals "pfctl calls" "1" "$PFCTL_CALLS"
#	assertEquals "pfrules lines" "1" "$( wc -l /tmp/pot_test-pot80s3000_pfrules | awk '{print $1}')"
#	assertEquals "rdr rule" "rdr pass on em2 proto tcp from any to em2 port 3000 -> 1.2.3.4 port 80" "$(sed '1!d' /tmp/pot_test-pot80s3000_pfrules)"
}

test_js_export_ports_003()
{
	_js_export_ports test-pot80433
	assertEquals "pfctl calls" "1" "$PFCTL_CALLS"
#	assertEquals "pfrules lines" "2" "$( wc -l /tmp/pot_test-pot80433_pfrules | awk '{print $1}')"
#	assertEquals "rdr rule" "rdr pass on em2 proto tcp from any to em2 port 3333 -> 1.2.3.4 port 80" "$(sed '1!d' /tmp/pot_test-pot80433_pfrules)"
#	assertEquals "rdr rule" "rdr pass on em2 proto tcp from any to em2 port 3000 -> 1.2.3.4 port 433" "$(sed '2!d' /tmp/pot_test-pot80433_pfrules)"
}

setUp()
{
	common_setUp
	PFCTL_CALLS=0
	GETEXPORTPORTS_CALLS=0
	RNDPORT_CALLS=0

	POT_FS_ROOT=/tmp
	POT_ZFS_ROOT=zpot
	POT_EXTIF="em2"
}

. shunit/shunit2
