#!/bin/bash -x

if [ $EUID -ne 0 ]; then
	sudo $0 "$@"
fi

if [ ! -e /dev/kvm ]; then
   mknod /dev/kvm c 10 $(grep '\<kvm\>' /proc/misc | cut -f 1 -d' ')   
fi
