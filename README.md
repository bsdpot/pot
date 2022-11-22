# pot

[![build-badge](https://github.com/pizzamig/pot/workflows/unit-test/badge.svg)](https://github.com/pizzamig/pot/actions) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

Another container framework based on jails, to run FreeBSD containers on FreeBSD.
Every running instance is called `pot`, like the one that I use to cook all the different type of pasta.
It's heavily based on FreeBSD, in particular on jails, ZFS, pf and rctl.

The project's initial goal was to prove that FreeBSD has all the technologies to have a container-alike environment.
The project then evolved in something more robust and feature-rich.

The project was presented for the first time at FOSDEM 2018: ([talk page](https://archive.fosdem.org/2018/schedule/event/pot_container_framework/))

If you are more interested in jail orchestration, a nomad driver is provided to interact with `pot` and this work has been presented at FOSDEM 2020 ([talk page](https://archive.fosdem.org/2020/schedule/event/orchestrating_jails/))

### Documentation
The project's documentation is available at [https://pot.pizzamig.dev](https://pot.pizzamig.dev)

More in details:
* A Getting started guide is available [here](https://pot.pizzamig.dev/Getting)
* An installation guide, with detailed description is available [here](https://pot.pizzamig.dev/Installation)

### Nomad pot driver integration
A driver to allow [nomad](https://www.nomadproject.io) to interact with `pot` has been developed and available [here](https://github.com/trivago/nomad-pot-driver)

### Online help
`pot` provide an online help:
```
# pot help
Usage: pot command [options]

Commands:
	help	-- Show help
	version -- Show the pot version
	config  -- Show pot framework configuration
	ls/list	-- List of the installed pots
	show	-- Show pot information
	info    -- Print minimal information on a pot
	top     -- Run the unix top in the pot
	ps      -- Show running pots
	init	-- Initialize the ZFS layout
	de-init	-- Deinstall pot from your system
	vnet-start -- Start the vnet configuration
	create-base	-- Create a new base image
	create-fscomp -- Create a new fs component
	create-private-bridge -- Create a new private bridge
	create -- Create a new pot (jail)
	clone -- Clone a pot creating a new one
	clone-fscomp - Clone a fscomp
	rename -- Rename a pot
	destroy -- Destroy a pot
	prune   -- Destroy not running prunable pots
	copy-in -- Copy a file or a directory into a pot
	mount-in -- Mount a directory, a zfs dataset or a fscomp into a pot
	add-dep -- Add a dependency
	set-rss -- Set a resource constraint
	get-rss -- Get the current resource usage
	set-cmd -- Set the command to start the pot
	set-env -- Set environment variabls inside a pot
	set-hosts -- Set etc/hosts entries inside a pot
	set-hook -- Set hook scripts for a pot
	set-attr -- Set a pot's attribute
	get-attr -- Get a pot's attribute
	export-ports -- Let export tcp ports
	start -- Start a jail (pot)
	stop -- Stop a jail (pot)
	term -- Start a terminal in a pot
	run -- Start and open a terminal in a pot
	snap/snapshot -- Take a snapshot of a pot
	rollback/revert -- Restore the last snapshot
	purge-snapshots -- Remove old/all snapshots
	export -- Export a pot to a file
	import -- Import a pot from a file or a URL
	prepare -- Import and prepare a pot - designed for jail orchestrator
	update-config -- Update the configuration of a pot
```

Every command has its own online help as well. For instance:
```
pot create [-hv] -p potname [-N network-type] [-i ipaddr] [-l lvl] [-f flavour]
  [-b base | -P basepot ] [-d dns] [-t type]
  -h print this help
  -v verbose
  -k keep the pot, if create fails
  -p potname : the pot name (mandatory)
  -l lvl : pot level (only for type multi)
  -b base : the base pot
  -P pot : the pot to be used as reference
  -d dns : one between inherit(default), pot, off or custom:filename
  -f flavour : flavour to be used
  -t type: single or multi (default multi)
         single: the pot is based on a unique ZFS dataset
         multi: the pot is composed by a classical collection of 3 ZFS dataset
  -N network-type: one of those
         inherit: inherit the host network stack (default)
         alias: use a static ip as alias configured directly to the host NIC
         public-bridge: use the internal commonly public bridge
         private-bridge: use an internal private bridge (with option -B)
  -i ipaddr : an ip address or the keyword auto (if compatible with the network-type)
         auto: usable with public-bridge and private-bridge (default)
         ipaddr: mandatory with alias, usable with public-bridge and private-bridge
  -B bridge-name : the name of the bridge to be used (private-bridge only)
  -S network-stack : the network stack (ipv4, ipv6 or dual)
```
