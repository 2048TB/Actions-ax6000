# Redmi AX6000 刷机说明（本仓库产物）

> 适用范围：本仓库当前默认编译 `stock` 布局（`xiaomi_redmi-router-ax6000-stock`）。
>
> 高风险提示：刷机有变砖风险。操作前请确认你有回退方案。

## 1. 你会看到哪些产物

本仓库的 Release 默认只上传：

- `...-stock-squashfs-sysupgrade.bin`

说明：

- `sysupgrade.bin`：当前默认的升级/刷写主文件。
- Actions 构建目录里仍可能出现 `manifest`、`sha256sums` 等辅助文件，这是正常现象。

## 2. 为什么别人常见 `.bin`，你之前是 `itb/ubi`

核心区别是目标机型配置：

- `stock` 目标（本仓库当前默认）通常对应 `sysupgrade.bin`。
- `ubootmod` 目标通常对应 `sysupgrade.itb`、`initramfs-factory.ubi` 等多种格式。

也就是说，差异来自 `target device/layout`，不是 CI 模板本身。

## 3. 升级方法（当前默认产物）

### LuCI 升级

系统 -> 备份/升级 -> 刷写新固件，选择：

- `...-stock-squashfs-sysupgrade.bin`

### SSH 升级

```sh
scp immortalwrt-...-stock-squashfs-sysupgrade.bin root@192.168.31.1:/tmp/
ssh root@192.168.31.1
sysupgrade /tmp/immortalwrt-...-stock-squashfs-sysupgrade.bin
```

清空配置升级：

```sh
sysupgrade -n /tmp/immortalwrt-...-stock-squashfs-sysupgrade.bin
```

## 4. 如果你仍要 `ubootmod` 格式

需要把目标改回：

- `.config` 中 `CONFIG_TARGET_mediatek_filogic_DEVICE_xiaomi_redmi-router-ax6000-ubootmod=y`
- 同步调整 workflow 的 `required_symbols` 校验
- Release 上传规则从 `*sysupgrade.bin` 改回你需要的模式（如 `*` 或 `*sysupgrade.itb`）

## 5. 默认信息

- 默认管理地址：`http://192.168.31.1`
- 默认用户名：`root`

## 6. 参考资料

- OpenWrt Redmi AX6000 设备页
  - https://openwrt.org/toh/xiaomi/redmi_ax6000
- ImmortalWrt 官方仓库
  - https://github.com/immortalwrt/immortalwrt
