#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

set-attribute-help()
{
	cat <<-EOH
	pot set-attribute [-hv] -p pot -A attr -V value
	  -h print this help
	  -v verbose
	  -p pot : the working pot
	  -A attribute : one of
	$(echo "$_POT_RW_ATTRIBUTES $_POT_JAIL_RW_ATTRIBUTES" |
	  xargs -n1 echo "     +" | sort)
	  -V value : the new value for "attribute"
	EOH
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
		set-attribute-help
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
		set-attribute-help
		return 1
	fi
	_cdir="$POT_FS_ROOT/jails/$_pname/conf"
	${SED} -i '' -e "/^pot.attr.$_attr=.*/d" "$_cdir/pot.conf"
	echo "pot.attr.$_attr=$_value" >> "$_cdir/pot.conf"
}

# $1 pot name
# $2 attribute name
# $3 value
_set_string_attribute()
{
	local _pname _value _cdir
	_pname=$1
	_attr=$2
	_value=$3

	_cdir="$POT_FS_ROOT/jails/$_pname/conf"
	${SED} -i '' -e "/^pot.attr.$_attr=.*/d" "$_cdir/pot.conf"
	echo "pot.attr.$_attr=$_value" >> "$_cdir/pot.conf"
}

# $1 pot name
# $2 attribute name
# $3 value
_set_sysvopt_attribute()
{
	local _pname _value _cdir
	_pname=$1
	_attr=$2
	_value=$3

	if [ "$_value" != "new" ] && [ "$_value" != "inherit" ] && \
	    [ "$_value" != "disable" ]; then
		_error "value must be one of 'new', 'inherit', 'disable'"
		set-attribute-help
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
			set-attribute-help
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
			set-attribute-help
			return 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		set-attribute-help
		return 1
	fi
	if [ -z "$_attr" ]; then
		_error "Option -A is mandatory"
		set-attribute-help
		return 1
	fi
	if [ -z "$_value" ]; then
		_error "Option -V is mandatory"
		set-attribute-help
		return 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "$_pname is not a valid pot"
		set-attribute-help
		return 1
	fi
	# shellcheck disable=SC2086
	if ! _is_in_list "$_attr" $_POT_RW_ATTRIBUTES ${_POT_JAIL_RW_ATTRIBUTES} ; then
		_error "$_attr is not a valid attribute"
		set-attribute-help
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
		"no-etc-hosts"|\
		"prunable"|\
		"localhost-tunnel")
			_cmd=_set_boolean_attribute
			;;
		"no-tmpfs")
			if [ "$(_get_conf_var "$_pname" pot.type)" = "single" ] ; then
				if ! _is_pot_running "$_pname" ; then
					_cmd=_set_boolean_attribute
				else
					_error "pot $_pname is still running"
				fi
			else
				_error "Attribute no-tmpfs is only usable with single type pot"
				return 1
			fi
			;;
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
			(string)
				_cmd=_set_string_attribute
				;;
			(sysvopt)
				_cmd=_set_sysvopt_attribute
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
