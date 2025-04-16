#!/bin/bash

# 检查本地 SOCKS5 是否可用，最大重试3次
check_socks5() {
    for i in {1..3}; do
        if curl -s --socks5-hostname 127.0.0.1:40000 --max-time 5 https://1.1.1.1 >/dev/null; then
            return 0  # 成功
        fi
        sleep 1
    done
    return 1  # 失败
}

if check_socks5; then
    echo "SOCKS5 代理正常"
else
    echo "SOCKS5 代理不可用，执行 warp"
    /bin/warp y
fi
