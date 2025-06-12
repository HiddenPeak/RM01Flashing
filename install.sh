#!/bin/bash

# RM01 设备 Jetson Orin 刷机文件安装脚本
# 版本: 1.1
# 日期: 2025年6月12日

set -e  # 遇到错误时退出

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印彩色输出
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "检测到以 root 用户运行，建议使用普通用户运行此脚本"
        read -p "继续执行? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 检查环境变量
check_environment() {
    print_status "检查环境变量..."
    
    # 如果未设置 L4T_DIR，使用默认路径
    if [ -z "$L4T_DIR" ]; then
        L4T_DIR="/home/rm01/nvidia/nvidia_sdk/JetPack_6.2_Linux_JETSON_AGX_ORIN_TARGETS/Linux_for_Tegra"
        print_warning "L4T_DIR 环境变量未设置，使用默认路径: $L4T_DIR"
        export L4T_DIR
    fi
    
    if [ ! -d "$L4T_DIR" ]; then
        print_error "L4T 目录不存在: $L4T_DIR"
        echo "请确认 NVIDIA JetPack SDK 已正确安装"
        exit 1
    fi
    
    print_success "环境变量检查通过: L4T_DIR=$L4T_DIR"
}

# 检查必需文件
check_required_files() {
    print_status "检查必需文件..."
    
    local files=(
        "$SCRIPT_DIR/rm01-orin.conf"
        "$SCRIPT_DIR/bootloader/tegra234-mb2-bct-common.dtsi"
        "$SCRIPT_DIR/kernel/tegra234-rm01+p3701-0005-nv.dts"
        "$SCRIPT_DIR/kernel/dtb/tegra234-rm01+p3701-0005-nv-withoutCamera.dtb"
    )
    
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "必需文件缺失: $file"
            print_error "请确保脚本位于 RM01Flashing 项目目录中"
            exit 1
        fi
    done
    
    print_success "所有必需文件检查通过"
    print_status "项目目录: $SCRIPT_DIR"
}

# 创建备份
create_backup() {
    print_status "创建备份文件..."
    
    local backup_dir="$L4T_DIR/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # 备份可能被覆盖的文件
    if [ -f "$L4T_DIR/bootloader/tegra234-mb2-bct-common.dtsi" ]; then
        cp "$L4T_DIR/bootloader/tegra234-mb2-bct-common.dtsi" "$backup_dir/"
        print_success "已备份: bootloader/tegra234-mb2-bct-common.dtsi"
    fi
    
    if [ -f "$L4T_DIR/kernel/tegra234-rm01+p3701-0005-nv.dts" ]; then
        cp "$L4T_DIR/kernel/tegra234-rm01+p3701-0005-nv.dts" "$backup_dir/"
        print_success "已备份: kernel/tegra234-rm01+p3701-0005-nv.dts"
    fi
    
    if [ -f "$L4T_DIR/kernel/dtb/tegra234-rm01+p3701-0005-nv-withoutCamera.dtb" ]; then
        cp "$L4T_DIR/kernel/dtb/tegra234-rm01+p3701-0005-nv-withoutCamera.dtb" "$backup_dir/"
        print_success "已备份: kernel/dtb/tegra234-rm01+p3701-0005-nv-withoutCamera.dtb"
    fi
    
    echo "备份目录: $backup_dir"
}

# 安装文件
install_files() {
    print_status "开始安装 RM01 文件..."
    
    # 复制配置文件
    print_status "复制配置文件..."
    cp "$SCRIPT_DIR/rm01-orin.conf" "$L4T_DIR/"
    print_success "已复制: rm01-orin.conf"
    
    # 复制 bootloader 文件
    print_status "复制 bootloader 文件..."
    cp "$SCRIPT_DIR/bootloader/tegra234-mb2-bct-common.dtsi" "$L4T_DIR/bootloader/"
    print_success "已复制: bootloader/tegra234-mb2-bct-common.dtsi"
    
    # 复制设备树文件
    print_status "复制设备树文件..."
    mkdir -p "$L4T_DIR/kernel/dtb"
    cp "$SCRIPT_DIR/kernel/tegra234-rm01+p3701-0005-nv.dts" "$L4T_DIR/kernel/"
    cp "$SCRIPT_DIR/kernel/dtb/tegra234-rm01+p3701-0005-nv-withoutCamera.dtb" "$L4T_DIR/kernel/dtb/"
    print_success "已复制: kernel/tegra234-rm01+p3701-0005-nv.dts"
    print_success "已复制: kernel/dtb/tegra234-rm01+p3701-0005-nv-withoutCamera.dtb"
}
    print_success "已复制: kernel/dtb/tegra234-rm01+p3701-0005-nv-withoutCamera.dtb"
}

# 验证安装
verify_installation() {
    print_status "验证安装..."
    
    local files=(
        "$L4T_DIR/rm01-orin.conf"
        "$L4T_DIR/bootloader/tegra234-mb2-bct-common.dtsi"
        "$L4T_DIR/kernel/tegra234-rm01+p3701-0005-nv.dts"
        "$L4T_DIR/kernel/dtb/tegra234-rm01+p3701-0005-nv-withoutCamera.dtb"
    )
    
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "安装验证失败: $file 不存在"
            exit 1
        fi
    done
    
    print_success "安装验证通过"
}

# 显示刷机命令
show_flash_commands() {
    print_status "显示刷机命令..."
    
    echo ""
    echo "============================================"
    echo "安装完成！现在您可以使用以下命令进行刷机："
    echo "============================================"
    echo ""
    echo "1. 进入 L4T 目录："
    echo "   cd $L4T_DIR"
    echo ""
    echo "2. 确保设备处于恢复模式并连接到主机"
    echo ""
    echo "3. 执行刷机命令："
    echo "   sudo ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1p1 \\"
    echo "     -c tools/kernel_flash/flash_l4t_external.xml \\"
    echo "     -p \"-c bootloader/t186ref/cfg/flash_t234_qspi.xml\" \\"
    echo "     --showlogs --network usb0 rm01-orin internal"
    echo ""
    echo "============================================"
    echo ""
}

# 主函数
main() {
    echo "============================================"
    echo "RM01 设备 Jetson Orin 刷机文件安装脚本"
    echo "版本: 1.0"
    echo "============================================"
    echo ""
    
    check_root
    check_environment
    check_required_files
    
    echo ""
    read -p "是否继续安装? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "安装已取消"
        exit 0
    fi
    
    create_backup
    install_files
    verify_installation
    show_flash_commands
    
    print_success "RM01 文件安装完成！"
}

# 执行主函数
main "$@"
