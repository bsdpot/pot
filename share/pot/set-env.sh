#!/bin/sh
:

# shellcheck disable=SC2039
set-env-help() {
	echo "pot set-env [-hv] -p pot -E env"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -E var=value : the variable and the value to be added'
	echo '     this option can be repeated more than once'
}

# $1 pot
# $2 env
_set_environment()
{
	# shellcheck disable=SC2039
	local _pname _tmpfile _cfile
	_pname="$1"
	_tmpfile="$2"
	_cfile=$POT_FS_ROOT/jails/$_pname/conf/pot.conf
	sed -i '' -e "/^pot.env=.*/d" "$_cfile"
	cat "$_tmpfile" | sed 's/.*/pot.env=&/g' >> "$_cfile"
}

# shellcheck disable=SC2039
pot-set-env()
{
	local _pname _env _tmpfile
	_env=
	_pname=
	_tmpfile="/tmp/pot-set-env"
	OPTIND=1
	while getopts "hvp:E:" _o ; do
		case "$_o" in
		h)
			set-env-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		E)
			if [ "$OPTARG" = "${OPTARG#*=}" ]; then
				# the argument doesn't have an equal sign
				_error "$OPTARG not in a valid form"
				_error "VARIABLE=value is accetped"
				set-env-help
				${EXIT} 1
			fi
			_tmp="$( echo "$OPTARG" | sed 's%"%\\"%g' )"
			echo "\"$_tmp\"" >> $_tmpfile
			_env=1
			;;
		p)
			_pname="$OPTARG"
			;;
		?)
			set-env-help
			${EXIT} 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		set-env-help
		${EXIT} 1
	fi
	if [ -z "$_env" ]; then
		_error "A command is mandatory"
		set-env-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		set-env-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_set_environment "$_pname" "$_tmpfile"
	rm "$_tmpfile"
}
