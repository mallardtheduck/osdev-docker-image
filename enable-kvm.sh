#!/bin/bash

if [ $EUID -ne 0 ]; then
	sudo $0 "$@"
	exit $?
fi

lsmod | grep '\<kvm\>' > /dev/null || {
	echo >&2 "KVM module not loaded"
	exit 1
}

if [ ! -e /dev/kvm ]; then
   mknod /dev/kvm c 10 $(grep '\<kvm\>' /proc/misc | cut -f 1 -d' ')   
fi

dd if=/dev/kvm count=0 2>/dev/null || {
	echo >&2 "KVM device not usable; is container privileged?"
	exit 1
}

if [ -e /dev/kvm ]; then
	chmod 666 /dev/kvm
fi

exit 0
