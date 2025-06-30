#!/bin/bash

# 清空所有 .log 文件
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

# 删除压缩日志和 .1 旧日志
find /var/log -type f -name "*.gz" -delete
find /var/log -type f -name "*.1" -delete

# 控制 journal 日志占用不超过 100M
journalctl --vacuum-size=100M
