#!/bin/sh
:

# shellcheck disable=SC2039
set-cmd-help() {
	echo "pot set-cmd [-hv] -p pot -c cmd"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -p pot : the working pot'
	echo '  -c cmd : the command line to start the container'
}

# $1 pot
# $2 cmd
_set_command()
{
	# shellcheck disable=SC2039
	local _pname _cmd _cdir _cmd1 _cmd2
	_pname="$1"
	_cmd="$2"
	_cdir=$POT_FS_ROOT/jails/$_pname/conf
	sed -i '' -e "/^pot.cmd=.*/d" "$_cdir/pot.conf"
	_cmd1="$( echo $_cmd | sed 's/^"//' )"
	if [ "$_cmd" = "$_cmd1" ]; then
		echo "pot.cmd=$_cmd" >> "$_cdir"/pot.conf
	else
		_cmd2="$( echo $_cmd1 | sed 's/"$//' )"
		echo "pot.cmd=$_cmd2" >> "$_cdir"/pot.conf
	fi
}

# shellcheck disable=SC2039
pot-set-cmd()
{
	local _pname _cmd
	_cmd=
	_pname=
	OPTIND=1
	while getopts "hvp:c:" _o ; do
		case "$_o" in
		h)
			set-cmd-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		c)
			_cmd="$OPTARG"
			;;
		p)
			_pname="$OPTARG"
			;;
		*)
			set-cmd-help
			${EXIT} 1
		esac
	done

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		set-cmd-help
		${EXIT} 1
	fi
	if [ -z "$_cmd" ]; then
		_error "A command is mandatory"
		set-cmd-help
		${EXIT} 1
	fi
	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		set-cmd-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	_set_command "$_pname" "$_cmd"
}
