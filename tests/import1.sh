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

test_pot_import_001()
{
	pot-import -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "0" "$FETCHPOT_CALLS"
	assertEquals "_import calls" "0" "$IMPORTS_CALLS"

	setUp
	pot-import -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "0" "$FETCHPOT_CALLS"
	assertEquals "_import calls" "0" "$IMPORTS_CALLS"
}

test_pot_import_020()
{
	pot-import -p
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "0" "$FETCHPOT_CALLS"
	assertEquals "_import calls" "0" "$IMPORTS_CALLS"
}

test_pot_import_021()
{
	pot-import -p ""
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "0" "$FETCHPOT_CALLS"
	assertEquals "_import calls" "0" "$IMPORTS_CALLS"
}

test_pot_import_022()
{
	pot-import -p no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "0" "$FETCHPOT_CALLS"
	assertEquals "_import calls" "0" "$IMPORTS_CALLS"
}

test_pot_import_023()
{
	pot-import -t
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "0" "$FETCHPOT_CALLS"
	assertEquals "_import calls" "0" "$IMPORTS_CALLS"
}

test_pot_import_024()
{
	pot-import -t ""
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "0" "$FETCHPOT_CALLS"
	assertEquals "_import calls" "0" "$IMPORTS_CALLS"
}

test_pot_import_025()
{
	# correct snapshot, but no pot
	pot-import -t 666
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "0" "$FETCHPOT_CALLS"
	assertEquals "_import calls" "0" "$IMPORTS_CALLS"
}

test_pot_import_026()
{
	pot-import -p test-pot-single -t 1.0 -U
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "_fetch_pot calls" "0" "$FETCHPOT_CALLS"
	assertEquals "_import calls" "0" "$IMPORTS_CALLS"
}

test_pot_import_027()
{
	pot-import -p test-pot-single -t 1.0 -U ""
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "_fetch_pot calls" "0" "$FETCHPOT_CALLS"
	assertEquals "_import calls" "0" "$IMPORTS_CALLS"
}

test_pot_import_040()
{
	pot-import -p test-pot-single -t 1.0
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "1" "$FETCHPOT_CALLS"
	assertEquals "_fetch_pot arg1" "test-pot-single" "$FETCHPOT_CALL1_ARG1"
	assertEquals "_fetch_pot arg2" "1.0" "$FETCHPOT_CALL1_ARG2"
	assertEquals "_fetch_pot arg3" "" "$FETCHPOT_CALL1_ARG3"
	assertEquals "_import calls" "1" "$IMPORTS_CALLS"
	assertEquals "_import arg1" "test-pot-single" "$IMPORTS_CALL1_ARG1"
	assertEquals "_import arg2" "1.0" "$IMPORTS_CALL1_ARG2"
	assertEquals "_import arg3" "test-pot-single_1_0" "$IMPORTS_CALL1_ARG3"
}

test_pot_import_041()
{
	pot-import -p test-pot-single -t v1.0
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "1" "$FETCHPOT_CALLS"
	assertEquals "_fetch_pot arg1" "test-pot-single" "$FETCHPOT_CALL1_ARG1"
	assertEquals "_fetch_pot arg2" "v1.0" "$FETCHPOT_CALL1_ARG2"
	assertEquals "_fetch_pot arg3" "" "$FETCHPOT_CALL1_ARG3"
	assertEquals "_import calls" "1" "$IMPORTS_CALLS"
	assertEquals "_import arg1" "test-pot-single" "$IMPORTS_CALL1_ARG1"
	assertEquals "_import arg2" "v1.0" "$IMPORTS_CALL1_ARG2"
	assertEquals "_import arg3" "test-pot-single_v1_0" "$IMPORTS_CALL1_ARG3"
}

test_pot_import_042()
{
	pot-import -p test-pot-single -t 1.0 -U https://example.org
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_fetch_pot calls" "1" "$FETCHPOT_CALLS"
	assertEquals "_fetch_pot arg1" "test-pot-single" "$FETCHPOT_CALL1_ARG1"
	assertEquals "_fetch_pot arg2" "1.0" "$FETCHPOT_CALL1_ARG2"
	assertEquals "_fetch_pot arg3" "https://example.org" "$FETCHPOT_CALL1_ARG3"
	assertEquals "_import calls" "1" "$IMPORTS_CALLS"
	assertEquals "_import arg1" "test-pot-single" "$IMPORTS_CALL1_ARG1"
	assertEquals "_import arg2" "1.0" "$IMPORTS_CALL1_ARG2"
	assertEquals "_import arg3" "test-pot-single_1_0" "$IMPORTS_CALL1_ARG3"
}

