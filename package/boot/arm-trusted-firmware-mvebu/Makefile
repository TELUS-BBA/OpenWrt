#
# Copyright (C) 2019 OpenWrt
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arm-trusted-firmware-mvebu
PKG_RELEASE:=17.10.8

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_RELEASE).tar.xz
PKG_SOURCE_URL=https://github.com/MarvellEmbeddedProcessors/atf-marvell
PKG_SOURCE_DATE:=2018-06-06
PKG_SOURCE_VERSION:=34247e027e234634d65287d1cfdf0c3d6eb98cae
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
    TITLE:=ARM Trusted Firmware for uDPU board
    DEPENDS+=+u-boot-uDPU
    CLOCKSPRESET:=CPU_1000_DDR_800
    PLAT:=a3700
endef

PKG_A3700_UTILS_NAME:=a3700-utils
PKG_A3700_UTILS_RELEASE:=17.10.5
PKG_A3700_UTILS_SOURCE=$(PKG_A3700_UTILS_NAME)-$(PKG_A3700_UTILS_RELEASE).tar.bz2

# A3700-uilts - required for the WTP
define Download/a3700-utils
  FILE:=$(PKG_A3700_UTILS_SOURCE)
  PKG_RELEASE:=$(PKG_A3700_UTILS_RELEASE)
  PROTO:=git
  URL:=https://github.com/MarvellEmbeddedProcessors/A3700-utils-marvell
  VERSION:=177ba4771f3011362793422d0edc7f9b77d9424d
  MIRROR_HASH:=45e23e8f4ccd01eab7d09149a9a26723d4cc892cce9cbf705f4898608bf799ad
  SUBDIR:=$(PKG_A3700_UTILS_NAME)
endef
$(eval $(call Download,a3700-utils))

PKG_LINARO_NAME:=gcc-linaro
PKG_LINARO_RELEASE:=5
PKG_LINARO_VERSION:=5.0-2017.10
PKG_LINARO_ARCH_PREFIX:=i686_arm-linux-gnueabi
PKG_LINARO_SOURCE=$(PKG_LINARO_NAME)-$(PKG_LINARO_RELEASE).$(PKG_LINARO_VERSION)-$(PKG_LINARO_ARCH_PREFIX).tar.xz

# 32-bit cross compiler is required for building the WTMI image
define Download/gcc-linaro
  FILE:=$(PKG_LINARO_SOURCE)
  URL:=https://releases.linaro.org/components/toolchain/binaries/latest-$(PKG_LINARO_RELEASE)/arm-linux-gnueabi/
  HASH:=22ed082a9d661279c42c65f11999fa81e2a1860729bed14db685e452710d7652
endef
$(eval $(call Download,gcc-linaro))

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	$(TAR) -C $(BUILD_DIR) -xf $(DL_DIR)/$(PKG_SOURCE)
	$(TAR) -C $(STAGING_DIR) -xf $(DL_DIR)/$(PKG_A3700_UTILS_SOURCE)
	$(TAR) -C $(STAGING_DIR) -xf $(DL_DIR)/$(PKG_LINARO_SOURCE)
endef

export BL33=$(STAGING_DIR)/u-boot.bin
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_CM3=$(STAGING_DIR)/$(PKG_LINARO_NAME)-$(PKG_LINARO_RELEASE).$(PKG_LINARO_VERSION)-$(PKG_LINARO_ARCH_PREFIX)/bin/arm-linux-gnueabi-

# Clean the default CFLAGS so they don't mess up with the build
TARGET_CFLAGS =

MAKE_FLAGS = \
	CLOCKSPRESET=$(CLOCKSPRESET) \
	PLAT=$(PLAT) \
	WTP=$(STAGING_DIR)/$(PKG_A3700_UTILS_NAME) \
	all \
	fip

define Build/InstallDev
	$(CP) $(PKG_BUILD_DIR)/build/$(PLAT)/release/flash-image.bin $(BIN_DIR)/u-boot-$(BOARDNAME)
endef

$(eval $(call BuildPackage,arm-trusted-firmware-uDPU))
