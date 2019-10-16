#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/set-env.sh

# common stubs
. common-stub.sh

# app specific stubs
set-env-help()
{
	__monitor HELP "$@"
}

rm()
{
	__monitor RM "$@"
}

_set_environment()
{
	__monitor SETENV "$@"
}

test_pot_set_env_001()
{
	pot-set-env
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "0" "$SETENV_CALLS"

	setUp
	pot-set-env -bv
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "0" "$SETENV_CALLS"

	setUp
	pot-set-env -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "0" "$SETENV_CALLS"

	setUp
	pot-set-env -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "0" "$SETENV_CALLS"
}

test_pot_set_env_002()
{
	pot-set-env -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "0" "$SETENV_CALLS"

	setUp
	pot-set-env -E VAR=value
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "0" "$SETENV_CALLS"
}

test_pot_set_env_020()
{
	pot-set-env -p test-no-pot -E VAR=value
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "0" "$SETENV_CALLS"
}

test_pot_set_env_021()
{
	pot-set-env -p test-pot -E NOVAR
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "2" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "0" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "0" "$SETENV_CALLS"
}

test_pot_set_env_040()
{
	pot-set-env -p test-pot -E VAR=value
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_set_environment arg1" "test-pot" "$SETENV_CALL1_ARG1"
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR=value"' "$(sed '1!d' /tmp/pot-set-env)"
}

test_pot_set_env_041()
{
	pot-set-env -p test-pot -E VAR=value -E VAR2=value2
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_tmpfile length" "2" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR=value"' "$(sed '1!d' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR2=value2"' "$(sed '2!d' /tmp/pot-set-env)"
}

test_pot_set_env_042()
{
	pot-set-env -p test-pot -E VAR="value1 value2"
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_set_environment arg1" "test-pot" "$SETENV_CALL1_ARG1"
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR=value1 value2"' "$(sed '1!d' /tmp/pot-set-env)"
}

test_pot_set_env_043()
{
	pot-set-env -p test-pot -E VAR="value1 value2" -E VAR2=value3
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_set_environment arg1" "test-pot" "$SETENV_CALL1_ARG1"
	assertEquals "_tmpfile length" "2" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR=value1 value2"' "$(sed '1!d' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR2=value3"' "$(sed '2!d' /tmp/pot-set-env)"
}

test_pot_set_env_044()
{
	pot-set-env -p test-pot -E EMPTYVAR=
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_set_environment arg1" "test-pot" "$SETENV_CALL1_ARG1"
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"EMPTYVAR="' "$(sed '1!d' /tmp/pot-set-env)"
}

test_pot_set_env_045()
{
	pot-set-env -p test-pot -E VAR="12*"
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_set_environment arg1" "test-pot" "$SETENV_CALL1_ARG1"
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR=12*"' "$(sed '1!d' /tmp/pot-set-env)"
}

test_pot_set_env_046()
{
	pot-set-env -p test-pot -E VAR='12*' -E 'VAR2=?h* '
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_set_environment arg1" "test-pot" "$SETENV_CALL1_ARG1"
	assertEquals "_tmpfile length" "2" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR=12*"' "$(sed '1!d' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR2=?h* "' "$(sed '2!d' /tmp/pot-set-env)"
}

test_pot_set_env_060()
{
	pot-set-env -p test-pot -E "VAR=value1 value2"
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_set_environment arg1" "test-pot" "$SETENV_CALL1_ARG1"
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR=value1 value2"' "$(sed '1!d' /tmp/pot-set-env)"
}

test_pot_set_env_061()
{
	pot-set-env -p test-pot -E VAR="value1 value2"
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_set_environment arg1" "test-pot" "$SETENV_CALL1_ARG1"
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR=value1 value2"' "$(sed '1!d' /tmp/pot-set-env)"
}

test_pot_set_env_062()
{
	pot-set-env -p test-pot -E 'VAR=value1 value2'
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_set_environment arg1" "test-pot" "$SETENV_CALL1_ARG1"
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR=value1 value2"' "$(sed '1!d' /tmp/pot-set-env)"
}

test_pot_set_env_063()
{
	pot-set-env -p test-pot -E VAR='value1 value2'
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_pot calls" "1" "$ISPOT_CALLS"
	assertEquals "_set_environment calls" "1" "$SETENV_CALLS"
	assertEquals "_set_environment arg1" "test-pot" "$SETENV_CALL1_ARG1"
	assertEquals "_tmpfile length" "1" "$( awk 'END {print NR}' /tmp/pot-set-env)"
	assertEquals "_tmpfile" '"VAR=value1 value2"' "$(sed '1!d' /tmp/pot-set-env)"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	SETENV_CALLS=0
	/bin/rm -f /tmp/pot-set-env
}

tearDown()
{
	/bin/rm -f /tmp/pot-set-env
}


. shunit/shunit2
