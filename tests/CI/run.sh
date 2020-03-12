#!/bin/sh

export PATH=/appdata/pot/bin:$PATH
timestamp="$(date +%Y%m%d%H%M)"
export logfile="pot-ci-${timestamp}"

error() {
	test_name="${1:-unknown}"
	echo "Test ${test_name} failed ($2)" >> $logfile
	end
	exit 
}

begin()
{
	echo "Start pot-ci at $(date)" > $logfile
	if [ ! -d /var/cache/pot ]; then
		mkdir -p /var/cache/pot
	fi
	if [ ! -d /var/cache/pot ]; then
		echo "pot's cache cannot be generated - aborting"
		exit
	fi
}

end()
{
	echo "End pot-ci at $(date)" >> $logfile
}

success()
{
	echo "The test execution was succesfull :+1:"
}

empty_check() {
	if [ -n "$(pot ls -q)" ]; then
		error "$1" "pot not deleted"
	fi
	if [ -n "$(pot ls -qb)" ]; then
		error "$1" "base not deleted"
	fi
	if [ -n "$(pot ls -qf)" ]; then
		error "$1" "fscomp not deleted"
	fi
	if [ -n "$(pot ls -qB)" ]; then
		error "$1" "bridge not deleted"
	fi
}

# $1 type
# $2 base_version
# $3 network type
create_test() {
	t=$1
	b=$2
	n=${3:-inherit}
	local name=${1}-${3}-test
	case $t in
	single)
		case $n in
			private-bridge)
				# create bridge
				if ! pot create-private-bridge -v -B testprivate -S 5 ; then
					error $name create-private-bridge
				fi
				if ! pot create -v -p $name -t $t -b $b -N $n -B testprivate ; then
					error $name create
				fi
				;;
			*)
				if ! pot create -v -p $name -t $t -b $b -N $n ; then
					error $name create
				fi
		esac
		;;
	multi)
		if ! pot create-base -v -r $b ; then
			error $name create-base
		else
			case $n in
				private-bridge)
					# create bridge
					if ! pot create-private-bridge -v -B testprivate -S 5 ; then
						error $name create-private-bridge
					fi
					if ! pot create -v -p $name -t $t -b $b -N $n -B testprivate ; then
						error $name create
					fi
					;;
				*)
					if ! pot create -v -p $name -t $t -b $b -N $n ; then
						error $name create
					fi
			esac
		fi
		;;
	esac
}

# $1 type
# $2 network
snap_test() {
	local name=${1}-${2}-test
	case $1 in
	single)
		snaps=2
		;;
	multi)
		snaps=3
		;;
	esac
	if ! pot snap -p $name ; then
		error $name snap
	fi
	if [ "$(pot info -v -p $name | grep -A 10 snapshot | grep -Fv snapshot | grep -Fc $name )" -ne $snaps ]; then
		error $name snap-info
	fi
}

