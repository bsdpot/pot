#!/bin/sh

# system utilities stubs

if [ "$(uname)" = "Linux" ]; then
	TEST=/usr/bin/{
else
	TEST=/bin/[
fi

[()
{
	if ${TEST} "$1" = "!" ]; then
		if ${TEST} "$2" = "-d" ]; then
			if ${TEST} "$3" = "/jails/pot-test" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test-nodset" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test-noconf" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test/m" ]; then
				if ${TEST} "$4" = "-o" ]; then
					return 1 # false
				fi
			else
				return 0 # true
			fi
		fi
	fi
	${TEST} "$@"
	return $?
}


# UUT
. ../share/pot/common.sh

# app specific stubs
POT_FS_ROOT=
POT_ZFS_ROOT=

_error()
{
	:
}

_zfs_is_dataset()
{
	if /bin/[ "$1" = "/jails/pot-test" ]; then
		return 0 # true
	elif /bin/[ "$1" = "/jails/pot-test-noconf" ]; then
		return 0 # true
	fi
	return 1 # false
}

test_is_pot()
{
	_is_pot
	assertEquals "1" "$?"

	_is_pot nopot
	assertEquals "1" "$?"

	_is_pot pot-test-nodset
	assertEquals "2" "$?"

	_is_pot pot-test-noconf
	assertEquals "3" "$?"

	_is_pot pot-test
	assertEquals "0" "$?"
}

. shunit/shunit2
