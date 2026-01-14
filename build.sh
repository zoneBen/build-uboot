#!/bin/bash
# 本地构建脚本 (可选)

set -e

echo "开始构建 CMT Cube RK3288 U-Boot..."

# 检查是否已安装必要工具
command -v arm-linux-gnueabihf-gcc >/dev/null 2>&1 || { echo "错误: 未找到 arm-linux-gnueabihf-gcc"; exit 1; }
command -v dtc >/dev/null 2>&1 || { echo "错误: 未找到 dtc (device tree compiler)"; exit 1; }

# 克隆 U-Boot 源码
if [ ! -d "u-boot" ]; then
    echo "克隆 U-Boot 源码..."
    git clone https://github.com/u-boot/u-boot.git
fi

cd u-boot

# 复制自定义配置和设备树
cp ../configs/cmt_cube_rk3288_defconfig configs/
cp ../arch/arm/dts/rk3288-cmt-cube.dts arch/arm/dts/

# 设置环境变量
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

# 配置和构建
make cmt_cube_rk3288_defconfig
make -j$(nproc)

echo "构建完成!"

# 打包 idbloader.img
if [ -f spl/u-boot-spl.bin ]; then
    ./tools/mkimage -n rk3288 -T rksd -d spl/u-boot-spl.bin idbloader.img
    echo "idbloader.img 创建成功"
else
    echo "警告: SPL 文件不存在，可能未启用 CONFIG_SPL"
fi

# 创建 boot.img
if [ -f u-boot.itb ]; then
    cp u-boot.itb boot.img
    echo "boot.img 创建成功 (使用 FIT image)"
elif [ -f u-boot-dtb.bin ]; then
    cp u-boot-dtb.bin boot.img
    echo "boot.img 创建成功 (使用传统方式)"
else
    echo "警告: 未找到 u-boot.itb 或 u-boot-dtb.bin"
fi

# 合并生成完整镜像
if [ -f idbloader.img ] && [ -f boot.img ]; then
    # 创建完整的合并镜像
    dd if=/dev/zero of=full.bin bs=512 count=64
    dd if=idbloader.img of=full.bin conv=notrunc
    dd if=boot.img of=full.bin bs=512 seek=64
    echo "完整镜像 full.bin 创建成功"
    echo "可通过以下命令写入SD卡或eMMC:"
    echo "sudo dd if=full.bin of=/dev/sdX bs=512"
    echo "sync"
fi

echo "构建过程完成!"