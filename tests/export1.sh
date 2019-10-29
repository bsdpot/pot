#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/export.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

_is_zfs_pot_snap()
{
	__monitor ISZFSSNAP "$@"
	if [ "$1" = "test-pot-single" ] && [ "$2" = "666" ]; then
		return 0
	else
		return 1
	fi
}

_zfs_last_snap()
{
	__monitor ZFSLASTSNAP "$@"
	if [ "$1" = "/jails/test-pot-single" ]; then
		echo 1234321
	elif [ "$1" = "/jails/test-pot-single-2" ]; then
		echo 4321234
	fi
}

_zfs_count_snap()
{
	if [ "$1" = "/jails/test-pot-single-2" ]; then
		echo 2
	else
		echo 1
	fi
}

pot-cmd()
{
	__monitor POTCMD "$@"
}

# app specific stubs
export-help()
{
	__monitor HELP "$@"
}

_export_pot()
{
	__monitor EXPORTS "$@"
	return 0 # true
}

test_pot_export_001()
{
	pot-export -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"

	setUp
	pot-export -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_020()
{
	pot-export -p
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_021()
{
	pot-export -p ""
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_022()
{
	pot-export -p no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_023()
{
	pot-export -s
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_024()
{
	pot-export -s ""
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_025()
{
	# correct snapshot, but no pot
	pot-export -s 666
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_026()
{
	# pot is not single
	pot-export -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_027()
{
	# snapshot already existing
	pot-export -p test-pot-single -s 666
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_is_zfs_pot_snap calls" "1" "$ISZFSSNAP_CALLS"
	assertEquals "_is_zfs_pot_snap arg1" "test-pot-single" "$ISZFSSNAP_CALL1_ARG1"
	assertEquals "_is_zfs_pot_snap arg2" "666" "$ISZFSSNAP_CALL1_ARG2"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_028()
{
	# directory doesn't exist
	pot-export -p test-pot-single -D asdfasdf
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_029()
{
	# wrong compression level
	pot-export -p test-pot-single -l max
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_030()
{
	# wrong compression level
	pot-export -p test-pot-single -l 10
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_031()
{
	# wrong number of snapshost
	pot-export -p test-pot-single-2
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_040()
{
	pot-export -p test-pot-single
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_zfs_pot_snap calls" "0" "$ISZFSSNAP_CALLS"
	assertEquals "_export calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export arg1" "test-pot-single" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export arg2" "1234321" "$EXPORTS_CALL1_ARG2"
	assertEquals "_export arg3" "1234321" "$EXPORTS_CALL1_ARG3"
	assertEquals "_export arg4" "." "$EXPORTS_CALL1_ARG4"
}

test_pot_export_041()
{
	pot-export -p test-pot-single -t v1.0
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_zfs_pot_snap calls" "0" "$ISZFSSNAP_CALLS"
	assertEquals "_export calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export arg1" "test-pot-single" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export arg2" "1234321" "$EXPORTS_CALL1_ARG2"
	assertEquals "_export arg3" "v1.0" "$EXPORTS_CALL1_ARG3"
	assertEquals "_export arg4" "." "$EXPORTS_CALL1_ARG4"
}

test_pot_export_042()
{
	pot-export -p test-pot-single -s 1234
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_zfs_pot_snap calls" "1" "$ISZFSSNAP_CALLS"
	assertEquals "_is_zfs_pot_snap arg1" "test-pot-single" "$ISZFSSNAP_CALL1_ARG1"
	assertEquals "_is_zfs_pot_snap arg2" "1234" "$ISZFSSNAP_CALL1_ARG2"
	assertEquals "_export calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export arg1" "test-pot-single" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export arg2" "1234" "$EXPORTS_CALL1_ARG2"
	assertEquals "_export arg3" "1234" "$EXPORTS_CALL1_ARG3"
	assertEquals "_export arg4" "." "$EXPORTS_CALL1_ARG4"
}

test_pot_export_043()
{
	pot-export -p test-pot-single -s 1234 -t 1.0
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_zfs_pot_snap calls" "1" "$ISZFSSNAP_CALLS"
	assertEquals "_is_zfs_pot_snap arg1" "test-pot-single" "$ISZFSSNAP_CALL1_ARG1"
	assertEquals "_is_zfs_pot_snap arg2" "1234" "$ISZFSSNAP_CALL1_ARG2"
	assertEquals "_export calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export arg1" "test-pot-single" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export arg2" "1234" "$EXPORTS_CALL1_ARG2"
	assertEquals "_export arg3" "1.0" "$EXPORTS_CALL1_ARG3"
	assertEquals "_export arg4" "." "$EXPORTS_CALL1_ARG4"
}

test_pot_export_044()
{
	pot-export -p test-pot-single -s 1234 -t 1.0 -D /tmp
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_zfs_pot_snap calls" "1" "$ISZFSSNAP_CALLS"
	assertEquals "_is_zfs_pot_snap arg1" "test-pot-single" "$ISZFSSNAP_CALL1_ARG1"
	assertEquals "_is_zfs_pot_snap arg2" "1234" "$ISZFSSNAP_CALL1_ARG2"
	assertEquals "_export calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export arg1" "test-pot-single" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export arg2" "1234" "$EXPORTS_CALL1_ARG2"
	assertEquals "_export arg3" "1.0" "$EXPORTS_CALL1_ARG3"
	assertEquals "_export arg4" "/tmp" "$EXPORTS_CALL1_ARG4"
}

test_pot_export_050()
{
	pot-export -p test-pot-single-2 -t 1.0 -F
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_zfs_pot_snap calls" "0" "$ISZFSSNAP_CALLS"
	assertEquals "_export calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export arg1" "test-pot-single-2" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export arg2" "4321234" "$EXPORTS_CALL1_ARG2"
	assertEquals "_export arg3" "1.0" "$EXPORTS_CALL1_ARG3"
	assertEquals "_export arg4" "." "$EXPORTS_CALL1_ARG4"
}

test_pot_export_051()
{
	pot-export -p test-pot-single-2 -t 1.0 -A
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_is_zfs_pot_snap calls" "0" "$ISZFSSNAP_CALLS"
	assertEquals "pot-cmd calls" "1" "$POTCMD_CALLS"
	assertEquals "_export calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export arg1" "test-pot-single-2" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export arg2" "4321234" "$EXPORTS_CALL1_ARG2"
	assertEquals "_export arg3" "1.0" "$EXPORTS_CALL1_ARG3"
	assertEquals "_export arg4" "." "$EXPORTS_CALL1_ARG4"
}
setUp()
{
	common_setUp
	HELP_CALLS=0
	ISZFSSNAP_CALLS=0
	ZFSLASTSNAP_CALLS=0
	EXPORTS_CALLS=0
	EXPORTS_CALL1_ARG1=""
	EXPORTS_CALL1_ARG2=""
	EXPORTS_CALL1_ARG3=""
	POTCMD_CALLS=0
}

. shunit/shunit2
