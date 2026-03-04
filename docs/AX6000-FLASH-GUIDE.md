# Redmi AX6000 刷机说明（本仓库产物）

> 适用范围：本仓库编译出的 `ubootmod` 固件。
>
> 高风险提示：刷机和分区操作有变砖风险。刷机前请确认你能进入救援模式并有回退方案。

## 1. 先识别产物文件

编译完成后常见文件：

- `...-ubootmod-squashfs-sysupgrade.itb`
- `...-ubootmod-initramfs-factory.ubi`
- `...-ubootmod-initramfs-recovery.itb`
- `...-ubootmod-preloader.bin`
- `...-ubootmod-bl31-uboot.fip`

用途说明：

- `sysupgrade.itb`：已在 OpenWrt/ImmortalWrt 上时的日常升级包。
- `initramfs-factory.ubi`：首次写入 `ubootmod` 体系时使用（需匹配正确流程）。
- `initramfs-recovery.itb`：救援/临时启动用途，不是日常升级包。
- `preloader.bin`、`bl31-uboot.fip`：底层引导组件，**不要在日常升级中刷写**。

## 2. 你现在是原厂系统时该怎么选

你是“原厂准备刷入”，优先结论：

- 目标写入包：`...-ubootmod-initramfs-factory.ubi`
- 后续升级包：`...-ubootmod-squashfs-sysupgrade.itb`

## 3. 原厂首刷建议

由于本仓库当前只编译 `ubootmod` 目标，不包含 stock-layout 目标，实际首刷方式强依赖你采用的入口（例如：SSH 注入、Breed/U-Boot、救援、串口）。

请务必遵循你正在使用的那条入口教程，不要混用步骤。尤其是：

- 不要把 `sysupgrade.itb` 当作首次写入包。
- 不要在未确认分区/流程时刷 `preloader.bin`、`bl31-uboot.fip`。

## 4. 成功进入 ImmortalWrt 后的升级方法

### LuCI 升级

系统 -> 备份/升级 -> 刷写新固件，选择：

- `...-ubootmod-squashfs-sysupgrade.itb`

### SSH 升级

```sh
scp immortalwrt-...-ubootmod-squashfs-sysupgrade.itb root@192.168.31.1:/tmp/
ssh root@192.168.31.1
sysupgrade /tmp/immortalwrt-...-ubootmod-squashfs-sysupgrade.itb
```

若你要清空配置再升级，可改用：

```sh
sysupgrade -n /tmp/immortalwrt-...-ubootmod-squashfs-sysupgrade.itb
```

## 5. 默认信息

- 默认管理地址：`http://192.168.31.1`
- 默认用户名：`root`

## 6. 参考资料（建议先看）

- OpenWrt Redmi AX6000 设备页（含分区/升级注意事项）
  - https://openwrt.org/toh/xiaomi/redmi_ax6000
- ImmortalWrt 官方仓库
  - https://github.com/immortalwrt/immortalwrt
