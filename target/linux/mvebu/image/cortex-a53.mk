ifeq ($(SUBTARGET),cortexa53)

define Device/globalscale-espressobin
  KERNEL_NAME := Image
  KERNEL := kernel-bin
  DEVICE_TITLE := ESPRESSObin (Marvell Armada 3700 Community Board)
  DEVICE_PACKAGES := e2fsprogs ethtool mkf2fs kmod-fs-vfat kmod-usb2 kmod-usb3 kmod-usb-storage
  IMAGES := sdcard.img.gz
  IMAGE/sdcard.img.gz := boot-scr | boot-img-ext4 | sdcard-img-ext4 | gzip | append-metadata
  DEVICE_DTS := armada-3720-espressobin
  DTS_DIR := $(DTS_DIR)/marvell
  SUPPORTED_DEVICES := globalscale,espressobin
endef
TARGET_DEVICES += globalscale-espressobin

define Device/armada-3720-db
  KERNEL_NAME := Image
  KERNEL := kernel-bin
  DEVICE_TITLE := Marvell Armada 3720 Development Board DB-88F3720-DDR3
  DEVICE_PACKAGES := e2fsprogs ethtool mkf2fs kmod-fs-vfat kmod-usb2 kmod-usb3 kmod-usb-storage
  IMAGES := sdcard.img.gz
  IMAGE/sdcard.img.gz := boot-scr | boot-img-ext4 | sdcard-img-ext4 | gzip | append-metadata
  DEVICE_DTS := armada-3720-db
  DTS_DIR := $(DTS_DIR)/marvell
  SUPPORTED_DEVICES := marvell,armada-3720-db
endef
TARGET_DEVICES += armada-3720-db

define Device/methode-micro-DPU
  BLOCKSIZE := 64k
  PAGESIZE := 128
  SUBPAGESIZE := 1
  FILESYSTEMS := squashfs ubifs
  UBIFS_OPTS := -m 8 -e 65408 -c 2048
  KERNEL_NAME := Image
  KERNEL_SUFFIX :=
  KERNEL := kernel-bin | install-dtb
  KERNEL_IN_UBI := 1
  DEVICE_TITLE := Methode micro-DPU Board
  DEVICE_PACKAGES := ethtool kmod-usb2 kmod-usb3 kmod-e100 kmod-e1000 kmod-e1000e kmod-igb kmod-ixgbevf kmod-mdio-gpio kmod-sky2 kmod-switch-mvsw61xx kmod-bonding
  IMAGES := sysupgrade.bin factory.ubi
  IMAGE/sysupgrade.bin := sysupgrade-ubi
  IMAGE/factory.ubi := factory-ubi
  DEVICE_DTS := methode-micro-DPU
  DTS_DIR := $(DTS_DIR)/marvell
  SUPPORTED_DEVICES := methode,micro-DPU
endef
TARGET_DEVICES += methode-micro-DPU

endif
