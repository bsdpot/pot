#!/bin/sh
:

# shellcheck disable=SC2039
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

_set_start_at_boot()
{
	# shellcheck disable=SC2039
	local _pname _value _cdir
	_pname=$1
	_value=$2
	if ! _value=$(_normalize_true_false "$_value") ; then
		_error "value $_value is not a valid boolean value"
		set-attr-help
		${EXIT} 1
	fi
	_cdir="$POT_FS_ROOT/jails/$_pname/conf"
	sed -i '' -e "/^pot.attr.start-at-boot=.*/d" "$_cdir/pot.conf"
	echo "pot.attr.start-at-boot=$_value" >> "$_cdir/pot.conf"
}

_set_persistent()
{
	# shellcheck disable=SC2039
	local _pname _value _cdir
	_pname=$1
	_value=$2
	if ! _value=$(_normalize_true_false "$_value") ; then
		_error "value $_value is not a valid boolean value"
		set-attr-help
		${EXIT} 1
	fi
	_cdir="$POT_FS_ROOT/jails/$_pname/conf"
	sed -i '' -e "/^pot.attr.start-at-boot=.*/d" "$_cdir/pot.conf"
	echo "pot.attr.persistent=$_value" >> "$_cdir/pot.conf"
}

_ignored_parameter()
{
	# shellcheck disable=SC2039
	local _attr
	_attr=$1
 	_debug "The attribute $_attr is not implemented anymore and it will be ignored"
}

# shellcheck disable=SC2039
pot-set-attribute()
{
	local _pname _attr _value
	_pname=
	_attr=
	_value=
	OPTIND=1
	while getopts "hvp:A:V:" _o ; do
		case "$_o" in
		h)
			set-attr-help
			${EXIT} 0
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
			${EXIT} 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		set-attr-help
		${EXIT} 1
	fi
	if [ -z "$_attr" ]; then 
		_error "Option -A is mandatory"
		set-attr-help
		${EXIT} 1
	fi
	if [ -z "$_value" ]; then 
		_error "Option -V is mandatory"
		set-attr-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "$_pname is not a valid pot"
		set-attr-help
		${EXIT} 1
	fi
	if ! _is_in_list "$_attr" $_POT_RW_ATTRIBUTES ; then
		_error "$_attr is not a valid attribute"
		set-attr-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	case $_attr in
		"start-at-boot")
			_cmd=_set_start_at_boot
			;;
		"persistent")
			_cmd=_set_persistent
			;;
		*)
			_ignored_parameter "$_attr"
			${EXIT} 0
			;;
	esac

	if ! $_cmd "$_pname" "$_value" ; then
		return 1 # false
	fi
	return 0
}
