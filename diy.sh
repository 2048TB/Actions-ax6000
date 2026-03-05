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
    # Keep stage for compatibility.
    ;;

  feeds)
    # Keep v2ray-geodata source aligned with the referenced profile.
    rm -rf feeds/packages/net/v2ray-geodata package/v2ray-geodata
    git clone --filter=blob:none --depth=1 --single-branch \
      https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

    # Align golang toolchain for PassWall/Xray packages.
    rm -rf feeds/packages/lang/golang
    git clone --filter=blob:none --depth=1 --single-branch \
      https://github.com/sbwml/packages_lang_golang -b 26.x feeds/packages/lang/golang
    ;;

  post)
    # Keep existing default LAN IP behavior from current repository.
    cfg_file="package/base-files/files/bin/config_generate"
    if [ -f "$cfg_file" ]; then
      sed -i 's/192\.168\.1\.1/192.168.31.1/g' "$cfg_file"
    else
      echo "Missing file: $cfg_file" >&2
      exit 1
    fi
    ;;

  *)
    echo "Unknown stage: $STAGE (expected: pre|feeds|post)" >&2
    exit 1
    ;;
esac
