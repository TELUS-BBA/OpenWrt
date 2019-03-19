#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_VERSION:=2018.07
PKG_RELEASE:=1

PKG_HASH:=9f10df88bc91b35642e461217f73256bbaeeca9ae2db8db56197ba5e89e1f6d4

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define U-Boot/Default
  BUILD_TARGET:=mvebu
  HIDDEN:=1
endef

define U-Boot/clearfog
  NAME:=SolidRun ClearFog A1
  BUILD_DEVICES:=armada-388-clearfog-base armada-388-clearfog-pro
  BUILD_SUBTARGET:=cortexa9
  UBOOT_IMAGE:=u-boot-spl.kwb
endef

UBOOT_TARGETS:= \
	clearfog

Build/Exports:=$(Host/Exports)

define Build/Configure
	# enable additional options beyond clearfog_defconfig
	echo CONFIG_NET_RANDOM_ETHADDR=y >> $(PKG_BUILD_DIR)/configs/$(BUILD_VARIANT)_defconfig
	echo CONFIG_CMD_SETEXPR=y >> $(PKG_BUILD_DIR)/configs/$(BUILD_VARIANT)_defconfig

	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) $(UBOOT_CONFIGURE_VARS) $(UBOOT_CONFIG)_config
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(CP) $(PKG_BUILD_DIR)/$(UBOOT_IMAGE) $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot-spl.kwb
endef

$(eval $(call BuildPackage/U-Boot))
