#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for tailscale
PKG_VERSION:=0.0.1
LUCI_DEPENDS:=+tailscale

define Package/luci-app-tailscaler/conffiles
/etc/config/tailscaler
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature