#!/bin/sh

# system utilities stubs
pfctl()
{
	__monitor PFCTL "$@"
}

SED=sed_stub
sed_stub()
{
	if [ "$(uname)" = "Linux" ]; then
		shift 2
		sed -i'' "$@"
	else
		sed "$@"
	fi
}

POT_MKTEMP_SUFFIX=XXX

# UUT
. ../share/pot/start.sh

# common stubs
. ../share/pot/common.sh
. ../share/pot/set-env.sh
. common-stub.sh
. conf-stub.sh

cp()
{
	:
}

pot-cmd()
{
	echo _POT_NAME=test-pot
}

test_js_env_001()
{
	_js_env test-pot
#	assertTrue "env script exists" "[ -e /tmp/pot_environment_test-pot.sh ]"
#	assertEquals "env script length" "1" "$( awk 'END {print NR}' /tmp/pot_environment_test-pot.sh)"
}

test_js_env_020()
{
	pot-set-env -p test-pot -E VAR=value
	_js_env test-pot
#	assertTrue "env script exists" "[ -e /tmp/pot_environment_test-pot.sh ]"
#	assertEquals "env script length" "2" "$( awk 'END {print NR}' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR=value"' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line2" "0" "$( grep -F -c 'export "VAR2=' /tmp/pot_environment_test-pot.sh)"

#	. /tmp/pot_environment_test-pot.sh
#	assertEquals "export validation" "$VAR" "value"
#	assertEquals "export validation" "$_POT_NAME" "test-pot"
}

test_js_env_021()
{
	pot-set-env -p test-pot -E VAR=value -E VAR2=value2
	_js_env test-pot
#	assertTrue "env script exists" "[ -e /tmp/pot_environment_test-pot.sh ]"
#	assertEquals "env script length" "3" "$( awk 'END {print NR}' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR=value"' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR2=value2"' /tmp/pot_environment_test-pot.sh)"

#	. /tmp/pot_environment_test-pot.sh
#	assertEquals "export validation" "$VAR" "value"
#	assertEquals "export validation" "$VAR2" "value2"
}

test_js_env_022()
{
	pot-set-env -p test-pot -E VAR="value1 value2"
	_js_env test-pot
#	assertTrue "env script exists" "[ -e /tmp/pot_environment_test-pot.sh ]"
#	assertEquals "env script length" "2" "$( awk 'END {print NR}' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR=value1 value2"' /tmp/pot_environment_test-pot.sh)"

#	. /tmp/pot_environment_test-pot.sh
#	assertEquals "export validation" "$VAR" "value1 value2"
}

test_js_env_023()
{
	pot-set-env -p test-pot -E "VAR=value1 value2" -E VAR2=value3
	_js_env test-pot
#	assertTrue "env script exists" "[ -e /tmp/pot_environment_test-pot.sh ]"
#	assertEquals "env script length" "3" "$( awk 'END {print NR}' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR=value1 value2"' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR2=value3"' /tmp/pot_environment_test-pot.sh)"

#	. /tmp/pot_environment_test-pot.sh
#	assertEquals "export validation" "$VAR" "value1 value2"
#	assertEquals "export validation" "$VAR2" "value3"
}

test_js_env_024()
{
	pot-set-env -p test-pot -E "EMPTYVAR="
	_js_env test-pot
#	assertTrue "env script exists" "[ -e /tmp/pot_environment_test-pot.sh ]"
#	assertEquals "env script length" "2" "$( awk 'END {print NR}' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "EMPTYVAR="' /tmp/pot_environment_test-pot.sh)"
#
#	. /tmp/pot_environment_test-pot.sh
#	assertEquals "export validation" "$EMPTYVAR" ""
}

test_js_env_025()
{
	pot-set-env -p test-pot -E "VAR=12*"
	_js_env test-pot
#	assertTrue "env script exists" "[ -e /tmp/pot_environment_test-pot.sh ]"
#	assertEquals "env script length" "2" "$( awk 'END {print NR}' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR=12*"' /tmp/pot_environment_test-pot.sh)"
#
#	. /tmp/pot_environment_test-pot.sh
#	assertEquals "export validation" "$VAR" "12*"
}

test_js_env_026()
{
	pot-set-env -p test-pot -E "VAR=12*" -E "VAR2=?h* "
	_js_env test-pot
#	assertTrue "env script exists" "[ -e /tmp/pot_environment_test-pot.sh ]"
#	assertEquals "env script length" "3" "$( awk 'END {print NR}' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR=12*"' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR2=?h* "' /tmp/pot_environment_test-pot.sh)"

#	. /tmp/pot_environment_test-pot.sh
#	assertEquals "export validation" "$VAR" "12*"
#	assertEquals "export validation" "$VAR2" "?h* "
}

test_js_env_027()
{
	pot-set-env -p test-pot -E 'VAR=value1 "value2"'
	_js_env test-pot
#	assertTrue "env script exists" "[ -e /tmp/pot_environment_test-pot.sh ]"
#	assertEquals "env script length" "2" "$( awk 'END {print NR}' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR=value1 \"value2\""' /tmp/pot_environment_test-pot.sh)"
#
#	. /tmp/pot_environment_test-pot.sh
#	assertEquals "export validation" 'value1 "value2"' "$VAR"
}

test_js_env_040()
{
	pot-set-env -p test-pot -E VAR1=value1 -E "VAR2=value1 value2" -E 'VAR3=value1 value2 value3' -E VAR4=value4
	_js_env test-pot
#	assertTrue "env script exists" "[ -e /tmp/pot_environment_test-pot.sh ]"
#	assertEquals "env script length" "5" "$( awk 'END {print NR}' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR1=value1"' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR2=value1 value2"' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR3=value1 value2 value3"' /tmp/pot_environment_test-pot.sh)"
#	assertEquals "export line" "1" "$( grep -F -c 'export "VAR4=value4"' /tmp/pot_environment_test-pot.sh)"
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
