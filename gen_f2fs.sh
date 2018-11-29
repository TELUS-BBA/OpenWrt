#!/bin/bash

BOOTFS="build_dir/target-aarch64_cortex-a53_musl/boot/"
ROOTFS="build_dir/target-aarch64_cortex-a53_musl/root-mvebu/"

BOOTFS_SIZE=15
ROOTFS_SIZE=50

# Create boot partition
dd if=/dev/zero of=./devel/bootpart.img count=$BOOTFS_SIZE bs=512
./staging_dir/host/bin/make_ext4fs -J -L boot -l $((BOOTFS_SIZE*1024))K devel/bootpart.img $BOOTFS

# Create rootfs partition
dd if=/dev/zero of=./devel/rootfspart.img count=$ROOTFS_SIZE bs=1M
./staging_dir/host/bin/mkfs.f2fs -l rootfs ./devel/rootfspart.img

# Create misc partition
dd if=/dev/zero of=./devel/miscpart.img count=$ROOTFS_SIZE bs=1M
./staging_dir/host/bin/mkfs.f2fs -l misc ./devel/misc.img

# Tmp dir for mounting
[[ -d ./tmp/mnt ]] && rm -r ./tmp/mnt
mkdir -p ./tmp/mnt
sudo mount ./devel/rootfspart.img ./tmp/mnt
cd ./tmp/mnt
tar cvzf rootfs.tar.gz ../../$ROOTFS
sync
cd ../..
sudo umount ./tmp/mnt
rm -r ./tmp/mnt

# Create final img
dd if=/dev/zero of=./devel/final.img bs=512 count=1

./staging_dir/host/bin/ptgen -o ./devel/final.img -h 16 -s 63 -l 1024 -t 83 -p 16640 -t 83 -p 262400 -t 83 -p 262400

(cat ./devel/bootpart.img
dd if=/dev/zero bs=128k count=1 2>/dev/null
) | dd of=./devel/final.img bs=512 seek=2048 conv=notrunc 2>/dev/null

(cat ./devel/rootfspart.img
dd if=/dev/zero bs=128k count=1 2>/dev/null
) | dd of=./devel/final.img bs=512 seek=3147776 conv=notrunc 2>/dev/null

(cat ./devel/miscpart.img
dd if=/dev/zero bs=128k count=1 2>/dev/null
 ) | dd of=./devel/final.img bs=512 seek=7342079 conv=notrunc 2>/dev/null

# Gzip final.img
tar cvzf ./devel/final.tar.gz ./devel/final.img
