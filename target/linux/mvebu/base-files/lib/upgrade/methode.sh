platform_do_upgrade_ubi() {
       UBI_MTD=$(grep rootfs /proc/mtd | awk '{print $1}' | cut -d ':' -f1)
       UBI_VOL=/dev/ubi0_0

       # Pivot root

       [ "$(mount | grep "ubi0:rootfs")" ] && printf "Root filesystem is not umounted!"

       # Needs image vertification
       if [ ! -e "$UBI_VOL" ]; then
               ubiattach -p /dev/$UBI_MTD &> /dev/null
       fi

       printf "Updating UBI volume..\n"
       sleep 1
       ubiupdatevol $UBI_VOL $ARGV
       ubidetach -p /dev/$UBI_MTD

       printf "Initializing volume..\n"
       ubiattach -p /dev/$UBI_MTD && ubidetach -p /dev/$UBI_MTD
}
