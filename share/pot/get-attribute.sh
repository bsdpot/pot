#!/bin/sh
# shellcheck disable=SC3033,SC3040,SC3043
:

get-attr-help()
{
	echo "pot get-attr [-hvq] -p pot -A attr"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -q quiet'
	echo '  -p pot : the working pot'
	echo '  -A attribute : one of those attributes:'
	echo '      '"$_POT_RW_ATTRIBUTES $_POT_RO_ATTRIBUTES"
}

pot-get-attribute()
{
	local _pname _attr _value _quiet
	_pname=
	_attr=
	_value=
	_quiet="no"
	OPTIND=1
	while getopts "hvqp:A:V:" _o ; do
		case "$_o" in
		h)
			get-attr-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		q)
			_quiet="quiet"
			;;
		p)
			_pname="$OPTARG"
			;;
		A)
			_attr="$OPTARG"
			;;
		*)
			get-attr-help
			${EXIT} 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		get-attr-help
		${EXIT} 1
	fi
	if [ -z "$_attr" ]; then
		_error "Option -A is mandatory"
		get-attr-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" "$_quiet" ; then
		if [ "$_quiet" != "quiet" ]; then
			_error "$_pname is not a valid pot"
			get-attr-help
		fi
		${EXIT} 1
	fi
	# shellcheck disable=SC2086
	if ! _is_in_list "$_attr" $_POT_RW_ATTRIBUTES $_POT_RO_ATTRIBUTES $_POT_JAIL_RW_ATTRIBUTES ; then
		_error "$_attr is not a valid attribute"
		get-attr-help
		${EXIT} 1
	fi
	_value=$(_get_conf_var "$_pname" "pot.attr.$_attr")
	if [ "$_quiet" = "quiet" ]; then
		echo "$_value"
	else
		if [ -z "$_value" ]; then
			_info "The attribute $_attr is not set for the pot $_pname"
		else
			_info "$_attr: $_value"
		fi
	fi
	return 0
}
