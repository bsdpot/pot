#!/bin/sh

dirs="/usr/share/bsdconfig /usr/share/doc /usr/share/dtrace /usr/share/examples /usr/share/man /usr/share/openssl /usr/share/sendmail /usr/share/pc-sysinstall /usr/libexec/bsdinstall /usr/libexec/bsdconfig /rescue /usr/tests /usr/lib32 /usr/lib/clang /usr/include /var/db/freebsd-update /var/db/etcupdate /boot"
usr_bin="c++ c++filt c89 c99 cc CC cpp clang clang-cpp clang-tblgen clang++ gdb gdbtui gdbserver ld ld.bfd ld.lld lldb llvm-objdump llvm-tblgen nm objcopy objdump strings strip"
usr_bin_glob="svnlite yp"

usr_sbin="dtrace"
usr_sbin_glob="bhyve boot yp"
rm -f /usr/lib/*.a
## Remove pkg stuff
rm -rf /var/db/pkg/*
rm -rf /usr/sbin/pkg
rm -rf /usr/local/sbin/pkg

for d in $dirs ; do
	rm -rf ${d}
done
(
	cd /usr/bin
	for f in $usr_bin ; do
		rm -f $f
	done
	for g in $usr_bin_glob ; do
		rm -rf ${g}*
	done
)
(
	cd /usr/sbin
	for g in $usr_sbin_glob ; do
		rm -rf ${g}*
	done
	rm -f $usr_sbin
)
