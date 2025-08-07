#!/bin/bash

# 更新软件包列表
apt-get update

# 安装必需的软件包
apt install sudo -y
sudo apt install git -y
sudo apt install curl -y
sudo apt install nano -y
sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent

# 拉取库
until git clone https://github.com/lisi-123/v2bx-scr.git; do
  echo "git clone 失败，3 秒后重试..."; sleep 3;
done

# 赋予可执行权限
chmod +x /root/v2bx-scr/clean_logs.sh

# 检测并添加虚拟内存
chmod +x /root/v2bx-scr/swap.sh && /root/v2bx-scr/swap.sh

# 安装 iptables-persistent（自动回答“是”）
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent

# 添加规则（UDP 35000-36000 转发到 50000）
sudo iptables -t nat -A PREROUTING -p udp --dport 35000:36000 -j REDIRECT --to-port 50000

# 保存规则
mkdir -p /etc/iptables
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6

# 安装v2bx
wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh && bash install.sh v0.2.2

# 修改为上海时区
sudo timedatectl set-timezone Asia/Shanghai

# 添加定时任务（凌晨4点自动重启v2bx，每分钟检测warp状态，自动清理vps日志）
CRON_JOB1='0 4 * * * /usr/bin/v2bx restart'
CRON_JOB3='0 5 * * * /root/v2bx-scr/clean_logs.sh'

# 将任务添加到 crontab 并避免重复
(crontab -l 2>/dev/null; echo "$CRON_JOB1"; echo "$CRON_JOB2"; echo "$CRON_JOB3") | sort -u | crontab -

V2bX restart

# 输出完成信息
echo "NodeID 已成功安装v2bx！"
