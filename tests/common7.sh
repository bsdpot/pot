#!/bin/sh

# system utilities stubs

find()
{
	cat << MANIFEST-EOF
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-12.0-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-10.0-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-10.4-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-11.0-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-9.1-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-9.0-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-10.1-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-11.1-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-9.2-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-10.3-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-11.2-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-10.2-RELEASE
/usr/local/share/freebsd/MANIFESTS/amd64-amd64-9.3-RELEASE
MANIFEST-EOF
}

sysctl()
{
	if [ "$2" = "hw.machine_arch" ]; then
		echo "$__arch"
	elif [ "$2" = "hw.machine" ]; then
		echo "$__machine"
	else
		return 1	# failure
	fi
}

hostname()
{
	echo "test-host"
}

# UUT
. ../share/pot/common.sh

# common stubs
. ./monitor.sh

# app specific stubs


test_get_arch_001()
{
	result="$(_get_arch)"
	assertEquals "amd64-amd64" "$result"

	__machine="i386"
	__arch="i386"
	result="$(_get_arch)"
	assertEquals "i386-i386" "$result"

	__machine="arm64"
	__arch="aarch64"
	result="$(_get_arch)"
	assertEquals "arm64-aarch64" "$result"
}

test_get_valid_releases_001()
{
	result="$( _get_valid_releases )"
	assertEquals "9.0 9.1 9.2 9.3 10.0 10.1 10.2 10.3 10.4 11.0 11.1 11.2 12.0 " "$result"
}

test_is_valid_release_001()
{
	# valid release
	_is_valid_release 11.0
	assertEquals "0" "$?"
}

test_is_valid_release_002()
{
	# invalid release
	_is_valid_release 10.8
	assertEquals "1" "$?"

	# invalid call
	_is_valid_release
	assertEquals "1" "$?"
}

test_get_usable_hostname_001()
{
	result="$( _get_usable_hostname pot-short-name )"
	assertEquals "pot-short-name.test-host" "$result"

}

test_get_usable_hostname_002()
{
	result="$( _get_usable_hostname pot-long-name-01234567890123456789012345678901234567890123456789 )"
	assertEquals "pot-long-name-01234567890123456789012345678901234567890123456789" "$result"
}

test_get_usable_hostname_003()
{
	result="$( _get_usable_hostname pot-long-name-012345678901234567890123456789012345678901234567890123456789 )"
	assertEquals "pot-long-name-01234567890123456789012345678901234567890123456789" "$result"
}

test_get_usable_hostname_004()
{
	export POT_HOSTNAME_MAX_LENGTH=62
	result="$( _get_usable_hostname pot-long-name-012345678901234567890123456789012345678901234567890123456789 )"
	assertEquals "pot-long-name-012345678901234567890123456789012345678901234567" "$result"
}

setUp()
{
	__mon_init
	__machine="amd64"
	__arch="amd64"
}

tearDown()
{
	__mon_tearDown
}

. shunit/shunit2
