# pot

[![Test Status](https://travis-ci.org/pizzamig/pot.png?branch=master)](https://travis-ci.org/pizzamig/pot) [![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

Another container framework based on jails, to run FreeBSD containers on FreeBSD.
Every running instance is called "pot", but less flexible than a VM.
It's heavily based on FreeBSD, in particular on jails, ZFS, pf and rctl.

Currently, pot is only a bunch of shell script enforcing the pot container model, but it relay only on the command line tools provided by FreeBSD to play with jails, ZFS and so on.
So, at the moment the only dependency is the operating system. That will change in the future, to provide more features.

It is an educational/experimental project, but it's becoming more robust.

The project was presented at FOSDEM 2018: [video mp4](https://video.fosdem.org/2018/K.3.401/pot_container_framework.mp4) [video webm](https://video.fosdem.org/2018/K.3.401/pot_container_framework.webm) [slides (PDF)](https://fosdem.org/2018/schedule/event/pot_container_framework/attachments/slides/2128/export/events/attachments/pot_container_framework/slides/2128/pot_slides.pdf)

### Quickstart guide
A non-exaustive guide is available in the folder `share/doc/pot`:

* [as Markdown file](https://github.com/pizzamig/pot/blob/master/share/doc/pot/QuickStart.md)
* [as html](https://people.freebsd.org/~pizzamig/pot/QuickStart.html)

### Installation guide
An exaustive installation guide is available in the folder `share/doc/pot`:

* [as Markdown file](https://github.com/pizzamig/pot/blob/master/share/doc/pot/Installation.md)
* [as html](https://people.freebsd.org/~pizzamig/pot/Installation.html)

#### Nomad pot driver integration
A driver to allow [nomad](https://www.nomadproject.io) to interact with `pot` has been developed and available [here](https://github.com/trivago/nomad-pot-driver) 

An important step to interact with nomad is to create `pot` images. An introduction guide to images is available in the folder `share/doc/pot`:
* [as Markdown file](https://github.com/pizzamig/pot/blob/master/share/doc/pot/Images.md)
* [as html](https://people.freebsd.org/~pizzamig/pot/Images.html)

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
	create -- Create a new pot (jail)
	clone -- Clone a pot creating a new one
	clone-fscomp - Clone a fscomp
	rename -- Rename a pot
	destroy -- Destroy a pot
	copy-in -- Copy a file or a directory into a pot
	mount-in -- Mount a directory, a zfs dataset or a fscomp into a pot
	add-dep -- Add a dependency
	set-rss -- Set a resource constraint
	set-cmd -- Set the command to start the pot
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
	prepare/execute -- Import and prepare a pot - designed for jail orchestrator
	update-config -- Update the configuration of a pot
```

Every command has its own online help as well. For instance:
```
# pot help create
pot create [-hv] -p potname [-i ipaddr] [-s] [-l lvl] [-f flavour]
  [-b base | -P basepot ] [-d dns] [-t type]
  -h print this help
  -v verbose
  -p potname : the pot name (mandatory)
  -l lvl : pot level (only for type multi)
  -b base : the base pot
  -P pot : the pot to be used as reference
  -i ipaddr : an ip address or the keyword auto or the keyword inherit
  -s : static ip address
  -d dns : one between inherit(default) or pot
  -f flavour : flavour to be used
  -t type: single or multi (default multi)
         single: the pot is based on a unique ZFS dataset
         multi: the pot is composed by a classical collection of 3 ZFS dataset
```

