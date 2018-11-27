emmc_dev="/dev/mmcblk1"

do_part_check() {
	local emmc_parts="1 2 3 4"
	local part_valid="1"

	# Check if the block devices exist
	for num in ${emmc_parts}; do
		[[ ! -b ${emmc_dev}p${num} ]] && part_valid="0"
	done

	# If devices are missing create a new partition table
	if [ "$part_valid" != "1" ]; then
		printf "Invalid partition table, creating a new one\n"
		printf "o\nn\np\n1\n\n+256M\nn\np\n2\n\n+256M\nn\np\n3\n\n+1536M\nn\np\n\n\nw\n" | fdisk -W always $emmc_dev  > /dev/null 2>&1

		# Format the /misc part right away as we will need it for the firmware
		printf "Formating /misc partition, this make take a while..\n"
		mkfs.f2fs -q -l misc ${emmc_dev}p4
		[ $? -eq 0 ] && printf "/misc partition formated successfully\n" || printf "/misc partition formatting failed\n"

		do_initial_setup
	else
		printf "Partition table looks ok\n"
	fi

}

do_misc_prep() {
	if [ ! "$(grep -wo /misc /proc/mounts)" ]; then
		mkdir -p /misc
		mount ${emmc_dev}p4 /misc

		# If the mount fails, try to reformat partition
		# Leaving possiblity for multiple iterations
		if [ $? -ne 0 ]; then
			printf "Error while mounting /misc, trying to reformat..\n"

			format_count=0
			while [ "$format_count" -lt "1" ]; do
				mkfs.f2fs -q -l misc ${emmc_dev}p4
				mount ${emmc_dev}p4 /misc
				if [ $? -ne 0 ]; then
					umount -l /misc
					printf "Failed while mounting /misc\n"
					format_count=$((format_count +1))
				else
					printf "Mounted /misc successfully\n"
					break
				fi
			done
		fi
	fi
}

do_initial_setup() {
	# Prepare /recovery parition
	mkfs.ext4 -q ${emmc_dev}p2 | echo y &> /dev/null

	# Prepare /boot partition
	mkfs.ext4 -q ${emmc_dev}p1 | echo y &> /dev/null

	# Prepare /root partition
	printf "Formating /root partition, this may take a while..\n"
	mkfs.f2fs -q -l rootfs ${emmc_dev}p3
	[ $? -eq 0 ] && printf "/root partition reformated\n"

}

do_regular_upgrade() {
	# Clean /boot partition - mfks.ext4 is not available in chroot
	[ "$(grep -wo /boot /proc/mounts)" ] && umount /boot
	mkdir -p /tmp/boot
	mount ${emmc_dev}p1 /tmp/boot
	rm -rf /tmp/boot/*

	# Clean /root partition - mkfs.f2fs is not available in chroot
	[ "$(grep -wo /dev/root /proc/mounts)" ] && umount /
	mkdir -p /tmp/rootpart
	mount ${emmc_dev}p3 /tmp/rootpart
	rm -rf /tmp/rootpart/*
}

platform_do_upgrade_uDPU() {
	# Prepare and extract firmware on /misc partition
	do_misc_prep

	[ -f "/misc/firmware" ] && rm -r /misc/firmware
	mkdir -p /misc/firmware
	tar xzf "$1" -C /misc/firmware/

	do_regular_upgrade

	printf "Updating /boot partition\n"
	tar xzf /misc/firmware/boot.tar.gz -C /tmp/boot
	[ $? -eq 0 ] && printf "/boot partition updated successfully\n" || printf "/boot partition update failed\n"
	sync

	printf "Updating /root partition\n"
	tar xzf /misc/firmware/rootfs.tar.gz -C /tmp/rootpart
	[ $? -eq 0 ] && printf "/root partition updated successfully\n" || printf "/root partition update failed\n"
	sync

	# Remove temp mounts
	tmp_parts=$(grep "${emmc_dev}" /proc/mounts | awk '{print $2}')
	for part in ${tmp_parts}; do
		umount $part
		# Force umount is necessary
		[ "$(grep "${part}" /proc/mounts)" ] && umount -l $part
	done
}

platform_copy_config_uDPU() {
	# Work in progress
	do_misc_prep
	cp -f /tmp/sysupgrade.tgz /misc
	sync
}
