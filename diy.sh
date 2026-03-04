#!/bin/bash
#
# Merged DIY script for OpenWrt build pipeline.
# Usage:
#   ./diy.sh pre   # before feeds update/install
#   ./diy.sh post  # after feeds install, before build
#

set -euo pipefail

STAGE="${1:-pre}"

case "$STAGE" in
  pre)
    # Keep official feeds only by default.
    # Add extra feeds here if needed.
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
    echo "Unknown stage: $STAGE (expected: pre|post)" >&2
    exit 1
    ;;
esac
