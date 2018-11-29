#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=f2fs-tools
PKG_CPE_ID:=cpe:/a:jaegeuk:f2fs-tools
PKG_VERSION:=1.11.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/$(PKG_SOURCE)
PKG_HASH:=b916ac7cda902502cf18de98da94921f71edbab40fb0437d757f0716191c79e3

include $(INCLUDE_DIR)/host-build.mk

HOST_CONFIGURE_VARS+= \
	--host=$(GNU_HOST_NAME) \
	--target=$(GNU_HOST_NAME) \
	--static

define Host/Configure
	(cd $(HOST_BUILD_DIR); \
		autoreconf --install; \
		./configure \
	)
endef

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR)
endef

define Host/Install
	install -m0755 $(HOST_BUILD_DIR)/mkfs/mkfs.f2fs $(STAGING_DIR_HOST)/bin/
	install -m0755 $(HOST_BUILD_DIR)/fsck/fsck.f2fs $(STAGING_DIR_HOST)/bin/
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOST)/bin/mkfs.f2fs
	rm -f $(STAGING_DIR_HOST)/bin/fsck.f2fs
endef

$(eval $(call HostBuild))
