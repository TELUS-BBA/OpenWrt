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

#define Device/uDPU
#  KERNEL_NAME := Image
#  KERNEL_LOADADDR := 0x00080000
#  KERNEL := kernel-bin | install-dtb
#  KERNEL_INITRAMFS_PREFIX := $$(IMG_PREFIX)-$$(DEVICE_NAME)-initramfs
#  KERNEL_INITRAMFS_SUFFIX := .itb
#  KERNEL_INITRAMFS := kernel-bin | gzip | fit gzip $$(DTS_DIR)/$$(DEVICE_DTS).dtb
#  DEVICE_TITLE := Methode uDPU Board
#  DEVICE_PACKAGES := f2fs-tools e2fsprogs fdisk ethtool kmod-usb2 kmod-usb3 kmod-e100 kmod-e1000 kmod-e1000e \
#			kmod-igb kmod-ixgbevf kmod-mdio-gpio kmod-sky2 kmod-switch-mvsw61xx kmod-bonding kmod-eeprom-at24
#  IMAGES := sysupgrade.tar.gz
#  IMAGE_NAME := $$(IMAGE_PREFIX)-sysupgrade.tar.gz
#  IMAGE/sysupgrade.tar.gz := uDPU-firmware | gzip | append-metadata
#  DEVICE_DTS := uDPU
#  DTS_DIR := $(DTS_DIR)/marvell
#  SUPPORTED_DEVICES := methode,uDPU
#endef
#TARGET_DEVICES += uDPU

endif
