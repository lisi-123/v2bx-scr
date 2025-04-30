#!/bin/bash

# 检查架构并选择相应的安装方式
cpu_arch=$(uname -m)
if [ "$cpu_arch" = "aarch64" ]; then
    # ARM架构，使用bbrv3arm.sh
    bash <(curl -sL jhb.ovh/jb/bbrv3arm.sh)
    exit 0
fi

# 检查物理内存是否大于 512GB，如果小于且没有虚拟内存则添加 1GB 交换空间
check_memory() {
    total_memory=$(free -g | grep Mem: | awk '{print $2}')
    swap_memory=$(free -g | grep Swap: | awk '{print $2}')
    
    # 如果物理内存小于512GB，且没有启用交换空间，则添加1GB交换空间
    if [ "$total_memory" -lt 512 ] && [ "$swap_memory" -eq 0 ]; then
        echo "物理内存小于 512GB 且没有虚拟内存，自动添加 1GB 虚拟内存..."
        # 创建 1GB 的交换文件
        sudo fallocate -l 1G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        # 将交换文件永久添加到 /etc/fstab
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    fi
}

# 检查是否安装了xanmod内核
if dpkg -l | grep -q 'linux-xanmod'; then
    # 如果已安装xanmod内核，执行更新或卸载操作
    echo "您已安装xanmod的BBRv3内核"
    kernel_version=$(uname -r)
    echo "当前内核版本: $kernel_version"
    
    # 卸载当前的xanmod内核并更新GRUB
    apt purge -y 'linux-*xanmod1*'
    update-grub

    # 下载并添加xanmod仓库的公钥
    wget -qO - ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes

    # 添加xanmod存储库
    echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

    # 获取适配的内核版本并安装
    local version=$(wget -q ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/check_x86-64-psabi.sh && chmod +x check_x86-64-psabi.sh && ./check_x86-64-psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')

    apt update -y
    apt install -y linux-xanmod-x64v$version

    echo "XanMod内核已更新。重启后生效"
    rm -f /etc/apt/sources.list.d/xanmod-release.list
    rm -f check_x86-64-psabi.sh*

    # 重启服务器
    reboot
    exit 0
fi

# 如果不是xanmod内核，执行BBRv3加速安装
echo "设置BBR3加速"
echo "视频介绍: https://www.bilibili.com/video/BV14K421x7BS?t=0.1"
echo "------------------------------------------------"
echo "仅支持Debian/Ubuntu"
echo "请备份数据，将为你升级Linux内核开启BBR3"
echo "------------------------------------------------"

# 检查操作系统类型
if [ -r /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "debian" ] && [ "$ID" != "ubuntu" ]; then
        echo "当前环境不支持，仅支持Debian和Ubuntu系统"
        exit 1
    fi
else
    echo "无法确定操作系统类型"
    exit 1
fi

# 检查内存并添加虚拟内存（如果需要）
check_memory

# 检查交换空间并安装必要的工具
check_swap
install wget gnupg

# 下载并添加xanmod仓库的公钥
wget -qO - ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/archive.key | gpg --dearmor -o /usr/share/keyrings/xanmod-archive-keyring.gpg --yes

# 添加xanmod仓库
echo 'deb [signed-by=/usr/share/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list

# 获取适配的内核版本并安装
local version=$(wget -q ${gh_proxy}raw.githubusercontent.com/kejilion/sh/main/check_x86-64-psabi.sh && chmod +x check_x86-64-psabi.sh && ./check_x86-64-psabi.sh | grep -oP 'x86-64-v\K\d+|x86-64-v\d+')

apt update -y
apt install -y linux-xanmod-x64v$version

# 启用BBR3
bbr_on

echo "XanMod内核安装并BBR3启用成功。重启后生效"
rm -f /etc/apt/sources.list.d/xanmod-release.list
rm -f check_x86-64-psabi.sh*

# 重启服务器
reboot
