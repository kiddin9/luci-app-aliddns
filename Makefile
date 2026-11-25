#
# Copyright (C) 2018-2026 honwen <https://github.com/honwen/>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-aliddns
PKG_VERSION:=2.1.0
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=honwen <https://github.com/honwen/>

LUCI_TITLE:=LuCI Support for AliDDNS
LUCI_DESCRIPTION:=Native ucode and LuCI JavaScript client for Alibaba Cloud Dynamic DNS (AliDDNS) on OpenWrt 25.12+.
LUCI_DEPENDS:=+luci-base +ucode +ucode-mod-fs +ucode-mod-uci +ucode-mod-ubus +ucode-mod-uloop +ucode-mod-resolv +curl +ca-bundle
LUCI_PKGARCH:=all

define Package/luci-app-aliddns/conffiles
/etc/config/aliddns
endef

define Build/Prepare/luci-app-aliddns
	chmod 0755 $(PKG_BUILD_DIR)/root/etc/init.d/aliddns
	chmod 0755 $(PKG_BUILD_DIR)/root/etc/hotplug.d/iface/80-aliddns
	chmod 0755 $(PKG_BUILD_DIR)/root/etc/uci-defaults/40_luci-aliddns
	chmod 0755 $(PKG_BUILD_DIR)/root/usr/sbin/aliddns
	chmod 0644 $(PKG_BUILD_DIR)/root/usr/share/rpcd/ucode/luci.aliddns
	chmod 0644 $(PKG_BUILD_DIR)/root/usr/share/luci/menu.d/luci-app-aliddns.json
	chmod 0644 $(PKG_BUILD_DIR)/root/usr/share/rpcd/acl.d/luci-app-aliddns.json
	chmod 0600 $(PKG_BUILD_DIR)/root/etc/config/aliddns
endef

define Package/luci-app-aliddns/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
if [ -f /etc/uci-defaults/40_luci-aliddns ]; then
	( . /etc/uci-defaults/40_luci-aliddns ) && rm -f /etc/uci-defaults/40_luci-aliddns
fi
rm -f /tmp/luci-indexcache /tmp/luci-indexcache.*
rm -rf /tmp/luci-modulecache/
[ -x /etc/init.d/rpcd ] && /etc/init.d/rpcd restart >/dev/null 2>&1 || true
[ -x /etc/init.d/aliddns ] && {
	/etc/init.d/aliddns enable >/dev/null 2>&1 || true
	/etc/init.d/aliddns reload >/dev/null 2>&1 || true
}
exit 0
endef

define Package/luci-app-aliddns/prerm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
if [ -x /etc/init.d/aliddns ]; then
	/etc/init.d/aliddns stop >/dev/null 2>&1 || true
	/etc/init.d/aliddns disable >/dev/null 2>&1 || true
fi
exit 0
endef

ifneq ($(wildcard $(TOPDIR)/feeds/luci/luci.mk),)
  include $(TOPDIR)/feeds/luci/luci.mk
else
  include ../../luci.mk
endif

# call BuildPackage - OpenWrt buildroot signature