# $1 pot name
# $2 type
export_test() {
	local name=$1
	local type=$2
	case $type in
	single)
		if ! pot export -p $name -t 0 ; then
			error $name export-single
		fi
		;;
	multi)
		if pot export -p $name ; then
			error $name export-no-multi
		fi
		return
		;;
	esac
	if ! pot import -p $name -t 0 -U file://. ; then
		error $name import
	fi
	if ! pot destroy -p ${name}_0 ; then
		error $name import-destroy
	fi
	rm -rf *.xz*
	rm -rf /var/cache/pot/*.xz*
}

# $1 pot name
fscomp_test() {
	local name=$1
	if ! pot create-fscomp -f fscomp ; then
		error $name create-fscomp
	fi
	if ! pot mount-in -p $name -f fscomp -m /media ; then
		error $name mount-in
	fi
}

# $1 pot name
_get_ip() {
	local name=$1
	pot info -p single-auto-test | grep ip4 | awk '{ print $3 }'
}

# $1 pot name
# $2 network
startstop_test() {
	local name=$1
	if ! pot start $name ; then
		error $name start
	fi
	# runtime checks
	if [ "$(pot show | grep -c $name)" -ne 1 ]; then
		error $name show
	fi
	if [ "$3" = "auto" ]; then
		ip4="$( _get_ip $name )"
		if ! ping -c 1 $ip4 ; then
			error $name ping-bridge
		fi
		if ! jexec $name ping -c 1 1.1.1.1 ; then
			error $name ping-nat
		fi
	fi
	if ! pot stop $name ; then
		error $name stop
	fi
}

# $1 type
# $2 base
# $3 network
destroy_test() {
	local name=${1}-${3}-test
	case $1 in
	single)
		if ! pot destroy -p $name ; then
			error $name destroy
		fi
		;;
	multi)
		if pot destroy -b $2 ; then
			error $name no-destroy-base-$2
		fi
		if ! pot destroy -rb $2 ; then
			error $name destroy-base-$2
		fi
		;;
	esac
	if ! pot destroy -f fscomp ; then
		error $name destroy-fscomp
	fi
	if [ "$3" = "private-bridge" ]; then
		if ! pot destroy -B testprivate ; then
			error $name destroy-bridge
		fi
	fi
}

# $1 type
# $2 base
# $3 network
destroy_corrupted_test() {
	local name=${1}-${3}-test
	case $1 in
	single)
		if pot destroy -p $name ; then
			error $name not-destroy-corrupted
		fi
		if ! pot destroy -p $name -F ; then
			error $name destroy-corrupted
		fi
		;;
	multi)
		if pot destroy -p $name ; then
			error $name not-destroy-corrupted
		fi
		if ! pot destroy -p $name -F ; then
			error $name destroy-corrupted
		fi
		if ! pot destroy -rb $2 ; then
			error $name destroy-base-$2
		fi
		;;
	esac
	if [ "$3" = "private-bridge" ]; then
		if ! pot destroy -B testprivate ; then
			error $name destroy-bridge
		fi
	fi
}

# $1 pot name
# $2 new name
rename_test() {
	local name=$1
	local new_name=$2
	if ! pot rename -p $name -n $new_name ; then
		error $name rename
	fi
	if [ "$( pot ls -q | grep -c "^${name}$")" != "0" ]; then
		error $name rename-not-renamed
	fi
	if [ "$( pot ls -q | grep -c "^${new_name}$")" != "1" ]; then
		error $name rename-no-new-name
	fi
}

# $1 pot name
# $2 type
# $3 base
# $4 network
destroy_rename_test() {
	local name=${1}
	local type=${2}
	case $type in
	single)
		if ! pot destroy -p $name ; then
			error $name destroy
		fi
		;;
	multi)
		if pot destroy -b $3 ; then
			error $name no-destroy-base-$3
		fi
		if ! pot destroy -rb $3 ; then
			error $name destroy-base-$3
		fi
		;;
	esac
	if [ "$4" = "private-bridge" ]; then
		if ! pot destroy -B testprivate ; then
			error $name destroy-bridge
		fi
	fi
}

# $1 type
# $2 base_version
# $3 network
pot_test() {
	local name=${1}-${3}-test
	create_test $1 $2 $3
	snap_test $1 $3
	export_test $name $1
	fscomp_test $name
	startstop_test $name $3
	destroy_test $1 $2 ${3}
	empty_check $name
}

# $1 type
# $2 base_version
# $3 network
pot_corrupted_test() {
	local name=${1}-${3}-test
	create_test $1 $2 $3
	rm -rf /opt/pot/jails/$name/conf
	destroy_corrupted_test $1 $2 ${3}
	empty_check $name
}

# $1 type
# $2 base_version
# $3 network
pot_rename_test()
{
	local name=${1}-${3}-test
	local new_name=${name}_new
	create_test $1 $2 $3
	rename_test $name $new_name
	startstop_test $new_name $3
	destroy_rename_test $new_name $1 $2 $3
}

# $1 type
# $2 base_version
# $3 network
pot_create_fail_test()
{
	local name=${1}-${3}-test
	local flv_dir
	if [ "$3" != "inherit" ]; then
		return 0
	fi
	flv_dir=/appdata/pot/etc/pot/flavours
	# add a broken flavour
	(
	cat << BROKEN_FLV
#!/bin/sh

false
BROKEN_FLV
) > $flv_dir/broken.sh
	chmod a+x $flv_dir/broken.sh
	if [ "$1" = "multi" ]; then
		if ! pot create-base -v -r $b ; then
			error $name create-base
		fi
	fi

	if pot create -p -v -p $name -t $1 -b $2 -N $3 -f broken ; then
		error $name create_fail
	fi
	rm $flv_dir/broken.sh
	if [ "$1" = "multi" ]; then
		pot destroy -b $2
	fi
	empty_check $name
}

VERSIONS="12.1 11.3"
TYPES="single multi"
NETWORKS="inherit public-bridge private-bridge"
begin

empty_check initial_check
pfctl -F all
for b in $VERSIONS ; do
	for t in $TYPES ; do
		for n in $NETWORKS ; do
			echo "testing $b $t $n $(date)" >> $logfile
			pot_test $t $b $n
			pot_corrupted_test $t $b $n
			pot_rename_test $t $b $n
			pot_create_fail_test $t $b $n
			echo "tested $b $t $n $(date)" >> $logfile
		done
	done
done

end
success
