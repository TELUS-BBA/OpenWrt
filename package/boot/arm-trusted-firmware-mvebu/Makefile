#
# Copyright (C) 2019 OpenWrt
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arm-trusted-firmware-mvebu
PKG_RELEASE:=18.12

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_RELEASE).tar.xz
PKG_SOURCE_URL=https://github.com/MarvellEmbeddedProcessors/atf-marvell
PKG_SOURCE_DATE:=2018-12-24
PKG_SOURCE_VERSION:=1f8ca7e01d4ac7023aea0eeb4c8a4b98dcf05760
PKG_MIRROR_HASH:=716c355309b820d89333a444f35f781da8a7f45fe5cdf35d4bdacd32ea6bd9d0

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
A3700_UTILS_RELEASE:=18.12.0
A3700_UTILS_SOURCE=$(A3700_UTILS_NAME)-$(A3700_UTILS_RELEASE).tar.bz2

define Download/a3700-utils
  FILE:=$(A3700_UTILS_SOURCE)
  PROTO:=git
  URL:=https://github.com/MarvellEmbeddedProcessors/A3700-utils-marvell.git
  VERSION:=a0a1cb88327afa91415c59822fa9c5894d9ec3d7
  MIRROR_HASH:=d0d8986637961c5575e42eb6542b0ec3a17ef403a745babc197d1796548b2bc7
  SUBDIR:=$(A3700_UTILS_NAME)
endef

# mv-ddr-marvell - required for A3700 platform
MV_DDR_NAME:=mv-ddr-marvell
MV_DDR_RELEASE:=18.12.0
MV_DDR_SOURCE:=$(MV_DDR_NAME)-$(MV_DDR_RELEASE).tar.bz2

define Download/mv-ddr-marvell
  FILE:=$(MV_DDR_SOURCE)
  PROTO:=git
  URL:=https://github.com/MarvellEmbeddedProcessors/mv-ddr-marvell.git
  VERSION:=618dadd1491eb2f7b2fd74313c04f7accddae475
  MIRROR_HASH:=f4caafe195001ccf77006eb02618495d3fe3e529108a94dfc1aef5deb9a961ec
  SUBDIR:=$(MV_DDR_NAME)
endef

# 32-bit cross compiler is required for building the WTMI image
LINARO_NAME:=gcc-linaro
LINARO_RELEASE:=6
LINARO_VERSION:=5.0-2018.12-i686_arm-linux-gnueabi
LINARO_SOURCE=$(LINARO_NAME)-$(LINARO_RELEASE).$(LINARO_VERSION).tar.xz

define Download/gcc-linaro
  FILE:=$(LINARO_SOURCE)
  URL:=https://releases.linaro.org/components/toolchain/binaries/latest-$(LINARO_RELEASE)/arm-linux-gnueabi/
  HASH:=24134423d48c13c8754f4518ce22bb490c8d2bd03a142a03b64e8a118cd188b8
endef

define Build/Prepare
	# Download sources
	$(eval $(call Download,a3700-utils))
	$(eval $(call Download,mv-ddr-marvell))
	$(eval $(call Download,gcc-linaro))

	rm -rf $(PKG_BUILD_DIR)
	$(TAR) -C $(BUILD_DIR) -xf $(DL_DIR)/$(PKG_SOURCE)
	$(TAR) -C $(STAGING_DIR_IMAGE) -xf $(DL_DIR)/$(A3700_UTILS_SOURCE)
	$(TAR) -C $(STAGING_DIR_IMAGE) -xf $(DL_DIR)/$(MV_DDR_SOURCE)
	$(TAR) -C $(STAGING_DIR_IMAGE) -xf $(DL_DIR)/$(LINARO_SOURCE)
endef

# Clean the default CFLAGS so they don't mess up with the build
TARGET_CFLAGS = ""

MAKE_FLAGS = \
	CROSS_COMPILE=aarch64-linux-gnu- \
	CROSS_CM3=$(STAGING_DIR_IMAGE)/$(LINARO_NAME)-$(LINARO_RELEASE).$(LINARO_VERSION)/bin/arm-linux-gnueabi- \
	BL33=$(STAGING_DIR_IMAGE)/u-boot.bin \
	MV_DDR_PATH=$(STAGING_DIR_IMAGE)/$(MV_DDR_NAME) \
	WTP=$(STAGING_DIR_IMAGE)/$(A3700_UTILS_NAME) \
	CLOCKSPRESET=$(CLOCKSPRESET) \
	PLAT=$(PLAT) \
	all \
	fip

define Build/InstallDev
	$(CP) $(PKG_BUILD_DIR)/build/$(PLAT)/release/flash-image.bin $(BIN_DIR)/u-boot-$(BOARDNAME)/
endef

$(eval $(call BuildPackage,arm-trusted-firmware-uDPU))
