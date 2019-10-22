#
# Copyright (C) 2019 OpenWrt
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

CC_HOST:=i686

PKG_NAME:=arm-trusted-firmware-mvebu
PKG_RELEASE:=2.1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_RELEASE).tar.xz
PKG_SOURCE_URL=https://github.com/ARM-software/arm-trusted-firmware
PKG_SOURCE_DATE:=2019-10-21
PKG_SOURCE_VERSION:=937f669872b5516c9a0fd3d60f9618ad54a72b5c
PKG_MIRROR_HASH:=ca7e6b148f16064c99303b7e0f9197ecf20b61793b0a947fc454852629dabda1

PKG_MAINTAINER:=Vladimir Vid <vladimir.vid@sartura.hr>

include $(INCLUDE_DIR)/package.mk

define Package/arm-trusted-firmware-mvebu/default
    SECTION:=boot
    CATEGORY:=Boot Loaders
    TITLE:=ARM Trusted Firmware for mvebu devices
    DEPENDS:=@TARGET_mvebu
endef

# Define board specific options in the Device sections, as a3700 platform has a wide range of settings
define Package/arm-trusted-firmware-uDPU
$(call Package/arm-trusted-firmware-mvebu/default)
    BOARDNAME:=uDPU
    TITLE:=ARM Trusted Firmware for Methode uDPU
    DEPENDS+=+u-boot-uDPU
    UBOOT:=uDPU
    CLOCKSPRESET:=CPU_1000_DDR_800
    PLAT:=a3700
endef

# A3700-utils - required for the WTP
A3700_UTILS_NAME:=a3700-utils
A3700_UTILS_RELEASE:=18.12.1
A3700_UTILS_SOURCE=$(A3700_UTILS_NAME)-$(A3700_UTILS_RELEASE).tar.bz2

define Download/a3700-utils
  FILE:=$(A3700_UTILS_SOURCE)
  PROTO:=git
  URL:=https://github.com/MarvellEmbeddedProcessors/A3700-utils-marvell.git
  VERSION:=e6bb176fb9936d9160e53ae09275000dc6440686
  MIRROR_HASH:=c3edf71cbf1fc2e5482d36e36a34c79d682d2c87fdfb909b4dc6327a171e7bd4
  SUBDIR:=$(A3700_UTILS_NAME)
endef

# mv-ddr-marvell - required for A3700 platform
MV_DDR_NAME:=mv-ddr-marvell
MV_DDR_RELEASE:=mainline
MV_DDR_SOURCE:=$(MV_DDR_NAME)-$(MV_DDR_RELEASE).tar.bz2

define Download/mv-ddr-marvell
  FILE:=$(MV_DDR_SOURCE)
  PROTO:=git
  URL:=https://github.com/MarvellEmbeddedProcessors/mv-ddr-marvell.git
  VERSION:=a881467ef0f0185e6570dd0483023fde93cbb5f5
  MIRROR_HASH:=f4caafe195001ccf77006eb02618495d3fe3e529108a94dfc1aef5deb9a961ec
  SUBDIR:=$(MV_DDR_NAME)
endef

# Correct 32-bit and 64-bit cross compiler is required for building the image
LINARO_NAME:=gcc-linaro
LINARO_RELEASE:=6
LINARO_VERSION:=5.0-2018.12
HOST_ARCH:=i686
ARM32_ARCH:=arm-linux-gnueabi
ARM64_ARCH:=aarch64-linux-gnu
LINARO32_SOURCE:=$(LINARO_NAME)-$(LINARO_RELEASE).$(LINARO_VERSION)-$(HOST_ARCH)_$(ARM32_ARCH).tar.xz
LINARO64_SOURCE:=$(LINARO_NAME)-$(LINARO_RELEASE).$(LINARO_VERSION)-$(HOST_ARCH)_$(ARM64_ARCH).tar.xz

define Download/gcc-linaro
  FILE:=$(LINARO32_SOURCE)
  URL:=https://releases.linaro.org/components/toolchain/binaries/latest-$(LINARO_RELEASE)/$(ARM32_ARCH)/
  HASH:=24134423d48c13c8754f4518ce22bb490c8d2bd03a142a03b64e8a118cd188b8
endef

define Download/gcc-linaro64
  FILE:=$(LINARO64_SOURCE)
  URL:=https://releases.linaro.org/components/toolchain/binaries/latest-$(LINARO_RELEASE)/$(ARM64_ARCH)/
  HASH:=e5e9b26d5d4c8f5ff9f4b0ed94199ab5bf9e9be8fabb9ab54e1099df931ee6cd
endef

define Build/Prepare
	# Download sources
	$(eval $(call Download,a3700-utils))
	$(eval $(call Download,mv-ddr-marvell))
	$(eval $(call Download,gcc-linaro))
	$(eval $(call Download,gcc-linaro64))

	rm -rf $(PKG_BUILD_DIR)
	$(TAR) -C $(BUILD_DIR) -xf $(DL_DIR)/$(PKG_SOURCE)
	$(TAR) -C $(STAGING_DIR_IMAGE) -xf $(DL_DIR)/$(A3700_UTILS_SOURCE)
	$(TAR) -C $(STAGING_DIR_IMAGE) -xf $(DL_DIR)/$(MV_DDR_SOURCE)
	$(TAR) -C $(STAGING_DIR_IMAGE) -xf $(DL_DIR)/$(LINARO32_SOURCE)
	$(TAR) -C $(STAGING_DIR_IMAGE) -xf $(DL_DIR)/$(LINARO64_SOURCE)
endef

# Clean the default CFLAGS so they don't mess up with the build
TARGET_CFLAGS = ""

MAKE_FLAGS = \
	CROSS_COMPILE=$(STAGING_DIR_IMAGE)/$(LINARO_NAME)-$(LINARO_RELEASE).$(LINARO_VERSION)-$(HOST_ARCH)_$(ARM64_ARCH)/bin/$(ARM64_ARCH)- \
	CROSS_CM3=$(STAGING_DIR_IMAGE)/$(LINARO_NAME)-$(LINARO_RELEASE).$(LINARO_VERSION)-$(HOST_ARCH)_$(ARM32_ARCH)/bin/$(ARM32_ARCH)- \
	BL33=$(STAGING_DIR_IMAGE)/u-boot.bin \
	MV_DDR_PATH=$(STAGING_DIR_IMAGE)/$(MV_DDR_NAME) \
	WTP=$(STAGING_DIR_IMAGE)/$(A3700_UTILS_NAME) \
	CLOCKSPRESET=$(CLOCKSPRESET) \
	DEBUG=0 \
	USE_COHERENT_MEM=0 \
	LOG_LEVEL=20 \
	SECURE=0 \
	PARTNUM=0 \
	DDR_TOPOLOGY=0 \
	BOOTDEV=SPINOR \
	PLAT=$(PLAT) \
	all \
	fip

define Build/InstallDev
	$(CP) $(PKG_BUILD_DIR)/build/$(PLAT)/release/flash-image.bin $(BIN_DIR)/u-boot-$(BOARDNAME)/
endef

$(eval $(call BuildPackage,arm-trusted-firmware-uDPU))
