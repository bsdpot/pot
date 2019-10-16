#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/set-env.sh
. ../share/pot/common.sh

# common stubs
. conf-stub.sh

test_set_environment_000()
{
	cat > /tmp/pot-set-env << EOF_SETENV
"VAR=value"
EOF_SETENV
	_set_environment test-pot /tmp/pot-set-env

	assertEquals "pot.env lines" "1" "$(grep -c "^pot.env=" /tmp/jails/test-pot/conf/pot.conf)" 
	assertEquals "pot.env args" 'pot.env="VAR=value"' "$(grep ^pot.env /tmp/jails/test-pot/conf/pot.conf)"
}

test_set_environment_001()
{
	cat > /tmp/pot-set-env << EOF_SETENV
"VAR=value"
"VAR2=value2"
EOF_SETENV
	_set_environment test-pot /tmp/pot-set-env

	assertEquals "pot.env lines" "2" "$(grep -c "^pot.env=" /tmp/jails/test-pot/conf/pot.conf)" 
	assertEquals "pot.env args" 'pot.env="VAR=value"' "$(grep "^pot.env=\"VAR=" /tmp/jails/test-pot/conf/pot.conf)"
	assertEquals "pot.env args" 'pot.env="VAR2=value2"' "$(grep "^pot.env=\"VAR2=" /tmp/jails/test-pot/conf/pot.conf)"
}

test_set_environment_002()
{
	cat > /tmp/pot-set-env << EOF_SETENV
"VAR=value1 value2"
EOF_SETENV
	_set_environment test-pot /tmp/pot-set-env
	assertEquals "pot.env lines" "1" "$(grep -c "^pot.env=" /tmp/jails/test-pot/conf/pot.conf)" 
	assertEquals "pot.env args" 'pot.env="VAR=value1 value2"' "$(grep ^pot.env /tmp/jails/test-pot/conf/pot.conf)"
}

test_set_environment_003()
{
	cat > /tmp/pot-set-env << EOF_SETENV
"VAR=value1 value2"
"VAR2=value3"
EOF_SETENV
	_set_environment test-pot /tmp/pot-set-env
	assertEquals "pot.env lines" "2" "$(grep -c "^pot.env=" /tmp/jails/test-pot/conf/pot.conf)" 
	assertEquals "pot.env args" 'pot.env="VAR=value1 value2"' "$(grep "^pot.env=\"VAR=" /tmp/jails/test-pot/conf/pot.conf)"
	assertEquals "pot.env args" 'pot.env="VAR2=value3"' "$(grep "^pot.env=\"VAR2=" /tmp/jails/test-pot/conf/pot.conf)"
}

test_set_environment_004()
{
	cat > /tmp/pot-set-env << EOF_SETENV
"EMPTYVAR="
EOF_SETENV
	_set_environment test-pot /tmp/pot-set-env
	assertEquals "pot.env lines" "1" "$(grep -c "^pot.env=" /tmp/jails/test-pot/conf/pot.conf)" 
	assertEquals "pot.env args" 'pot.env="EMPTYVAR="' "$(grep ^pot.env /tmp/jails/test-pot/conf/pot.conf)"
}

test_set_environment_005()
{
	cat > /tmp/pot-set-env << EOF_SETENV
"VAR=12*"
EOF_SETENV
	_set_environment test-pot /tmp/pot-set-env
	assertEquals "pot.env lines" "1" "$(grep -c "^pot.env=" /tmp/jails/test-pot/conf/pot.conf)" 
	assertEquals "pot.env args" 'pot.env="VAR=12*"' "$(grep ^pot.env /tmp/jails/test-pot/conf/pot.conf)"
}

test_set_environment_006()
{
	cat > /tmp/pot-set-env << EOF_SETENV
"VAR=12*"
"VAR2=?h* "
EOF_SETENV
	_set_environment test-pot /tmp/pot-set-env
	assertEquals "pot.env lines" "2" "$(grep -c "^pot.env=" /tmp/jails/test-pot/conf/pot.conf)" 
	assertEquals "pot.env args" 'pot.env="VAR=12*"' "$(grep "^pot.env=\"VAR=" /tmp/jails/test-pot/conf/pot.conf)"
	assertEquals "pot.env args" 'pot.env="VAR2=?h* "' "$(grep "^pot.env=\"VAR2=" /tmp/jails/test-pot/conf/pot.conf)"
}

test_set_environment_007()
{
	cat > /tmp/pot-set-env << EOF_SETENV
"VAR=value1 \"value2\""
EOF_SETENV
	_set_environment test-pot /tmp/pot-set-env
	assertEquals "pot.env lines" "1" "$(grep -c "^pot.env=" /tmp/jails/test-pot/conf/pot.conf)" 
	assertEquals "pot.env args" 'pot.env="VAR=value1 \"value2\""' "$(grep "^pot.env=\"VAR=" /tmp/jails/test-pot/conf/pot.conf)"
}

setUp()
{
	conf_setUp
}

tearDown()
{
	conf_tearDown
	/bin/rm -f /tmp/pot-set-env
}
. shunit/shunit2
