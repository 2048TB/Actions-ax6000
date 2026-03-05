# Redmi AX6000 刷机说明

> 适用范围：本仓库编译 `hanwckf/immortalwrt-mt798x`（openwrt-21.02）的 `xiaomi_redmi-router-ax6000-stock` 固件。
>
> 高风险提示：刷机有变砖风险。操作前请确认你有回退方案。

## 1. Release 产物说明

| 文件 | 用途 | 使用场景 |
|------|------|----------|
| `*-squashfs-factory.bin` | 首次刷入 | 从小米原厂固件刷入 OpenWrt |
| `*-squashfs-sysupgrade.bin` | 系统升级 | 已有 OpenWrt 时升级到新版本 |
| `*-initramfs-kernel.bin` | 救砖/恢复 | 纯内存启动，不写入闪存，断电恢复原状 |

## 2. 首次从原厂固件刷入

前提：已通过漏洞获取小米原厂固件的 SSH 访问权限。

### 方式一：直接刷入（推荐）

```sh
# 1. 上传 factory.bin 到路由器
scp immortalwrt-...-squashfs-factory.bin root@192.168.31.1:/tmp/

# 2. SSH 登录并写入
ssh root@192.168.31.1
mtd -r write /tmp/immortalwrt-...-squashfs-factory.bin firmware
```

### 方式二：通过 initramfs 中转

适用于需要先验证固件再写入的场景：

```sh
# 1. 先刷入 initramfs-kernel.bin 启动临时系统（运行在内存中）
# 2. 进入临时系统后，使用 sysupgrade 永久写入
sysupgrade /tmp/immortalwrt-...-squashfs-sysupgrade.bin
```

## 3. 升级已有 OpenWrt

### LuCI Web 升级

系统 → 备份/升级 → 刷写新固件，选择 `*-squashfs-sysupgrade.bin`。

### SSH 命令行升级

```sh
scp immortalwrt-...-squashfs-sysupgrade.bin root@192.168.31.1:/tmp/
ssh root@192.168.31.1
sysupgrade /tmp/immortalwrt-...-squashfs-sysupgrade.bin
```

清空配置升级（恢复默认设置）：

```sh
sysupgrade -n /tmp/immortalwrt-...-squashfs-sysupgrade.bin
```

## 4. 救砖/恢复

当路由器无法正常启动时，使用 `*-initramfs-kernel.bin`：

- 该文件启动一个纯内存运行的临时系统，不写入闪存
- 断电后恢复原状，可安全用于测试
- 进入临时系统后可通过 `sysupgrade` 重新刷入正常固件

## 5. 默认信息

- 默认管理地址：`http://192.168.31.1`
- 默认用户名：`root`
- 默认密码：无（空密码）

## 6. 参考资料

- [OpenWrt Redmi AX6000 设备页](https://openwrt.org/toh/xiaomi/redmi_ax6000)
- [hanwckf/immortalwrt-mt798x](https://github.com/hanwckf/immortalwrt-mt798x)（上游源码）
- [ImmortalWrt 官方仓库](https://github.com/immortalwrt/immortalwrt)
