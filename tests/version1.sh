#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/version.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
version-help()
{
	__monitor HELP "$@"
}

test_pot_version_001()
{
	pot-version -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS

	setUp
	pot-version -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
}

test_pot_version_020()
{
	result=$(pot-version)
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Incorrect version" "pot version: $_POT_VERSION" "$result"
}

test_pot_version_021()
{
	result=$(pot-version -v)
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Incorrect version" "pot version: $_POT_VERSION" "$result"
}

test_pot_version_022()
{
	result=$(pot-version -q)
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Incorrect version" "$_POT_VERSION" "$result"
}

setUp()
{
	common_setUp
	_POT_VERSION="5.4.3"
	_POT_VERBOSITY="1"

}

. shunit/shunit2
