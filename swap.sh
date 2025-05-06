#!/bin/bash

# 检查是否存在 Swap
if free | awk '/Swap:/ {exit !$2}'; then
    echo "已存在 Swap，无需添加。"
else
    echo "未检测到 Swap，正在添加 1G Swap..."

    # 创建 Swap 文件
    fallocate -l 1G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=1024

    # 设置权限
    chmod 600 /swapfile

    # 设置为 Swap 格式
    mkswap /swapfile

    # 启用 Swap
    swapon /swapfile

    # 写入 fstab，开机自动挂载
    if ! grep -q '/swapfile' /etc/fstab; then
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi

    echo "1G Swap 添加完成。"
fi
