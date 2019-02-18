## Manual migration handbook

### Prerequisite

* testing with single type pot
* a snapshot is already present

### A xz archive of the datasets

* `zfs send -R zroot/pot/jails/mypot@1539804703 | xz > mypot.1539804703.xz`

Some statistics on FreeBSD 12.0
The file systems are accounted for 801MB, lz4 providing 2.23 as compression ration, leaving 383MB on the disk.
xz -9 is extremely slow, using +800MB of RAM and producing an output of 132MB
xz -6 (default) is quite slow, producing an output of 148MB
xz -3 is decently fast, producing an output of 164MB
xz -0 is quite fast, producing an output of 182MB

# Speculation

### A migration process

send the first xz file and combine with the receive
* `xzcat mypot.1539804703.xz | zfs receive ${POT_ZFS_ROOT}/jails/mypot@1539804703

depending on the content of pot.conf and fscomp.conf, get and extract the other datasets propery
In this case:
* xzcat mypot_m.1539804703.xz | zfs receive ${POT_ZFS_ROOT}/jails/mypot/m@1539804703
