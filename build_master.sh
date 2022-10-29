#!/bin/bash

set -e

if [[ "${1}" != "skip" ]] ; then
	./build_clean.sh
	./build_kernel.sh stock "$@" || exit 1
fi

VERSION="$(cat version)-$(date +%F | sed s@-@@g)"

if [ -e boot.img ] ; then
	rm arter97-kernel-$VERSION.zip 2>/dev/null

	# Pack AnyKernel2
	rm -rf kernelzip
	mkdir -p kernelzip/dtbs
	cp arch/arm64/boot/Image.gz kernelzip/
	find arch/arm64/boot -name '*.dtb' -exec cp {} kernelzip/dtbs/ \;
	echo "
kernel.string=arter97 kernel $(cat version) @ xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=beryllium
block=/dev/block/bootdevice/by-name/boot
is_slot_device=auto
ramdisk_compression=auto
" > kernelzip/props
	cp -rp ~/android/anykernel2/* kernelzip/
	cd kernelzip/
	7z a -mx0 arter97-kernel-$VERSION-tmp.zip *
	zipalign -v 4 arter97-kernel-$VERSION-tmp.zip ../arter97-kernel-$VERSION.zip
	rm arter97-kernel-$VERSION-tmp.zip
	cd ..
	ls -al arter97-kernel-$VERSION.zip
fi
