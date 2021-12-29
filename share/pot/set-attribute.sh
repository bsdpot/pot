#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

set-attr-help()
{
	echo "pot set-attr [-hv] -p pot -A attr -V value"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -A attribute : one of those attributes:'
	echo '      '"$_POT_RW_ATTRIBUTES"
	echo '  -V value : the new value for the attribute'
}

# check if the argument is a valid boolean value
# if valid, it returns true and it echo a normalized version of the boolean value (YES/NO)
# if not valid, it return false
_normalize_true_false() {
	case $1 in
		[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|[Oo][Nn])
			echo YES
			return 0 # true
			;;
		[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee]|[Oo][Ff][Ff])
			echo NO
			return 0 # true
			;;
		*)
			return 1 # false
	esac
}

# $1 pot name
# $2 attribute name
# $3 value
_set_boolean_attribute()
{
	local _pname _value _cdir
	_pname=$1
	_attr=$2
	_value=$3
	if ! _value=$(_normalize_true_false "$_value") ; then
		_error "value $_value is not a valid boolean value"
		set-attr-help
		return 1
	fi
	_cdir="$POT_FS_ROOT/jails/$_pname/conf"
	${SED} -i '' -e "/^pot.attr.$_attr=.*/d" "$_cdir/pot.conf"
	echo "pot.attr.$_attr=$_value" >> "$_cdir/pot.conf"
}

# $1 pot name
# $2 attribute name
# $3 value
_set_uint_attribute()
{
	local _pname _value _cdir
	_pname=$1
	_attr=$2
	_value=$3

	if [ -n "$(printf '%s' "${_value}" | tr -d '0-9')" ] ; then
		_error "value $_value is not a valid uint value"
		set-attr-help
		return 1
	fi
	_cdir="$POT_FS_ROOT/jails/$_pname/conf"
	${SED} -i '' -e "/^pot.attr.$_attr=.*/d" "$_cdir/pot.conf"
	echo "pot.attr.$_attr=$_value" >> "$_cdir/pot.conf"
}

_ignored_parameter()
{
	local _attr
	_attr=$1
	_info "The attribute $_attr is not implemented and it will be ignored"
}

pot-set-attribute()
{
	local _pname _attr _value _type
	_pname=
	_attr=
	_value=
	OPTIND=1
	while getopts "hvp:A:V:" _o ; do
		case "$_o" in
		h)
			set-attr-help
			return 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		p)
			_pname="$OPTARG"
			;;
		V)
			_value="$OPTARG"
			;;
		A)
			_attr="$OPTARG"
			;;
		*)
			set-attr-help
			return 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		set-attr-help
		return 1
	fi
	if [ -z "$_attr" ]; then
		_error "Option -A is mandatory"
		set-attr-help
		return 1
	fi
	if [ -z "$_value" ]; then
		_error "Option -V is mandatory"
		set-attr-help
		return 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "$_pname is not a valid pot"
		set-attr-help
		return 1
	fi
	# shellcheck disable=SC2086
	if ! _is_in_list "$_attr" $_POT_RW_ATTRIBUTES ${_POT_JAIL_RW_ATTRIBUTES} ; then
		_error "$_attr is not a valid attribute"
		set-attr-help
		return 1
	fi
	if ! _is_uid0 ; then
		return 1
	fi
	case $_attr in
		"start-at-boot"|\
		"early-start-at-boot"|\
		"persistent"|\
		"no-rc-script"|\
		"prunable"|\
		"localhost-tunnel")
			_cmd=_set_boolean_attribute
			;;
		"no-tmpfs")
			if "$(_get_conf_var $_pname pot.type)" = "single" ; then
				_cmd=_set_boolean_attribute
			else
				_error "Attribute no-tmpfs is only usable with single type pot"
				return 1
			fi
		*)
			# shellcheck disable=SC1083,2086
			eval _type=\"\${_POT_DEFAULT_${_attr}_T}\"
			case "${_type}" in
			(bool)
				_cmd=_set_boolean_attribute
				;;
			(uint)
				_cmd=_set_uint_attribute
				;;
			(*)
				_ignored_parameter "$_attr"
			        return 0
				;;
			esac
			;;
	esac

	if ! $_cmd "$_pname" "$_attr" "$_value" ; then
		return 1 # false
	fi
	return 0
}
