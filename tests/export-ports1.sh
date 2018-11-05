#!/bin/sh

EXIT="return"

# system utilities stubs

# UUT
. ../share/pot/export-ports.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
export-ports-help()
{
	__monitor HELP "$@"
}

_export_ports()
{
	__monitor EXPORTS "$@"
}

test_pot_export_ports_001()
{
	pot-export-ports -b bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"

	setUp
	pot-export-ports -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_020()
{
	pot-export-ports -p
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_021()
{
	pot-export-ports -p ""
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_022()
{
	pot-export-ports -p no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_023()
{
	pot-export-ports -p test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_024()
{
	pot-export-ports -e
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_025()
{
	pot-export-ports -e ""
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_026()
{
	pot-export-ports -p test-pot -e port
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_027()
{
	pot-export-ports -p test-pot -e ""
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_027()
{
	pot-export-ports -p test-pot -e -1
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_028()
{
	pot-export-ports -p test-pot -e "12 34"
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_029()
{
	pot-export-ports -p test-pot -e 65536
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_040()
{
	pot-export-ports -p test-pot -e 80
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export_ports arg1" "test-pot" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export_ports arg3" "80" "$EXPORTS_CALL1_ARG3"
}

test_pot_export_ports_041()
{
	pot-export-ports -p test-pot -e 80 -e 443
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export_ports arg1" "test-pot" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export_ports arg3" "80 443" "$EXPORTS_CALL1_ARG3"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	EXPORTS_CALLS=0
}

. shunit/shunit2
