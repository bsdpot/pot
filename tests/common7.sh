#!/bin/sh

# system utilities stubs

# UUT
. ../share/pot/common.sh

# common stubs
. ./monitor.sh

# app specific stubs

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
	echo "amd64"
}

test_map_archs_001()
{
	result="$(_map_archs )"
	assertEquals "" "$result"
	result="$(_map_archs intel )"
	assertEquals "" "$result"
}

test_map_archs_002()
{
	result="$(_map_archs i386 )"
	assertEquals "i386-i386" "$result"
	result="$(_map_archs amd64 )"
	assertEquals "amd64-amd64" "$result"
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

. shunit/shunit2
