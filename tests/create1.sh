#!/bin/sh

# system utilities stubs
potnet()
{
	__monitor POTNET "$@"
	if [ "$1" = "next" ]; then
		echo "10.192.123.123"
		return 0 # true
	fi
	if [ "$1" = "validate" ] && [ "$2" = "-H" ] ; then
		if [ "$3" = "10.192.123.123" ] || [ "$3" = "10.1.2.3" ]; then
			return 0 # true
		fi
	fi
	if [ "$1" = "ipcheck" ]; then
		return 0 # true
	fi
	return 1 # false
}

. pipefail-stub.sh

# UUT
. ../share/pot/create.sh

# common stubs
. common-stub.sh

. ../share/pot/network.sh

_is_vnet_available()
{
	__monitor ISVNETAVAIL "$@"
	return 0 # true
}

_is_potnet_available()
{
	__monitor ISPOTNETAVAIL "$@"
	return 0 # true
}

_fetch_freebsd()
{
	__monitor FETCHBSD "$@"
	return 0 # true
}

_get_network_stack()
{
	echo "dual"
}

# app specific stubs
_cj_zfs()
{
	__monitor CJZFS "$@"
}

_cj_conf()
{
	__monitor CJCONF "$@"
}

_cj_internal_conf()
{
	__monitor CJICONF "$@"
}

_cj_single_install()
{
	__monitor CJSINGLE "$@"
}

_exec_flv()
{
	__monitor EXEC_FLV "$@"
}

create-help()
{
	__monitor HELP "$@"
}

