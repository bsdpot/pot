# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- start: remove temporary files

### Fixes
- clone: fix a typo refactoring the grep that remove network parameters (#90)
- mount-in: fix mountpoint validation when pot is stopped and -v is passed (#93)
- clone: hooks have been ignored by clone (#94)
- info: fix withespace quoting with -E flag (#95)
- prepare: fix -i command to allow multiple IP addresses (#97)
- ifconfig: force IFCONFIG_FORMAT to avoid conflicting user setting (#99)

## [0.11.2] 2020-05-01
### Added
- prepare: the -S option is now used to specify the network stack

### Changed
- prepare: the -S flag to start the imported pot changed in -s

### Fixed
- fbsd-update: don't assume there is a tty (#86)
- clone: duplicate the entry pot.stack (#88)

## [0.11.1] 2020-04-19
### Fixed
- set-attr: attribute early-start-at-boot is now correctly recognized

## [0.11.0] 2020-04-19
### Added
- create-base: automatically call freebsd-update when a base is created (#83)
- attribute early-start-at-boot: for pot needed to start early at boot (REQUIRE: NETWORKING syslogd pf)
- create: add a -k flag to keep the pot, even if it's creation process failed
- network stack: add network stack as framework concept (ipv4, ipv6 or dual)
- CI: import the run.sh script, with regression system tests
- alias: the new notation -i can be repeated to assign multiple IPs to different NICs
- hooks: added variables to provide the full new alias network configuration

### Changed
- osrelease: detect it from freebsd-version, deprecating the osrelease field in pot.conf (#83)
- start-at-boot: the pot rc.d service will be executed late, with jail
- create: if create fails, the partially created pot is automatically destroyed
- create: -P will use send/receive from a snapshot, to cut the dependency with the snapshot
- create-multi: usr.local and custom dataset are send/received instead of cloned
- inherit: it inherits the stack configured in pot.conf
- alias: extend -i option to accept netif|ipaddr
- alias: -i option can be repeated more than once to add more ip addresses to the same instance
- syslogd: initial removal of syslogd forwarding

### Removed
- alias: remove option -I, in favour of a more flexible and powerful -i
- export: remove option -s, to select a specific snapshot (already deprecated)
- snapshot: remove option -n, to specify a snapshot name (already deprecated)
- snapshot: remove flag -a, to snapshot external ZFS datasets (already deprecated)
- revert: remove flag -a, to restore external ZFS datasets (already deprecated)

### Fixed
- mount-in: compute the realpath of the mount-point
- create: use pipefail only where implemented
- ipv6: rtsold doesn't start in a jail on 11.3

## [0.10.4] 2020-02-23
### Added
- alias: add ability to use a different network interface for alias network type (#80)
- env: add pot info -E output to environment or tinirc
- log: add the ability to log activites in syslog

### Fixed
- prepare: fix multiple export port support
- rc script: extend PATH to make potnet accessible
- etc/hosts: add full hostname to localhost

## [0.10.3] 2020-01-07
### Changed
- export-ports: relax the check bout the pot's network type
- list: print a message, if there are no pot yet

## [0.10.2] 2019-12-17
### Added
- fbsd-update flavour: add a flavour to run freebsd update

### Changed
- slim flavour: remove a bounch of other directories

### Fixed
- flavor: set-cmd can cause issue if it has quotes or double quotes in the command string
- tinirc: lo1 initialization needed only for public or private bridge
- start: background tasks now check if the pot is running
- init: fix bridge folder creation
- prepare: fix prepare when no command is provided (-c is optional)

## [0.10.1] 2019-12-04
### Added
- set-hooks: add support for pre/post start/stop hooks. Script are executed in the host environment (#61)

### Changed
- home-usr/home: those link are not always available. Change create and crate-base to have them always (reported by Philip Jocks)

### Fixed
- create: permission of /tmp in single type are wrong (#72)
- create: if FreeBSD base fetch is interrupted, a broken file is left and the checksum will always fail (#73)
- import: if the image fetch is interrupted, a broken file is left and the checksum will always fail
- import: fix hostname rename
- localhost-tunnel: fix kill of ncat tunnel, when the pot has a long name

## [0.10.0] 2019-11-01
### Added
- info: support for bridge
- set-hosts: new command to add custom etc/hosts entries to a pot
- set-env: new command to add environment variable to a pot
- network-type private-bridge: add a new network layout, to provide private bridges for a group of pots
- create-private-bridge: new subcommand to define and create a private-bridge
- create: add option -B, to provide the bridge name if network-type is private-bridge
- clone: add option -B, to provide the bridge name if network-type is private-bridge
- prepare: add option -B, to provide the bridge name if network-type is private-bridge
- destroy: add option -B, to provide a way to destroy a bridge
- Image Guide: added a guide about how to create an Image of a pot
- POT_EXTRA_EXTIF: add addition network interfaces support

### Changed
- start: overwrite /etc/hosts of a pot, adding all pots on the same bridge and custom entries added via set-hosts
- flavorable commands: extend support to set-cmd and set-env
- pot-rdr anchor: the name of the anchor is now a truncated pot name (the last 54 characters)
- export: it's executed only if one snapshot is available. -F force execution, -A fix the number of snapshots, via purge-snapshots or taking a shapshot automagically
- start: using exec.start instead of command (it seems more predictable)

### Deprecated
- snapshot: -n option to provide custom name to snapshots
- support to full pot snapshot (external zfs dataset) in snapshot and start, as well as the _pot_zfs_snap_full function
- support to full pot revert (external zfs dataset) in revert/rollback (option -a)
- create-dns: undocumented and too hard to maintain
- export: -s option, to specify a snapshot. It's misleading, because zfs send -R will send all the previous snapshots anyway

### Fixed
- flavorable commands: they cannot exit, but return. create can stop flavour execution otherwise
- show: fix single type support and directory in fscomp.conf
- start: if the command has arguments with equals, it would have been truncated

## [0.9.2] 2019-08-25
### Added
- prune: invoke a stop, before the destroy, even if the pot is not runing
- lockf: introducing lockf to run create, import or clone one at a time

### Fixed
- stop: make the pkill on ncat more robust
- stop: add a workaround for a race condition in the epair driver

## [0.9.1] 2019-08-20
### Added
- localhost-tunnel attribute: new attribute to create a tunnet to redirect traffic from localhost (consul feature)

### Changed
- prepare: allow network type "host" as alias for "inherit" (nomad-friendly feature)
- prepare: set localhost-tunnel automatically (consul-friendly feature)

### Fixed
- get-rss: fix return code when the pot is not valid
- set-cmd: fix potential double quotes surrouding the command
- get-rss: TotalTicks is now expressed in Mhz (pcpu * max cpu Frequency)
- get-rss: add swap usage statistic
- start: fix tinirc permission if no-rc-script is used with network type different than public-bridge
- destroy: use -f to remove the 'Device busy' issue

## [0.9.0] 2019-08-13
### Added
- Installation Guide: a more detailed guide, that better explains the installation of pot
- fdescfs attribute: new attribute to mount fdescfs inside the pot
- init: add a network configuration validation step

### Changed
- POT_CACHE: the cache used by import is now a dataset, child of POT_ZFS_ROOT
- set-rss: CPU limits is set as maximum amount of CPU. At start, pot decide where to allocate using potcpu
- prunable: if a pot is prunable, it has to be started at least once to be pruned (flavour counts)

## [0.8.0] 2019-07-30
### Added
- update-config: implemented -a flag to update all pot configurations in one run
- get-rss: show the current resources usage (output available in json)
- procfs attribute: new attribute to mount a procfs inside the pot
- prunable attribute: new attribute prunable, to automatically delete not running pots (prune)
- prune: new command to automatically destro yinactive prunable pots

### Changed
- create: rework how to configure the network type of a pot
- Quickstart Guide: rework the guide using mount-in and copy-in, listing all possibilities
- README: remove the introduction and pointing to the Quickstart guide instead
- import: removed -a option, not really needed during import
- prepare: optimized, importing once and using clone instead of import+rename every time
- clone: add -N option, to change network type while cloning
- prepare: add -N option, to change network type while preparing

### Removed
- promote: after a long deprecation time, promote has been deleted
- add-fscomp: removed, mount-in is its more generic replacement
- add-file: removed, copy-in is its more generic replacement
- execute: remove this alias of prepare

### Fixed
- start: if the start command doesn't go in background, rss and persist weren't managed

## [0.7.0] 2019-07-04
### Added
- update-config: new command that will update a pot configuration
- execute: an orchestration oriented command that imports and automatically set several settings on a pot
- prepare: new command, taking the place of execute
- copy-in: new command, to copy files or directory inside a pot (generalized replacement of add-file)
- mount-in: new command, to mount a directory, a zfs dataset or a fscomp inside a pot (replacement for add-fscomp)

### Changed
- export-ports: removed -S for static port export
- export-ports: add the ability to associate any host port to a pot port to be exported using pot_port:host_port format
- execute: an alias for prepare

### Deprecated
- add-file: deprecated, replaced by the more general new copy-in command
- add-fscomp: deprecated, replaces by the more general new mount-in command

## [0.6.1] 2019-06-25
### Fixed
- init: make pf.conf more robust
- vnet-start: make pf start more robust, in case pf as service is not up

## [0.6.0] 2019-06-23
### Added
- add-fscomp: add option -d, to allow to mount generic directories into a pot (-d and -f are mutual)
- show: add -q flag, to only show pot names
- set-attribute: to set pot attributes (options/flags/configurations)
- get-attribute: to get pot attributes (options/flags/configurations)
- FreeBSD version usable to create a pot are all the ones listed in the FreeBSD MANIFEST
- attributes: add persistent attribute to jail
- attributes: add no-rc-script attribute to start a pot without a rc script
- add-file: new command to copy a single file inside a pot

### Changed
- inherit network: added ipv6 support (automatic)
- static IP network: added ipv6 support
- pf: adopt anchor with relevant changes in nat rules management

### Deprecated
- pot_list: in rc.conf pot_list is not supported anymore. Please use the start-at-boot attribute

### Fixed
- syntax error in zsh autocompletion
- ls fscomp: using zfs instead of ls (if a fscomp is re-mounted, the mountpoint is not in /opt/pot/fscomp anymore)
- static-ip: Fix invocation to potnet to validate ip addresses

## [0.5.11] 2019-03-04
### Added
- export: new command. export generates a compressed file with the entire pot in it. It works only for single type pot
- export: -D option to change export directory and -l option to change compression level
- POT_CACHE: a place to cache pot images. It's a variable of pot.conf
- import: new command. import create a new pot based on an image generated via export
- import-export: add skein has verification support

### Changed
- rc.d: changed order, to start pot before ntpdate
- destroy: extend the usage of -F to be able to destroy corrupted pots

### Fixed
- destroy: fix return code
- rename: fix single pot support
- get_conf_var: using a better RE to avoid to detect variables value in pot names (Thanks to Johan Hendriks to report)

## [0.5.10] 2019-01-15
### Added
- destroy: option -f can be used to delete/destroy a fscomp (no recursive support yet)
- vnet-start: add support to VPN and custom pf configuration

### Changed
- destroy: option -f (force) is now -F

### Fixed
- is_pot: improve support to single pots, that don't have fscomp.conf file
- create-base: fix regression introduced on 0.5.9 (RC support and create -F removal)
 
## [0.5.9] 2018-12-16
### Added
- Add support to RC FreeBSD version
- config: add pot_prefix and fscomp_prefix as possible values
- snapshot: add option -n to give a name to the snapshot; valid for fscomp only
- Add support to FreeBSD 12.0

### Changed
- create: removed -F option and silent default flavor invocation. Default flavor has to be explicitely selected via -f
- create-base: removed support for undocumented default-base flavor

## [0.5.8] 2018-11-29
### Added
- QuickStart.md : a markdown quick guide, for new users
- create : -i auto (based on potnet) to get automatically a valid IP address
- clone : -i auto (based on potnet) to get automatically a valid IP address
- clone : add support to single type pot
- export-port : new command that allow pot ports to be exposed outside (vnet case)
- slim flavor, designed to be used with single dataset pot types
- purge-snapshot : new command that will remove all snapshots, except the last one
- export-port : static option, to add statically exported ports

### Changed
- init : it takes care of syslogd configuration in the host system
- create : type=single will install plain FreeBSD and run the default flavour
- create : multiple flavour support, executed in sequentially; option -f can be repeated
- add-fscomp : exploit the new internal refactorized mount and umount function to avoid to start the pot
- add-fscomp : if the pot is running, mount the new fscomp right away

### Fixed
- clone : fix a misleading/false positive error message 
- clone : fix syslogd configuration in the cloned pot
- destroy : fix if pot is a single dataset one
- start : fix hostname warning
- start (#046) : run the jail in a clean enviroment
- term (#046) : spawn the shell in a jail using the jailed user environment
- add-fscomp (#045) : check the mount point and create it, if missing
- list (#052) : fixing xargs invocation

### Deprecated
- promote : mark promot as deprecated, so we can remove it in the next major release

## [0.5.7] 2018-06-28
### Added
- create-base : add support to FreeBSD 11.2

### Fixed
- version (#038) : fix the version number showed

## [0.5.6] 2018-05-18
### Added
- create-base : add option -b, to provide a specific name to a base and support multiple bases with the same FreeBSD version
- create: add support to single dataset pots.
- set-cmd: add the command to manage the command line that starts the container
- top: add a new command, to spawn a top only on a pot

## [0.5.5] 2018-04-18
### Added
- ps : add ps subcommand, to show information about which pot is running
- config : add config subcommand, to easily access configuration values
- zsh autocompletion (#013): pot autocompletion support for zsh
- syslogd log unification (#032): when possible, syslogd autoconfigured to log in the host instead of in the pot

### Changed
- list : keep it more simple, leaving more information under -v
- show : add -r (all running pots) option and made it the new default
- show : -a greatly improved show all relevant information per pot

### Removed
- fs.conf is not supported anymore

## [0.5.0] 2018-03-16
### Added
- add-fscomp : add the ability to remount a fscomp (-w), instead of mount it via nullfs
- add-fscomp : add the ability to mount a fscomp in read-only (-r)
- info : new command, to get information about a specific pot
- rc.d script (#022)
- create (#020) : add option -s, to configure static ip address (alias to external network interface)
- create-base (#030) : add sha verification using freebsd-release-manifests
- version : add a subcommand the print the current version of the utility
- fscomp.conf : new fs component description file
- clone : -f option to automatically get a snapshot of a dataset, if needed
- promote (#008) : add promote command

### Changed
- create: the new wiki page shows the slightly different behavior of all use cases
- create: fscomp.conf is generated instead of fs.conf, using dataset instead of mountpoint as first column
- private datasets are now mounted changing the mountpoint of the dataset, instead of relying on nullfs
  For that reasons, an option called "zfs-remount" is added to the fs.conf file

### Deprecated
- fs.conf: fs.conf is deprecated. Support will be removed in the next release.

### Removed
- create: -S option, not needed anymore

## [0.4.0] 2018-02-13
### Added
- rollback : added rollback as alias of revert
- help : add support for aliases
- add-fscomp (#027): add support for external ZFS dataset via the option -e
- de-init (0#23): new command to completely remove (de-install) pot from your system

### Fixed
- stop (#024): check the pot existance
- stop : fixed error messages referring to "jail"
- list : fix help, option -s never implemented
- destroy (0#25): fix pot name validation and add dependency detection

## [0.3.1] 2018-01-26
### Added
- pot.conf.sample : a documentated pot.conf example

## [0.3.0] 2018-01-26
### Added
- Every command that need root privileges perform a check of the user id
- create (#010): add a validation of command types executable in a pot flavour
- Checks about VIMAGE and rctl usability (#018)

### Changed
- set-rss : rename command (it was add-rss)
- vnet-start (#019): automatic activation of ip forwarding

### Fixed
- create-base (#016): do not re-create the base pot
- rename (#017): apply the rename also in dependents pots (level 2 or runtime dependency)
- create (#021): -b argument validation

## [0.2.0] 2018-01-23
### Added
- create-dns : new command, to create the dns pot
- create : add the option -d to choose the type of dns (inherit or pot)
- start : add the support to dns types

### Fixed
- rename : remove a misleading error message
- start : proper stop, if one mount fails
- vnet-start (#009): pf module loaded and firewall enabled

## [0.1.0] 2017-12-14
### Added
- Add resource constraints, via add-rss command
- Add clone-fscomp command, to clone a fscomp
- Add clone command, to clone a pot
- Add rename command, to completely rename a pot
- Add dependency support, and related command add-dep
- Add support to destroy bases and their related level 0 pot
- Add support to recursive destroy
- Add support to default flavour with create-base
- Add -F option to create, to disable the default flavour
- More tests

### Changed
- Move packages db to the usr.local dataset - it's a breaking change

## [0.0.2] 2017-12-03
### Fixed
- Fixed start, a typo prevents the correct behavior

## [0.0.1] 2017-12-03
### Added
- Add a revert command, to rollback a pot snapshot
- Add snaposhot information in list command
- Add a test framework
- Add travis-ci support

### Changed
- snapshot options has changed to be more consistent and to support fscomp
- revert options has changed to be more consistent and to support fscomp

### Fixed
- If a start fails, it tries to clean up (umount)

## [0.0.1-rc.1] 2017-11-28
### Added
- Add a vnet-start command, to properly init the vnet network configuration (bridge+pf)
- Add an option to show, to show all pot resource usage
- Add some command alias: ls is an alias of list
- Auto-start of vnet, when needed
- Add level 2 pot support, adding special option -P and -S in create command
- Add a run command, to start and enter in a pot
- Add a -f option to destroy and term, to fix/force the operation
- Add -F for flavor and -a for all in list command

### Changed
- Changed pot configuration. No jail.conf anymore, but pot.conf
- Pots with an ip are now based on epair/vnet/VIMAGE technology
- Command show now shows resource usage of all pots by default
- Add more information in show and list command

### Deprecated
- jail.conf files are currently ignored, please destroy and recreate pots

### Removed
- scripts directory and j\* commands in bin. None of them could really works
## [0.0.1-beta] 2017-11-07
### Added
- Add option -b to list, to list available bases
- Add option -f to list, to list available fs components
- Add a destroy command, to destroy a pot
- Add a term command, to start a pot
- First implementation of show, that shows memory used by running pots
- Add support to flavour- pot subcommand and shell script

### Changed
- Remove jail references and use pot instead (not in zfs)
- jstart command is now start
- jstop command is now stop
- create-jail command is not create
- create-base creates the related level 0 pot automatically
- start doesn't invoke exit if succeeds

### Fixed
- Fix add-fscomp that can introduce valid, but imprecise mount-point
- Fix create-base that created a wrong usr.local.etc link

## [0.0.1-alpha] 2017-10-20
### Added
- Add the central utility called 'pot'
- Add a central configuration file
- Add a init command, to initialize the zfs layout
- Add a create-base command, to create a new base
- Add a create-fscomp command, to create a new base
- Add a create-jail command, to create a new base
- Add a jstart command, to start a pot
- Add a jstop command, to stop a pot
- Add an option to jstart, to take a snapshot of the pot before the start
- Add a help command, to show subcommand helps
- Add a list command, to list of pots
- Add a add-fscomp command, to add fscomponents to pots
- Add a snapshot command, to take a snapshot of a pot

### Changed
- After long time spent on thinking, the project has a new nice name, pot.
