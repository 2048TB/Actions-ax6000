#!/bin/bash
#
# Merged DIY script for OpenWrt build pipeline.
# Usage:
#   ./diy.sh pre   # before feeds update/install
#   ./diy.sh feeds # after feeds update, before feeds install
#   ./diy.sh post  # after feeds install, before build
#

set -euo pipefail

STAGE="${1:-pre}"

case "$STAGE" in
  pre)
    # Keep pre stage for compatibility; PassWall is injected in "feeds" stage.
    ;;

  feeds)
    # Replace legacy golang feed with newer toolchain packages for SingBox/Xray builds.
    GOLANG_FEED_REF="${GOLANG_FEED_REF:-5c14cc148c88b42ea36e8c42733c80acd2ee1949}"
    PASSWALL_LUCI_REF="${PASSWALL_LUCI_REF:-main}"
    PASSWALL_PACKAGES_REF="${PASSWALL_PACKAGES_REF:-main}"

    mkdir -p package/custom

    rm -rf feeds/packages/lang/golang
    git clone --filter=blob:none --depth=1 --single-branch \
      https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang
    git -C feeds/packages/lang/golang fetch --depth=1 origin "$GOLANG_FEED_REF"
    git -C feeds/packages/lang/golang checkout --detach "$GOLANG_FEED_REF"

    # Inject PassWall sources from official repos into package/custom.
    rm -rf package/custom/openwrt-passwall package/custom/passwall-packages
    git clone --filter=blob:none --depth=1 --single-branch \
      https://github.com/Openwrt-Passwall/openwrt-passwall -b main package/custom/openwrt-passwall
    git clone --filter=blob:none --depth=1 --single-branch \
      https://github.com/Openwrt-Passwall/openwrt-passwall-packages -b main package/custom/passwall-packages

    if [ "$PASSWALL_LUCI_REF" != "main" ]; then
      git -C package/custom/openwrt-passwall fetch --depth=1 origin "$PASSWALL_LUCI_REF"
      git -C package/custom/openwrt-passwall checkout --detach "$PASSWALL_LUCI_REF"
    fi
    if [ "$PASSWALL_PACKAGES_REF" != "main" ]; then
      git -C package/custom/passwall-packages fetch --depth=1 origin "$PASSWALL_PACKAGES_REF"
      git -C package/custom/passwall-packages checkout --detach "$PASSWALL_PACKAGES_REF"
    fi

    cp -rf package/custom/openwrt-passwall/luci-app-passwall package/custom/
    rm -rf package/custom/passwall-packages/.git*
    cp -rf package/custom/passwall-packages/* package/custom/
    rm -rf package/custom/openwrt-passwall package/custom/passwall-packages

    # Remove duplicated package names from feeds to avoid selecting stale feed variants.
    for pkg_path in package/custom/*; do
      [ -d "$pkg_path" ] || continue
      pkg_name="$(basename "$pkg_path")"
      while IFS= read -r old_path; do
        rm -rf "$old_path"
      done < <(find feeds -type d -name "$pkg_name")
    done

    # Explicitly remove passwall variants from luci feed if still present.
    rm -rf feeds/luci/applications/luci-app-passwall feeds/luci/applications/luci-app-passwall2
    ;;

  post)
    # Modify default IP
    cfg_file="package/base-files/files/bin/config_generate"
    if [ -f "$cfg_file" ]; then
      sed -i 's/192\.168\.1\.1/192.168.31.1/g' "$cfg_file"
    else
      echo "Missing file: $cfg_file" >&2
      exit 1
    fi

    # Modify default theme
    #sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

    # Modify hostname
    #sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
    ;;

  *)
    echo "Unknown stage: $STAGE (expected: pre|feeds|post)" >&2
    exit 1
    ;;
esac
