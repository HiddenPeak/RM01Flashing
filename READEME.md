# RM01 设备 Jetson Orin 刷机文件

这个仓库包含为 RM01 载板配置的 Jetson Orin 设备树文件和刷机配置文件。

## 项目结构

```
RM01Flashing/
├── README.md                    # 本文档
├── rm01-orin.conf              # RM01 载板刷机配置文件
├── install.sh                  # 自动安装脚本
├── bootloader/
│   └── tegra234-mb2-bct-common.dtsi  # MB2 BCT 通用配置文件
├── kernel/
│   ├── tegra234-rm01+p3701-0005-nv.dts  # RM01 设备树源文件
│   └── dtb/
│       └── tegra234-rm01+p3701-0005-nv-withoutCamera.dtb  # 编译后的设备树二进制文件
```

## 文件说明

### 1. 配置文件
- **rm01-orin.conf**: RM01 载板的主要配置文件，基于 P3701-0005 模块（64GB）
- **tegra234-mb2-bct-common.dtsi**: Bootloader 配置文件，包含系统启动相关设置

### 2. 设备树文件
- **tegra234-rm01+p3701-0005-nv.dts**: RM01 载板的设备树源文件
- **tegra234-rm01+p3701-0005-nv-withoutCamera.dtb**: 编译后的设备树二进制文件（不包含摄像头）

## 支持的硬件配置

- **模块**: NVIDIA Jetson Orin P3701-0005 (64GB)
- **载板**: RM01 自定义载板
- **配置**: 无摄像头版本

## 系统要求

- **操作系统**: Ubuntu 22.04 LTS (x86_64)
- **NVIDIA SDK Manager**: 需要在Ubuntu 22.04上运行
- **L4T版本**: Jetson Linux 36.3 或更新版本
- **硬件**: 足够的USB接口和可靠的USB连接
- **权限**: sudo 权限

## 前置条件

1. **安装NVIDIA SDK Manager**:
   - 仅支持在Ubuntu 22.04上运行
   - 从NVIDIA开发者网站下载并安装

2. **下载并解压L4T包**:
   ```bash
   # 下载Jetson Linux包并解压到指定目录
   # 例如: /home/user/Linux_for_Tegra
   ```

3. **设置环境变量**:
   ```bash
   export L4T_DIR=/path/to/Linux_for_Tegra
   echo 'export L4T_DIR=/path/to/Linux_for_Tegra' >> ~/.bashrc
   ```

## 安装说明

### 方法一：使用自动安装脚本（推荐）

1. 确保您的 Jetson Linux Developer Kit (L4T) 已正确安装
2. 运行安装脚本：
```bash
./install.sh
```

### 方法二：手动安装

1. **设置环境变量**：
```bash
# 设置 L4T 目录路径（根据您的实际安装路径修改）
export L4T_DIR=/path/to/Linux_for_Tegra
```

2. **备份原始文件**：
```bash
# 创建备份目录
mkdir -p $L4T_DIR/backup_$(date +%Y%m%d_%H%M%S)

# 备份可能被覆盖的文件
cp $L4T_DIR/bootloader/tegra234-mb2-bct-common.dtsi $L4T_DIR/backup_$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
```

3. **复制配置文件**：
```bash
# 复制 RM01 配置文件
cp rm01-orin.conf $L4T_DIR/

# 复制 bootloader 文件
cp bootloader/tegra234-mb2-bct-common.dtsi $L4T_DIR/bootloader/

# 复制设备树文件
cp kernel/tegra234-rm01+p3701-0005-nv.dts $L4T_DIR/kernel/
cp kernel/dtb/tegra234-rm01+p3701-0005-nv-withoutCamera.dtb $L4T_DIR/kernel/dtb/
```

4. **刷机**：
```bash
cd $L4T_DIR
sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \
  -c tools/kernel_flash/flash_l4t_external.xml \
  -p "-c bootloader/t186ref/cfg/flash_t234_qspi.xml" \
  --showlogs --network usb0 rm01-orin internal
```

## 重要注意事项

1. **环境变量**: 确保 `$L4T_DIR` 环境变量指向您的 L4T 安装目录
2. **权限**: 刷机操作需要 root 权限
3. **连接**: 确保设备正确连接并处于恢复模式
4. **备份**: 强烈建议在安装前备份原始文件

## 配置特性

- 基于 P3701-0005 模块（64GB 内存）
- 优化的设备树配置，移除不必要的摄像头支持
- 精简的 overlay 配置，仅包含核心组件
- 支持外部存储设备（NVMe）

## 故障排除

### 常见问题

1. **找不到设备树文件**
   - 确保所有文件已正确复制到 L4T 目录
   - 检查文件路径和权限

2. **刷机失败**
   - 确认设备处于恢复模式
   - 检查 USB 连接
   - 查看刷机日志获取详细错误信息

3. **启动问题**
   - 检查设备树配置是否与硬件匹配
   - 验证 bootloader 配置

## 联系信息

如有问题或需要技术支持，请联系开发团队。

## 许可证

本项目中的文件基于以下许可证：
- NVIDIA 相关文件: NVIDIA 专有许可证
- RM01 配置文件: BSD-3-Clause

---

**最后更新**: 2025年6月12日