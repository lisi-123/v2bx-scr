#!/bin/bash

# 检查本地 SOCKS5 代理是否可用（通过 curl 尝试访问bing）
if curl -s --socks5-hostname 127.0.0.1:40000 --max-time 5 https://www.bing.com >/dev/null; then
    echo "SOCKS5 代理正常"
else
    echo "SOCKS5 代理不可用，执行 warp"
    /bin/warp y
fi
