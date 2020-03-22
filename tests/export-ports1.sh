#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/export-ports.sh

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
	pot-export-ports -p test-pot -e http
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

test_pot_export_ports_030()
{
	pot-export-ports -p test-pot -e 80:
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_031()
{
	pot-export-ports -p test-pot -e :80
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_032()
{
	pot-export-ports -p test-pot -e 80:100000
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

test_pot_export_ports_033()
{
	pot-export-ports -p test-pot -e 100000:80
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
}

#test_pot_export_ports_034()
#{
#	pot-export-ports -p test-pot -e 80:80:
#	assertEquals "Exit rc" "1" "$?"
#	assertEquals "Help calls" "1" "$HELP_CALLS"
#	assertEquals "Error calls" "1" "$ERROR_CALLS"
#	assertEquals "_export_ports calls" "0" "$EXPORTS_CALLS"
#}

test_pot_export_ports_040()
{
	pot-export-ports -p test-pot-2 -e 80
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export_ports arg1" "test-pot-2" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export_ports arg2" "80" "$EXPORTS_CALL1_ARG2"
}

test_pot_export_ports_041()
{
	pot-export-ports -p test-pot-2 -e 80 -e 443
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export_ports arg1" "test-pot-2" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export_ports arg2" "80 443" "$EXPORTS_CALL1_ARG2"
}

test_pot_export_ports_042()
{
	pot-export-ports -p test-pot-2 -e 80:8080
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export_ports arg1" "test-pot-2" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export_ports arg2" "80:8080" "$EXPORTS_CALL1_ARG2"
}

test_pot_export_ports_043()
{
	pot-export-ports -p test-pot-2 -e 80:8080 -e 443:30443
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export_ports arg1" "test-pot-2" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export_ports arg2" "80:8080 443:30443" "$EXPORTS_CALL1_ARG2"
}

test_pot_export_ports_044()
{
	pot-export-ports -p test-pot-multi-private -e 80:8080 -e 443:30443
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "_export_ports calls" "1" "$EXPORTS_CALLS"
	assertEquals "_export_ports arg1" "test-pot-multi-private" "$EXPORTS_CALL1_ARG1"
	assertEquals "_export_ports arg2" "80:8080 443:30443" "$EXPORTS_CALL1_ARG2"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	EXPORTS_CALLS=0
}

. shunit/shunit2
