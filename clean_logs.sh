#!/bin/bash

# 清空所有 .log 文件
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

# 删除所有旧日志（.gz、.1、.old 等）
find /var/log -type f \( -name "*.gz" -o -name "*.1" -o -name "*.old" \) -delete

# 删除 systemd 日志（不保留任何日志）
journalctl --rotate
journalctl --vacuum-time=1s

# 删除临时文件
rm -rf /tmp/*
rm -rf /var/tmp/*
