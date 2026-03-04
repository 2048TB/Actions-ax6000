# Redmi AX6000 ImmortalWrt 自动编译

本仓库用于编译 `ImmortalWrt openwrt-24.10` 的 `xiaomi_redmi-router-ax6000-stock` 固件。

## 入口

- 刷机文档：`docs/AX6000-FLASH-GUIDE.md`

## 当前构建特点

- 目标机型：`mediatek/filogic` + `xiaomi_redmi-router-ax6000-stock`
- 发布策略：`bin-only`（Release 仅上传 `*sysupgrade.bin`）
- 默认管理地址：`192.168.31.1`
- PassWall：已精简为 `VLESS` 最小可用（`SingBox` + `V2ray_Geodata`）

## 为什么别人常见是 `.bin`

- 关键差异是 `target device`，不是 GitHub Actions 模板本身。
- `stock` 目标通常生成 `sysupgrade.bin`。
- `ubootmod` 目标会生成 `itb/ubi`（例如 `sysupgrade.itb`、`initramfs-factory.ubi`）。
