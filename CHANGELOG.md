# Changelog
All notable changes to this project will be documented in this file.


The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unrelease]
### Added
- Add a vnet-start command, to properly init the vnet network configuration (bridge+pf)

### Changed
- Pots with an ip are now based on epair/vnet/VIMAGE technology

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
