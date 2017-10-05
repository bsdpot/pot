#!/bin/sh

# include configuration file

# include common shell subroutines

# create the pot root

zfs create -o mountpoint=/opt/pot -o canmount=off -o compression=lz4 -o atime=off zroot/pot

# create the root directory

mkdir -p /opt/pot

# create mandatori datasets

zfs create zroot/pot/bases
zfs create zroot/pot/jails
zfs create zroot/pot/fscomp

