#!/bin/bash

# 更新软件包列表
apt-get update

# 安装必需的软件包
apt install sudo -y
apt install wget -y
sudo apt install curl -y
sudo apt install nano -y


# 安装 iptables-persistent（自动回答“是”）
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent

# 添加规则（UDP 35000-36000 转发到 50000）
sudo iptables -t nat -A PREROUTING -p udp --dport 35000:36000 -j REDIRECT --to-port 50000

# 保存 IPv4 规则
sudo iptables-save > /etc/iptables/rules.v4

# 保存 IPv6 规则
sudo ip6tables-save > /etc/iptables/rules.v6


# 执行其他安装指令
wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh && bash install.sh v0.1.10

# 修改为上海时区
sudo timedatectl set-timezone Asia/Shanghai

# 添加定时任务（凌晨4点自动重启v2bx）
CRON_JOB='0 4 * * * /usr/bin/v2bx restart'
(crontab -l 2>/dev/null; echo "$CRON_JOB") | sort -u | crontab -

# 先下载并执行 menu.sh 脚本
wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh <<< $'2\n13\n40000\n1\n'

# 替换路由文件
sudo cp -f /root/v2bx-scr/route.json /etc/V2bX/
sudo cp -f /root/v2bx-scr/custom_outbound.json /etc/V2bX/
sudo cp -f /root/v2bx-scr/sing_origin.json /etc/V2bX/

V2bX restart

# 输出完成信息
echo "NodeID 已更新成功！已自动配置warp解锁，v2bx已启动"
