#!/bin/bash
# Zhouping Liu <zliu@redhat.com>
# ------------------------------

/usr/libexec/qemu-kvm -monitor stdio -drive file=/root/RHEL-Server-5.8-64-virtio.qcow2,index=0,if=ide,media=disk,cache=none,format=qcow2 -net nic,vlan=0,model=rtl8139,macaddr=00:30:91:aa:04:74 -net tap,vlan=0,script=/etc/qemu-ifup,downscript=no -m 2048 -smp 2,cores=1,threads=1,sockets=2 -cpu qemu64,+sse2 -soundhw ac97 -rtc-td-hack -M rhel5.6.0 -usbdevice tablet -vnc :10 -boot c -no-kvm-pit-reinjection
