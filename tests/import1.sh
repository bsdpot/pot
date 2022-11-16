#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/import.sh

. ../share/pot/common.sh

# common stubs
. common-stub.sh

# app specific stubs
import-help()
{
	__monitor HELP "$@"
}

_fetch_pot()
{
	__monitor FETCHPOT "$@"
}

_import_pot()
{
	__monitor IMPORTS "$@"
}

# only has to exist, isn't called in tests
signify()
{
	true
}

test_pot_import_001()
{
	pot-import -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "0" FETCHPOT_CALLS
	assertEqualsMon "_import calls" "0" IMPORTS_CALLS

	setUp
	pot-import -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "0" FETCHPOT_CALLS
	assertEqualsMon "_import calls" "0" IMPORTS_CALLS
}

test_pot_import_020()
{
	pot-import -p
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "0" FETCHPOT_CALLS
	assertEqualsMon "_import calls" "0" IMPORTS_CALLS
}

test_pot_import_021()
{
	pot-import -p ""
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "0" FETCHPOT_CALLS
	assertEqualsMon "_import calls" "0" IMPORTS_CALLS
}

test_pot_import_022()
{
	pot-import -p no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "0" FETCHPOT_CALLS
	assertEqualsMon "_import calls" "0" IMPORTS_CALLS
}

test_pot_import_023()
{
	pot-import -t
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "0" FETCHPOT_CALLS
	assertEqualsMon "_import calls" "0" IMPORTS_CALLS
}

test_pot_import_024()
{
	pot-import -t ""
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "0" FETCHPOT_CALLS
	assertEqualsMon "_import calls" "0" IMPORTS_CALLS
}

test_pot_import_025()
{
	# correct snapshot, but no pot
	pot-import -t 666
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "0" FETCHPOT_CALLS
	assertEqualsMon "_import calls" "0" IMPORTS_CALLS
}

test_pot_import_026()
{
	pot-import -p test-pot-single -t 1.0 -U
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_fetch_pot calls" "0" FETCHPOT_CALLS
	assertEqualsMon "_import calls" "0" IMPORTS_CALLS
}

test_pot_import_027()
{
	pot-import -p test-pot-single -t 1.0 -U ""
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_fetch_pot calls" "0" FETCHPOT_CALLS
	assertEqualsMon "_import calls" "0" IMPORTS_CALLS
}

test_pot_import_040()
{
	pot-import -p test-pot-single -t 1.0
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "1" FETCHPOT_CALLS
	assertEqualsMon "_fetch_pot arg1" "test-pot-single" FETCHPOT_CALL1_ARG1
	assertEqualsMon "_fetch_pot arg2" "1.0" FETCHPOT_CALL1_ARG2
	assertEqualsMon "_fetch_pot arg3" "" FETCHPOT_CALL1_ARG3
	assertEqualsMon "_import calls" "1" IMPORTS_CALLS
	assertEqualsMon "_import arg1" "test-pot-single" IMPORTS_CALL1_ARG1
	assertEqualsMon "_import arg2" "1.0" IMPORTS_CALL1_ARG2
	assertEqualsMon "_import arg3" "test-pot-single_1_0" IMPORTS_CALL1_ARG3
}

test_pot_import_041()
{
	pot-import -p test-pot-single -t v1.0
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "1" FETCHPOT_CALLS
	assertEqualsMon "_fetch_pot arg1" "test-pot-single" FETCHPOT_CALL1_ARG1
	assertEqualsMon "_fetch_pot arg2" "v1.0" FETCHPOT_CALL1_ARG2
	assertEqualsMon "_fetch_pot arg3" "" FETCHPOT_CALL1_ARG3
	assertEqualsMon "_import calls" "1" IMPORTS_CALLS
	assertEqualsMon "_import arg1" "test-pot-single" IMPORTS_CALL1_ARG1
	assertEqualsMon "_import arg2" "v1.0" IMPORTS_CALL1_ARG2
	assertEqualsMon "_import arg3" "test-pot-single_v1_0" IMPORTS_CALL1_ARG3
}

test_pot_import_042()
{
	pot-import -p test-pot-single -t 1.0 -U https://example.org
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "1" FETCHPOT_CALLS
	assertEqualsMon "_fetch_pot arg1" "test-pot-single" FETCHPOT_CALL1_ARG1
	assertEqualsMon "_fetch_pot arg2" "1.0" FETCHPOT_CALL1_ARG2
	assertEqualsMon "_fetch_pot arg3" "" FETCHPOT_CALL1_ARG3
	assertEqualsMon "_fetch_pot arg4" "https://example.org" FETCHPOT_CALL1_ARG4
	assertEqualsMon "_import calls" "1" IMPORTS_CALLS
	assertEqualsMon "_import arg1" "test-pot-single" IMPORTS_CALL1_ARG1
	assertEqualsMon "_import arg2" "1.0" IMPORTS_CALL1_ARG2
	assertEqualsMon "_import arg3" "test-pot-single_1_0" IMPORTS_CALL1_ARG3
}

test_pot_import_043()
{
	pot-import -p test-pot-single -t 1.0 -U https://example.org -C import1.sh
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_fetch_pot calls" "1" FETCHPOT_CALLS
	assertEqualsMon "_fetch_pot arg1" "test-pot-single" FETCHPOT_CALL1_ARG1
	assertEqualsMon "_fetch_pot arg2" "1.0" FETCHPOT_CALL1_ARG2
	assertEqualsMon "_fetch_pot arg3" "import1.sh" FETCHPOT_CALL1_ARG3
	assertEqualsMon "_fetch_pot arg4" "https://example.org" FETCHPOT_CALL1_ARG4
	assertEqualsMon "_import calls" "1" IMPORTS_CALLS
	assertEqualsMon "_import arg1" "test-pot-single" IMPORTS_CALL1_ARG1
	assertEqualsMon "_import arg2" "1.0" IMPORTS_CALL1_ARG2
	assertEqualsMon "_import arg3" "test-pot-single_1_0" IMPORTS_CALL1_ARG3
}

test_pot_import_044()
{
	pot-import -p test-pot-single -t 1.0 -U https://example.org -C nonexistent
	assertEquals "Exit rc" "1" "$?"
}

setUp()
{
	common_setUp
}

. shunit/shunit2
