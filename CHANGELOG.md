# Changelog
All notable changes to this project will be documented in this file.


The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- stop (#024): check the pot existance
- stop : fixed error messages referring to "jail"
- list : fix help, option -s never implemented

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
