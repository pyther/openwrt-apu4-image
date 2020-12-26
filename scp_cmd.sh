#!/bin/sh
# SCP command for rootfs and kernel image. To be used with openwrt-upgrade-ab

DIR="build/$(date +%Y%m%d)"
HOST="openwrt.local"

echo scp "./$DIR/openwrt-imagebuilder-x86-64.Linux-x86_64/bin/targets/x86/64/openwrt-x86-64-generic-{kernel,rootfs}*" root@$HOST:/root/
