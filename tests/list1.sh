#!/bin/sh

EXIT="return"

# system utilities stubs

# UUT
. ../share/pot/list.sh

. ../share/pot/common.sh
# common stubs
. common-stub.sh

# app specific stubs
list-help()
{
	__monitor HELP "$@"
}

_ls_pots()
{
	__monitor LSPOTS "$@"
}

_ls_bases()
{
	__monitor LSBASES "$@"
}

_ls_fscomp()
{
	__monitor LSFSCOMP "$@"
}

_ls_flavour()
{
	__monitor LSFLAVOUR "$@"
}

test_pot_list_001()
{
	pot-list -k bb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"

	setUp
	pot-list -h
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"
}

test_pot_list_002()
{
	pot-list -pb
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"

	setUp
	pot-list -bp
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"

	setUp
	pot-list -ba
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"

	setUp
	pot-list -fpF
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"
}

test_pot_list_003()
{
	pot-list -aq
	assertEquals "Exit rc" "1" "$?"
	assertEquals "Help calls" "1" "$HELP_CALLS"
	assertEquals "Error calls" "1" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"
}

test_pot_list_020()
{
	pot-list
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "1" "$LSPOTS_CALLS"
	assertEquals "list_pots args" "" "$LSPOTS_CALL1_ARG1"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"

	setUp
	pot-list -q
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "1" "$LSPOTS_CALLS"
	assertEquals "list_pots args" "quiet" "$LSPOTS_CALL1_ARG1"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"
}

test_pot_list_021()
{
	pot-list -p
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "1" "$LSPOTS_CALLS"
	assertEquals "list_pots args" "" "$LSPOTS_CALL1_ARG1"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"

	setUp
	pot-list -pq
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "1" "$LSPOTS_CALLS"
	assertEquals "list_pots args" "quiet" "$LSPOTS_CALL1_ARG1"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"
}

test_pot_list_022()
{
	pot-list -b
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "1" "$LSBASES_CALLS"
	assertEquals "list_bases args" "" "$LSBASES_CALL1_ARG1"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"

	setUp
	pot-list -bq
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "1" "$LSBASES_CALLS"
	assertEquals "list_bases args" "quiet" "$LSBASES_CALL1_ARG1"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"
}

test_pot_list_023()
{
	pot-list -f
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "1" "$LSFSCOMP_CALLS"
	assertEquals "list_fscomp args" "" "$LSFSCOMP_CALL1_ARG1"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"

	setUp
	pot-list -fq
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "1" "$LSFSCOMP_CALLS"
	assertEquals "list_fscomp args" "quiet" "$LSFSCOMP_CALL1_ARG1"
	assertEquals "list_flavour calls" "0" "$LSFLAVOUR_CALLS"
}

test_pot_list_024()
{
	pot-list -F
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "1" "$LSFLAVOUR_CALLS"
	assertEquals "list_flavour args" "" "$LSFLAVOUR_CALL1_ARG1"

	setUp
	pot-list -Fq
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "0" "$LSPOTS_CALLS"
	assertEquals "list_bases calls" "0" "$LSBASES_CALLS"
	assertEquals "list_fscomp calls" "0" "$LSFSCOMP_CALLS"
	assertEquals "list_flavour calls" "1" "$LSFLAVOUR_CALLS"
	assertEquals "list_flavour args" "quiet" "$LSFLAVOUR_CALL1_ARG1"
}

test_pot_list_025()
{
	pot-list -a
	assertEquals "Exit rc" "0" "$?"
	assertEquals "Help calls" "0" "$HELP_CALLS"
	assertEquals "Error calls" "0" "$ERROR_CALLS"
	assertEquals "list_pots calls" "1" "$LSPOTS_CALLS"
	assertEquals "list_port args" "" "$LSPOTS_CALL1_ARG1"
	assertEquals "list_bases calls" "1" "$LSBASES_CALLS"
	assertEquals "list_bases args" "" "$LSBASES_CALL1_ARG1"
	assertEquals "list_fscomp calls" "1" "$LSFSCOMP_CALLS"
	assertEquals "list_fscomp args" "" "$LSFSCOMP_CALL1_ARG1"
	assertEquals "list_flavour calls" "1" "$LSFLAVOUR_CALLS"
	assertEquals "list_flavour args" "" "$LSFLAVOUR_CALL1_ARG1"
}

setUp()
{
	common_setUp
	HELP_CALLS=0
	LSPOTS_CALLS=0
	LSPOTS_CALL1_ARG1=
	LSBASES_CALLS=0
	LSBASES_CALL1_ARG1=
	LSFSCOMP_CALLS=0
	LSFSCOMP_CALL1_ARG1=
	LSFLAVOUR_CALLS=0
	LSFLAVOUR_CALL1_ARG1=
}

. shunit/shunit2