test_pot_create_001()
{
	pot-create
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS

	setUp
	pot-create -vL
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS

	setUp
	pot-create -L bb
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS

	setUp
	pot-create -h
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS

	setUp
	pot-create -S
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_002()
{
	pot-create -p test-pot -b 11.1
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_003()
{
	pot-create -p new-pot -P test-pot -l 0
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS

	setUp
	pot-create -p new-pot -b 11.1 -P test-pot -l 0
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_004()
{
	pot-create -p new-pot -P test-pot2
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS

	setUp
	pot-create -p new-pot -P test-pot2 -l 1
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS

	setUp
	pot-create -p new-pot -b 11.1 -l 2
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_005()
{
	pot-create -p new-pot -b 12.1 -N alias -I
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS

	setUp
	pot-create -p new-pot -b 12.1 -N alias -I removed-option
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_006()
{
	pot-create -p new-pot -b 12.1 -N alias -S no-valid-stack
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_007()
{
	pot-create -p new.pot -b 12.1
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_020()
{
	pot-create -p new-pot -b 11.1
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg2" "multi" CJZFS_CALL1_ARG2
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_021()
{
	pot-create -p new-pot -P test-pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg2" "multi" CJZFS_CALL1_ARG2
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "test-pot" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "test-pot" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_022()
{
	pot-create -p new-pot -P test-pot -S
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_023()
{
	pot-create -p new-pot -P test-pot -b 10.4
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_024()
{
	pot-create -p new-pot -P test-pot-0
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_025()
{
	pot-create -p new-pot -b 11.1
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg2" "multi" CJZFS_CALL1_ARG2
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_026()
{
	pot-create -p new-pot -b 11.1 -f flap
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg2" "multi" CJZFS_CALL1_ARG2
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "1" EXEC_FLV_CALLS
	assertEqualsMon "_exec_flv arg2" "flap" EXEC_FLV_CALL1_ARG2
}

test_pot_create_027()
{
	pot-create -p new-pot -b 11.1 -S ipv6 -f flap
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg2" "multi" CJZFS_CALL1_ARG2
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "ipv6" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "1" EXEC_FLV_CALLS
	assertEqualsMon "_exec_flv arg2" "flap" EXEC_FLV_CALL1_ARG2
}

test_pot_create_028()
{
	pot-create -p new-pot -b 11.1 -f flap -f flap2
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg2" "multi" CJZFS_CALL1_ARG2
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "2" EXEC_FLV_CALLS
	assertEqualsMon "_exec_flv arg2" "flap" EXEC_FLV_CALL1_ARG2
	assertEqualsMon "_exec_flv arg2" "flap2" EXEC_FLV_CALL2_ARG2
}

test_pot_create_030()
{
	pot-create -p new-pot -b 11.1 -f no-flav
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}
test_pot_create_040()
{
	pot-create -p new-pot -P test-pot -l 2
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg3" "2" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "test-pot" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "2" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "test-pot" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_041()
{
	pot-create -p new-pot -b 11.1 -P test-pot -l 2
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg3" "2" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "test-pot" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "2" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "test-pot" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_042()
{
	pot-create -p new-pot -P test-pot -b 10.4 -l 2
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_060()
{
	pot-create -p new-pot -b 11.1 -N inherit
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_is_vnet_available calls" "0" ISVNETAVAIL_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
	assertEqualsMon "_potnet calls" "0" POTNET_CALLS
}

test_pot_create_061()
{
	pot-create -p new-pot -b 11.1 -N inherit -s
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_062()
{
	pot-create -p new-pot -b 11.1 -N public-bridge -i 10.1.2.3
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "public-bridge" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "10.1.2.3" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_063()
{
	pot-create -p new-pot -b 11.1 -N alias -i 10.1.2.3
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_is_vnet_available calls" "0" ISVNETAVAIL_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "alias" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "10.1.2.3" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_064()
{
	pot-create -p new-pot -b 11.1 -N public-bridge -i auto
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "public-bridge" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "10.192.123.123" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_065()
{
	# -s is ignored in this case
	pot-create -p new-pot -b 11.1 -N alias -i auto
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
	# an empty error message is printed because _error is re-implemented in the stub
}

test_pot_create_080()
{
	pot-create -p new-pot -b 11.1 -d asdf
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "0" CJZFS_CALLS
	assertEqualsMon "_cj_conf calls" "0" CJCONF_CALLS
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_081()
{
	pot-create -p new-pot -b 11.1 -d pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_is_vnet_available calls" "1" ISVNETAVAIL_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "pot" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_082()
{
	pot-create -p new-pot -b 11.1 -N public-bridge -i 10.1.2.3 -d pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_is_vnet_available calls" "2" ISVNETAVAIL_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "public-bridge" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "10.1.2.3" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "pot" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_083()
{
	pot-create -p new-pot -b 11.1 -N alias -i 10.1.2.3 -d pot
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_is_vnet_available calls" "1" ISVNETAVAIL_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "alias" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "10.1.2.3" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "pot" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_084()
{
	pot-create -p new-pot -b 11.1 -N public-bridge -i 10.1.2.3 -d off
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_is_vnet_available calls" "1" ISVNETAVAIL_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg3" "1" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "public-bridge" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "10.1.2.3" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "1" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "off" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "multi" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "0" CJICONF_CALLS
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}


test_pot_create_100()
{
	pot-create -p new-pot -t single
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
}

test_pot_create_101()
{
	pot-create -p new-pot -t single -b no-base
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
}

test_pot_create_102()
{
	pot-create -p new-pot -t single -P no-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
}

test_pot_create_103()
{
	pot-create -p new-pot -t single -P test-pot
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
}

test_pot_create_104()
{
	pot-create -p test-pot -t single -b 11.1
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
}

test_pot_create_105()
{
	pot-create -p new-pot -t single -P test-pot-0
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
}

test_pot_create_106()
{
	pot-create -p new-pot -t single -P test-pot-single -b 10.3
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
}

test_pot_create_107()
{
	pot-create -p new-pot -t single -b 11.1 -l 1
	assertEquals "Exit rc" "1" "$?"
	assertEqualsMon "Help calls" "1" HELP_CALLS
	assertEqualsMon "Error calls" "1" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "0" ISUID0_CALLS
}

test_pot_create_120()
{
	pot-create -p new-pot -b 11.1 -t single
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_is_vnet_available calls" "0" ISVNETAVAIL_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg2" "single" CJZFS_CALL1_ARG2
	assertEqualsMon "_cj_zfs arg3" "0" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "0" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "single" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "1" CJSINGLE_CALLS
	assertEqualsMon "_cj_single_install arg1" "new-pot" CJSINGLE_CALL1_ARG1
	assertEqualsMon "_cj_single_install arg2" "11.1" CJSINGLE_CALL1_ARG2
	assertEqualsMon "_cj_interal_conf calls" "1" CJICONF_CALLS
	assertEqualsMon "_cj_interal_conf arg1" "new-pot" CJICONF_CALL1_ARG1
	assertEqualsMon "_cj_interal_conf arg2" "single" CJICONF_CALL1_ARG2
	assertEqualsMon "_cj_interal_conf arg3" "0" CJICONF_CALL1_ARG3
	assertEqualsMon "_cj_interal_conf arg4" "" CJICONF_CALL1_ARG4
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_121()
{
	pot-create -p new-pot -b 11.1 -t single -N public-bridge -i 10.1.2.3
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg2" "single" CJZFS_CALL1_ARG2
	assertEqualsMon "_cj_zfs arg3" "0" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "public-bridge" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "10.1.2.3" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "0" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "single" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "1" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "1" CJICONF_CALLS
	assertEqualsMon "_cj_single_install arg1" "new-pot" CJSINGLE_CALL1_ARG1
	assertEqualsMon "_cj_single_install arg2" "11.1" CJSINGLE_CALL1_ARG2
	assertEqualsMon "_cj_interal_conf arg1" "new-pot" CJICONF_CALL1_ARG1
	assertEqualsMon "_cj_interal_conf arg2" "single" CJICONF_CALL1_ARG2
	assertEqualsMon "_cj_interal_conf arg3" "0" CJICONF_CALL1_ARG3
	assertEqualsMon "_cj_interal_conf arg4" "10.1.2.3" CJICONF_CALL1_ARG4
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
}

test_pot_create_122()
{
	pot-create -p new-pot -P test-pot-single -t single
	assertEquals "Exit rc" "0" "$?"
	assertEqualsMon "Help calls" "0" HELP_CALLS
	assertEqualsMon "Error calls" "0" ERROR_CALLS
	assertEqualsMon "_is_uid0 calls" "1" ISUID0_CALLS
	assertEqualsMon "_is_vnet_available calls" "0" ISVNETAVAIL_CALLS
	assertEqualsMon "_cj_zfs calls" "1" CJZFS_CALLS
	assertEqualsMon "_cj_zfs arg1" "new-pot" CJZFS_CALL1_ARG1
	assertEqualsMon "_cj_zfs arg2" "single" CJZFS_CALL1_ARG2
	assertEqualsMon "_cj_zfs arg3" "0" CJZFS_CALL1_ARG3
	assertEqualsMon "_cj_zfs arg4" "11.1" CJZFS_CALL1_ARG4
	assertEqualsMon "_cj_zfs arg5" "test-pot-single" CJZFS_CALL1_ARG5
	assertEqualsMon "_cj_conf calls" "1" CJCONF_CALLS
	assertEqualsMon "_cj_conf arg1" "new-pot" CJCONF_CALL1_ARG1
	assertEqualsMon "_cj_conf arg2" "11.1" CJCONF_CALL1_ARG2
	assertEqualsMon "_cj_conf arg3" "inherit" CJCONF_CALL1_ARG3
	assertEqualsMon "_cj_conf arg4" "" CJCONF_CALL1_ARG4
	assertEqualsMon "_cj_conf arg5" "0" CJCONF_CALL1_ARG5
	assertEqualsMon "_cj_conf arg6" "inherit" CJCONF_CALL1_ARG6
	assertEqualsMon "_cj_conf arg7" "single" CJCONF_CALL1_ARG7
	assertEqualsMon "_cj_conf arg8" "" CJCONF_CALL1_ARG8
	assertEqualsMon "_cj_conf arg9" "test-pot-single" CJCONF_CALL1_ARG9
	assertEqualsMon "_cj_conf_arg10" "dual" CJCONF_CALL1_ARG10
	assertEqualsMon "_cj_single_install calls" "0" CJSINGLE_CALLS
	assertEqualsMon "_cj_interal_conf calls" "1" CJICONF_CALLS
	assertEqualsMon "_cj_interal_conf arg1" "new-pot" CJICONF_CALL1_ARG1
	assertEqualsMon "_cj_interal_conf arg2" "single" CJICONF_CALL1_ARG2
	assertEqualsMon "_cj_interal_conf arg3" "0" CJICONF_CALL1_ARG3
	assertEqualsMon "_cj_interal_conf arg4" "" CJICONF_CALL1_ARG4
	assertEqualsMon "_exec_flv calls" "0" EXEC_FLV_CALLS
	assertEqualsMon "_potnet calls" "0" POTNET_CALLS
}

setUp()
{
	common_setUp
}

. shunit/shunit2
