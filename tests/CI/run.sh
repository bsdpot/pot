#!/bin/sh

export POT_PATH=$( realpath $( dirname $(realpath $0))/../..)
export PATH=$POT_PATH/bin:$PATH
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

set_stack() {
	local s=$1
	local conf=$POT_PATH/etc/pot/pot.conf
	if grep -q ^POT_NETWORK_STACK $conf ; then
		sed -i '' -e "s/POT_NETWORK_STACK=.*$/POT_NETWORK_STACK=$s/" $conf
	else
		echo POT_NETWORK_STACK=$s >> $conf
	fi
}

# $1 type
# $2 base_version
# $3 network
# $4 stack
get_pot_name() {
	t=$1
	b=$( echo $2 | tr '.' '_' )
	n=$3
	s=$4
	echo $t-$b-$n-$s-test
}

# $1 type
# $2 base_version
# $3 network type
# $4 stack
create_test() {
	local name=$( get_pot_name $1 $2 $3 $4 )
	t=$1
	b=$2
	n=$3
	s=$4
	if [ "$t" = "multi" ]; then
		if ! pot create-base -v -r $b ; then
			error $name create-base
		fi
	fi
	case $n in
		alias)
			if ! pot create -v -p $name -t $t -b $b -N $n -i fdf2:f389:1f56:164b::1 -i 172.20.135.253 ; then
				error $name create
			fi
			;;
		private-bridge)
			# create bridge
			if ! pot create-private-bridge -v -B testprivate -S 5 ; then
				error $name create-private-bridge
			fi
			if [ "$s" = "ipv6" ]; then
				if pot create -v -p $name -t $t -b $b -N $n -B testprivate ; then
					error $name create
				fi
				if ! pot destroy -B testprivate ; then
					error $name destroy-bridge-after-nocreate
				fi
				if [ "$t" = "multi" ]; then
					if ! pot destroy -v -b $b ; then
						error $name destroy-base-after-nocreate
					fi
				fi
			else
				if ! pot create -v -p $name -t $t -b $b -N $n -B testprivate ; then
					error $name create
				fi
			fi
			;;
		*)
			if ! pot create -v -p $name -t $t -b $b -N $n ; then
				error $name create
			fi
	esac
}

# $1 name
# $2 type
snap_test() {
	local name=${1}
	case $2 in
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
	pot info -p $name | grep "ip " | awk '{ print $3 }'
}

# $1 pot name
# $2 network
# $3 stack
startstop_test() {
	local name=$1
	local n=$2
	local s=$3
	if [ $s = "ipv6" ] && [ $n = "private-bridge" ]; then
		if pot start $name ; then
			error $name no-start
		fi
		return 0
	fi
	if ! pot start $name ; then
		error $name start
	fi
	# runtime checks
	if [ "$(pot show | grep -c $name)" -ne 1 ]; then
		error $name show
	fi
	if [ $s = "ipv4" ] || [ $s = "dual" ]; then
		if [ $n = "public-bridge" ] || [ $n = "private-bridge" ] ; then
			ip4="$( _get_ip $name )"
			if ! ping -c 1 $ip4 ; then
				error $name ping-bridge
			fi
		fi
		# temporary disable ping tests for alias
		if [ "$n" = "alias" ]; then
			if ! pot stop $name ; then
				error $name stop
			fi
			return 0
		fi
		if ! jexec $name ping -c 1 1.1.1.1 ; then
			error $name ping-nat
		fi
	fi
	if [ $s = "ipv6" ] || [ $s = "dual" ]; then
		# temporary disable ping tests for alias
		if [ "$n" = "alias" ]; then
			if ! pot stop $name ; then
				error $name stop
			fi
			return 0
		fi
		if [ $n != "private-bridge" ]; then
			if ! jexec $name ping6 -c 1 2606:4700:4700::1111 ; then
				error $name ping6-ipv6
			fi
		fi
	fi
	if ! pot stop $name ; then
		error $name stop
	fi
}

# $1 type
# $2 base
# $3 network
# $4 stack
destroy_test() {
	local name=$( get_pot_name $1 $2 $3 $4 )
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
	local name=$( get_pot_name $1 $2 $3 $4 )
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
	local t=${2}
	local b=${3}
	local n=${4}
	case $t in
	single)
		if ! pot destroy -p $name ; then
			error $name destroy
		fi
		;;
	multi)
		if pot destroy -b $b ; then
			error $name no-destroy-base-$b
		fi
		if ! pot destroy -rb $b ; then
			error $name destroy-base-$b
		fi
		;;
	esac
	if [ "$n" = "private-bridge" ]; then
		if ! pot destroy -B testprivate ; then
			error $name destroy-bridge
		fi
	fi
}

# $1 type
# $2 base_version
# $3 network
# $4 stack
pot_test() {
	local name=$( get_pot_name $1 $2 $3 $4 )
	logger -p local2.info -t pot-CI "pot_test: $name"
	create_test $1 $2 $3 $4
	if [ $4 = "ipv6" ] && [ $3 = "private-bridge" ]; then
		return
	fi
	snap_test $name $1
	export_test $name $1
	fscomp_test $name
	startstop_test $name $3 $4
	destroy_test $1 $2 $3 $4
	empty_check $name
}

# $1 type
# $2 base_version
# $3 network
# $4 stack
pot_corrupted_test() {
	local name=$( get_pot_name $1 $2 $3 $4 )
	logger -p local2.info -t pot-CI "pot_corrupted_test: $name"
	create_test $1 $2 $3 $4
	rm -rf /opt/pot/jails/$name/conf
	destroy_corrupted_test $1 $2 $3 $4
	empty_check $name
}

# $1 type
# $2 base_version
# $3 network
# $4 stack
pot_rename_test()
{
	local name=$( get_pot_name $1 $2 $3 $4 )
	logger -p local2.info -t pot-CI "pot_rename_test: $name"
	local new_name=${name}_new
	create_test $1 $2 $3 $4
	rename_test $name $new_name
	startstop_test $new_name $3 $4
	destroy_rename_test $new_name $1 $2 $3
	empty_check $name
}

# $1 type
# $2 base_version
# $3 network
# $4 stack
pot_create_fail_test()
{
	local name=$( get_pot_name $1 $2 $3 $4 )
	logger -p local2.info -t pot-CI "pot_create_fail_test: $name"
	local flv_dir
	if [ "$3" != "inherit" ]; then
		return 0
	fi
	flv_dir=$POT_PATH/etc/pot/flavours
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

STACKS="ipv4 dual ipv6"
VERSIONS="12.2 11.4"
TYPES="single multi"
#NETWORKS="alias inherit public-bridge private-bridge"
NETWORKS="inherit public-bridge private-bridge"
begin

empty_check initial_check
pfctl -F all
for s in $STACKS ; do
	set_stack $s
	for b in $VERSIONS ; do
		for t in $TYPES ; do
			for n in $NETWORKS ; do
				echo "testing $t $b $n $s $(date)" >> $logfile
				pot_test $t $b $n $s
				if [ $n = "private-bridge" ] && [ $s = "ipv6" ]; then
					continue
				fi
				pot_corrupted_test $t $b $n $s
				pot_rename_test $t $b $n $s
				pot_create_fail_test $t $b $n $s
				echo "tested $t $b $n $s $(date)" >> $logfile
			done
		done
	done
done

end
success
