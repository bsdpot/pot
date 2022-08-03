#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/add-dep.sh

# common stubs
. common-stub.sh

# app specific stubs
add-dep-help()
{
	__monitor HELP "$@"
}

_add_dependency()
{
	__monitor ADDDEP "$@"
}

test_pot_add_dep_001()
{
	pot-add-dep
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_add_dependency calls" "0" ADDDEP_CALLS

	setUp
	pot-add-dep -vb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_add_dependency calls" "0" ADDDEP_CALLS

	setUp
	pot-add-dep -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_add_dependency calls" "0" ADDDEP_CALLS

	setUp
	pot-add-dep -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_add_dependency calls" "0" ADDDEP_CALLS
}

test_pot_add_dep_002()
{
	pot-add-dep -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_add_dependency calls" "0" ADDDEP_CALLS

	setUp
	pot-add-dep -P test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_add_dependency calls" "0" ADDDEP_CALLS

	setUp
	pot-add-dep -P test-pot -p test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "1" ISPOT_CALLS
	assertEqualsMon "_add_dependency calls" "0" ADDDEP_CALLS

	setUp
	pot-add-dep -p test-pot -P test-no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "2" ISPOT_CALLS
	assertEqualsMon "_add_dependency calls" "0" ADDDEP_CALLS

	setUp
	pot-add-dep -P test-pot -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "0" ISPOT_CALLS
	assertEqualsMon "_add_dependency calls" "0" ADDDEP_CALLS
}

test_pot_add_dep_020()
{
	pot-add-dep -P test-pot -p test-pot-2
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_pot calls" "2" ISPOT_CALLS
	assertEqualsMon "_add_dependency calls" "1" ADDDEP_CALLS
	assertEqualsMon "pot name " "test-pot-2" ADDDEP_CALL1_ARG1
	assertEqualsMon "run time dependency" "test-pot" ADDDEP_CALL1_ARG2
}

setUp()
{
	common_setUp
}

. shunit/shunit2
