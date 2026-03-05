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
    # Add PassWall feeds (official org, latest version with SingBox support)
    echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" >> feeds.conf.default
    echo "src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main" >> feeds.conf.default
    ;;

  feeds)
    # Replace legacy golang feed with newer toolchain packages for SingBox/Xray builds.
    GOLANG_FEED_REF="${GOLANG_FEED_REF:-5c14cc148c88b42ea36e8c42733c80acd2ee1949}"
    rm -rf feeds/packages/lang/golang
    git clone --filter=blob:none --depth=1 --single-branch \
      https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang
    git -C feeds/packages/lang/golang fetch --depth=1 origin "$GOLANG_FEED_REF"
    git -C feeds/packages/lang/golang checkout --detach "$GOLANG_FEED_REF"

    # Avoid feed conflict: force luci-app-passwall from passwall_luci feed.
    rm -rf feeds/luci/applications/luci-app-passwall
    rm -rf feeds/luci/applications/luci-app-passwall2
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
