#!/bin/sh

# system utilities stubs

if [ "$(uname)" = "Linux" ]; then
	TEST=/usr/bin/[
else
	TEST=/bin/[
fi

[()
{
	if ${TEST} "$1" = "!" ]; then
		if ${TEST} "$2" = "-d" ]; then
			if ${TEST} "$3" = "/jails/pot-test" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test-single" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test-nodset" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test-noconf" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test/m" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test-single/m" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/bases/base-test" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/bases/base-test-nodset" ]; then
				return 1 # false
			else
				return 0 # true
			fi
		fi
		if ${TEST} "$2" = "-r" ]; then
			if ${TEST} "$3" = "/jails/pot-test/conf/pot.conf" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test/conf/fscomp.conf" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test-single/conf/pot.conf" ]; then
				return 1 # false
			elif ${TEST} "$3" = "/jails/pot-test-single/conf/fscomp.conf" ]; then
				return 0 # true
			else
				return 0
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

_zfs_dataset_valid()
{
	if ${TEST} "$1" = "/jails/pot-test" ]; then
		return 0 # true
	elif ${TEST} "$1" = "/jails/pot-test-single" ]; then
		return 0 # true
	elif ${TEST} "$1" = "/jails/pot-test-noconf" ]; then
		return 0 # true
	fi
	if ${TEST} "$1" = "/bases/base-test" ]; then
		return 0
	fi
	return 1 # false
}

_get_pot_type()
{
	if ${TEST} "$1" = "pot-test" ]; then
		echo "multi"
	fi
	if ${TEST} "$1" = "pot-test-single" ]; then
		echo "single"
	fi
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

	_is_pot pot-test-single
	assertEquals "0" "$?"
}

test_is_base()
{
	_is_base
	assertEquals "1" "$?"

	_is_base nobase
	assertEquals "1" "$?"

	_is_base base-test-nodset
	assertEquals "2" "$?"

	_is_base base-test
	assertEquals "0" "$?"
}

. shunit/shunit2
