#!/bin/sh
:

# shellcheck disable=SC2039
add-file-help()
{
	echo "pot add-file [-hv] -p pot -m destination -f source"
	echo '  -h print this help'
	echo '  -v verbose'
	echo '  -f source : the file to be added component to be added'
	echo '  -p pot : the working pot'
	echo '  -m destination : the final location inside the pot'
}

# $1 file source
_file_validation()
{
	# shellcheck disable=SC2039
	local _pname _file _destination
	_file="$1"
	if [ -r "$_file" ]; then
		return 0 # true
	else
		_error "file $file not found"
		return 1 # false
	fi
}

# shellcheck disable=SC2039
pot-add-file()
{
	local _pname _file _destination _to_be_umount
	OPTIND=1
	_file=
	_pname=
	_destination=
	while getopts "hvf:p:m:" _o ; do
		case "$_o" in
		h)
			add-file-help
			${EXIT} 0
			;;
		v)
			_POT_VERBOSITY=$(( _POT_VERBOSITY + 1))
			;;
		f)
			_file="$OPTARG"
			;;
		p)
			_pname="$OPTARG"
			;;
		m)
			_destination="$OPTARG"
			;;
		*)
			add-file-help
			${EXIT} 1
			;;
		esac
	done

	echo '##############################'
	echo '#   add-file is deprecated   #'
	echo '##############################'
	echo '# Please use copy-in instead #'
	echo '##############################'

	if [ -z "$_pname" ]; then
		_error "A pot name is mandatory"
		add-file-help
		${EXIT} 1
	fi
	if [ -z "$_file" ]; then
		_error "A source filename is mandatory"
		add-file-help
		${EXIT} 1
	fi
	if [ -z "$_destination" ]; then
		_error "A mount point is mandatory"
		add-file-help
		${EXIT} 1
	fi
	if ! _is_absolute_path "$_destination" ; then
		_error "The destination tartget has to be an absolute pathname"
		${EXIT} 1
	fi

	if ! _is_pot "$_pname" ; then
		_error "pot $_pname is not valid"
		add-file-help
		${EXIT} 1
	fi
	if ! _is_uid0 ; then
		${EXIT} 1
	fi
	if ! _file_validation "$_file" ; then
		add-file-help
		${EXIT} 1
	fi
	if ! _is_pot_running "$_pname" ; then 
		_pot_mount $_pname
		_to_be_umount=1
	fi
	if cp -v "$_file" ${POT_FS_ROOT}/jails/$_pname/m/$_destination ; then
		_debug "File _file copied in the pot $_pname"
	else
		_error "File _file NOT copied because of an error"
	fi
	if [ "$_to_be_umount" = "1" ]; then
		_pot_umount $_pname
	fi
}
