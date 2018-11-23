emmc_dev="/dev/mmcblk1"

do_part_check() {
	emmc_parts="1 2 3 4"

	part_valid="1"

	for num in ${emmc_parts}; do
		[[ ! -b ${emmc_dev}p${num} ]] && part_valid="0"
	done

	if [ "$part_valid" != "1" ]; then
		printf "Partition table corrupted/invalid, creating new one\n"
		printf "o\nw\n" | fdisk $emmc_dev # > /dev/null 2>&1
		printf "o\nn\np\n1\n\n+256M\nn\np\n2\n\n+256M\nn\np\n3\n\n+1536M\nn\np\n\n\nw\n" | fdisk -W always $emmc_dev # > /dev/null 2>&1
		mkfs.f2fs -f -l misc ${emmc_dev}p4
		[[ $? == 0 ]] && printf "misc partition reformated\n"
		touch /tmp/enpt_lock
	else
		printf "Partition table ok\n"
	fi

}

do_misc_prep() {
	if [ ! "$(grep -wo /misc /proc/mounts)" ]; then
		[[ ! -d /misc ]] && mkdir /misc
		mount ${emmc_dev}p4 /misc
		if [[ $? != 0 ]]; then
			printf "Error while mounting /misc, trying to reformat\n"
			mkfs.f2fs -f -l misc ${emmc_dev}p4
			mount ${emmc_dev}p4 /misc
		fi
	elif [ "$(grep -wo /misc /proc/mounts)" != "${emmc_dev}p4" ]; then
		umount /misc
		[[ $? != 0 ]] && umount -l /misc
		mount ${emmc_dev}p4 /misc
	fi
}

platform_do_upgrade_uDPU() {
	do_part_check
	do_misc_prep

	mkdir -p /misc/firmware
	tar xzf "$1" -C /misc/firmware/
	ls /misc/firmware

	## - Stage 1 upgrade -
	## only boot and rootfs partitions are updated

	stage1_upgrade_parts="boot rootfs"
	for part in $stage1_upgrade_parts; do
		[ "$(grep -wo /${part} /proc/mounts)" ] && umount /${part}
	done

	printf "Updating /boot partition\n"
#	dd if=/misc/firmware/boot.ext4 of=${emmc_dev}p1 bs=512 && sync
	mkfs.ext4 ${emmc_dev}p1
	mkdir -p /tmp/boot
	mount ${emmc_dev}p1 /tmp/boot
	tar xzf /misc/firmware/boot.tar.gz -C /tmp/boot && sync
	umount /tmp/boot
	[[ $? == 0 ]] && printf "/boot partition updated successfully\n" || printf "/boot partition update failed\n"

	printf "Formating /root partition, this may take a couple of minutes..\n"
	mkfs.f2fs -f -l rootfs ${emmc_dev}p3
	[[ $? == 0 ]] && printf "/root partition reformated\n"
	mkdir -p /tmp/root_part
	mount ${emmc_dev}p3 /tmp/root_part
	tar xzf /misc/firmware/rootfs.tar.gz -C /tmp/root_part && sync
	[[ $? == 0 ]] && printf "/root parition updated\n" || printf "/root parition update failed\n"
	umount /tmp/root_part

	if [ -f "/tmp/enpt_lock" ]; then
		printf "Formating /recovery partition\n"
#		dd if=/misc/firmware/recovery.ext4 of=${emmc_dev}p2 bs=512 && sync
		mkfs.ext4 ${emmc_dev}p2
		mkdir -p /tmp/recovery
		mount ${emmc_dev}p3 /tmp/recovery
		tar xzf /misc/firmware/recovery.tar.gz -C /tmp/recovery && sync
		umount /tmp/boot
		[[ $? == 0 ]] && printf "/recovery partition updated successfully\n" || printf "/recovery partition update failed\n"
	fi
}

platform_copy_config_uDPU() {
	do_misc_prep

	cp -f /tmp/sysupgrade.tgz /misc
	sync
}
