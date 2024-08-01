#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

set-aliases-help() {
	cat <<-"EOH"
	pot set-aliases [-hv] -p pot -A alias_A[ alias_B alias_C ...]
	  -h print this help
	  -v verbose
	  -p pot : the working pot
	  -A alias_A[ alias_B alias_C ...]  : adding alias for an alternative name resolution
	                  via /etc/hosts file
	EOH
}

# $1 pot
# $2 hostfile
_set_aliases()
{
	local _pname _tmpfile _cfile
	_pname="$1"
	_tmpfile="$2"
	_cfile=$POT_FS_ROOT/jails/$_pname/conf/pot.conf
	${SED} -i '' -e "/^pot.aliases=.*/d" "$_cfile"
	sed 's/.*/pot.aliases=&/g' "$_tmpfile" >> "$_cfile"
}


pot-set-aliases()
{
	local _pname _tmpfile _aliases _alias
	_pname=
	if ! _is_pot_tmp_dir ; then
		_error "Failed to create the POT_TMP directory"
		return 1
	fi
	_tmpfile="$(mktemp "${POT_TMP:-/tmp}/pot-set-aliases${POT_MKTMP_SUFFIX}")" || exit 1
	OPTIND=1
	while getopts "hvp:A:" _o ; do
		case "$_o" in
		h)
			set-aliases-help
			rm -f "$_tmpfile"
			return 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		A)
			# validate IP address
			_alias=$OPTARG
			if [ -z "$_alias" ] ; then
				_error "Submitted alias is empty"
				set-aliases-help
				rm -f "$_tmpfile"
				return 1
			fi
			echo "alias=$_alias"
			_aliases=$(echo "$_aliases $_alias" | sed -e "s/^ *//g")
			echo "aliases $_aliases "
			;;
		p)
			_pname="$OPTARG"
			;;
		?)
			set-aliases-help
			rm -f "$_tmpfile"
			return 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		set-aliases-help
		rm -f "$_tmpfile"
		return 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		set-aliases-help
		rm -f "$_tmpfile"
		return 1
	fi
	if ! _is_uid0 ; then
		rm -f "$_tmpfile"
		return 1
	fi
	cat $_tmpfile
	echo "$_aliases " >> "$_tmpfile"
	_set_aliases "$_pname" "$_tmpfile"
	rm -f "$_tmpfile"
}