#test_pot_import_043()
#{
#	pot-import -p test-pot-single -s 1234 -t 1.0
#	assertEquals "Exit rc" "0" "$?"
#	assertEquals "Help calls" "0" "$HELP_CALLS"
#	assertEquals "Error calls" "0" "$ERROR_CALLS"
#	assertEquals "_is_zfs_pot_snap calls" "1" "$ISZFSSNAP_CALLS"
#	assertEquals "_is_zfs_pot_snap arg1" "test-pot-single" "$ISZFSSNAP_CALL1_ARG1"
#	assertEquals "_is_zfs_pot_snap arg2" "1234" "$ISZFSSNAP_CALL1_ARG2"
#	assertEquals "_import calls" "1" "$IMPORTS_CALLS"
#	assertEquals "_import arg1" "test-pot-single" "$IMPORTS_CALL1_ARG1"
#	assertEquals "_import arg2" "1234" "$IMPORTS_CALL1_ARG2"
#	assertEquals "_import arg3" "1.0" "$IMPORTS_CALL1_ARG3"
#	assertEquals "_import arg4" "." "$IMPORTS_CALL1_ARG4"
#}
#
#test_pot_import_044()
#{
#	pot-import -p test-pot-single -s 1234 -t 1.0 -D /tmp
#	assertEquals "Exit rc" "0" "$?"
#	assertEquals "Help calls" "0" "$HELP_CALLS"
#	assertEquals "Error calls" "0" "$ERROR_CALLS"
#	assertEquals "_is_zfs_pot_snap calls" "1" "$ISZFSSNAP_CALLS"
#	assertEquals "_is_zfs_pot_snap arg1" "test-pot-single" "$ISZFSSNAP_CALL1_ARG1"
#	assertEquals "_is_zfs_pot_snap arg2" "1234" "$ISZFSSNAP_CALL1_ARG2"
#	assertEquals "_import calls" "1" "$IMPORTS_CALLS"
#	assertEquals "_import arg1" "test-pot-single" "$IMPORTS_CALL1_ARG1"
#	assertEquals "_import arg2" "1234" "$IMPORTS_CALL1_ARG2"
#	assertEquals "_import arg3" "1.0" "$IMPORTS_CALL1_ARG3"
#	assertEquals "_import arg4" "/tmp" "$IMPORTS_CALL1_ARG4"
#}
#
#test_pot_import_050()
#{
#	pot-import -p test-pot-single-2 -t 1.0 -F
#	assertEquals "Exit rc" "0" "$?"
#	assertEquals "Help calls" "0" "$HELP_CALLS"
#	assertEquals "Error calls" "0" "$ERROR_CALLS"
#	assertEquals "_is_zfs_pot_snap calls" "0" "$ISZFSSNAP_CALLS"
#	assertEquals "_import calls" "1" "$IMPORTS_CALLS"
#	assertEquals "_import arg1" "test-pot-single-2" "$IMPORTS_CALL1_ARG1"
#	assertEquals "_import arg2" "4321234" "$IMPORTS_CALL1_ARG2"
#	assertEquals "_import arg3" "1.0" "$IMPORTS_CALL1_ARG3"
#	assertEquals "_import arg4" "." "$IMPORTS_CALL1_ARG4"
#}
#
#test_pot_import_051()
#{
#	pot-import -p test-pot-single-2 -t 1.0 -A
#	assertEquals "Exit rc" "0" "$?"
#	assertEquals "Help calls" "0" "$HELP_CALLS"
#	assertEquals "Error calls" "0" "$ERROR_CALLS"
#	assertEquals "_is_zfs_pot_snap calls" "0" "$ISZFSSNAP_CALLS"
#	assertEquals "pot-cmd calls" "1" "$POTCMD_CALLS"
#	assertEquals "pot-cmd arg1" "purge-snapshots" "$POTCMD_CALL1_ARG1"
#	assertEquals "_import calls" "1" "$IMPORTS_CALLS"
#	assertEquals "_import arg1" "test-pot-single-2" "$IMPORTS_CALL1_ARG1"
#	assertEquals "_import arg2" "4321234" "$IMPORTS_CALL1_ARG2"
#	assertEquals "_import arg3" "1.0" "$IMPORTS_CALL1_ARG3"
#	assertEquals "_import arg4" "." "$IMPORTS_CALL1_ARG4"
#}
#
#test_pot_import_052()
#{
#	pot-import -p test-pot-single-0 -t 1.0 -A
#	assertEquals "Exit rc" "0" "$?"
#	assertEquals "Help calls" "0" "$HELP_CALLS"
#	assertEquals "Error calls" "0" "$ERROR_CALLS"
#	assertEquals "_is_zfs_pot_snap calls" "0" "$ISZFSSNAP_CALLS"
#	assertEquals "pot-cmd calls" "1" "$POTCMD_CALLS"
#	assertEquals "pot-cmd arg1" "snapshot" "$POTCMD_CALL1_ARG1"
#	assertEquals "_import calls" "1" "$IMPORTS_CALLS"
#	assertEquals "_import arg1" "test-pot-single-0" "$IMPORTS_CALL1_ARG1"
#	assertEquals "_import arg2" "123123123" "$IMPORTS_CALL1_ARG2"
#	assertEquals "_import arg3" "1.0" "$IMPORTS_CALL1_ARG3"
#	assertEquals "_import arg4" "." "$IMPORTS_CALL1_ARG4"
#}

setUp()
{
	common_setUp
	HELP_CALLS=0
	IMPORTS_CALLS=0
	IMPORTS_CALL1_ARG1=""
	IMPORTS_CALL1_ARG2=""
	IMPORTS_CALL1_ARG3=""
	FETCHPOT_CALLS=0
	FETCHPOT_CALL1_ARG1=""
	FETCHPOT_CALL1_ARG2=""
	FETCHPOT_CALL1_ARG3=""
}

tearDown()
{
	:
}

. shunit/shunit2
