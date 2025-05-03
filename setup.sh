#!/bin/bash

# 更新软件包列表
apt-get update

# 安装必需的软件包
apt install sudo -y
sudo apt install git -y
sudo apt install curl -y
sudo apt install nano -y

# 拉取库
until git clone https://github.com/lisi-123/v2bx-scr.git; do
  echo "git clone 失败，3 秒后重试..."; sleep 3;
done

# 赋予 socks5-check.sh 可执行权限
chmod +x /root/v2bx-scr/socks5-check.sh

# 安装 iptables-persistent（自动回答“是”）
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent

# 添加规则（UDP 35000-36000 转发到 50000）
sudo iptables -t nat -A PREROUTING -p udp --dport 35000:36000 -j REDIRECT --to-port 50000

# 保存规则
mkdir -p /etc/iptables
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6

# 执行其他安装指令
wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh && bash install.sh v0.1.10

# 修改为上海时区
sudo timedatectl set-timezone Asia/Shanghai

# 安装warp并设置本地socks5代理
wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh <<< $'2\n5\n1\n1\n40000\n'

# 添加定时任务（凌晨4点自动重启v2bx，每分钟检测warp状态）
CRON_JOB1='0 4 * * * /usr/bin/v2bx restart'
CRON_JOB2='* * * * * /root/v2bx-scr/socks5-check.sh'

# 将任务添加到 crontab 并避免重复
(crontab -l 2>/dev/null; echo "$CRON_JOB1"; echo "$CRON_JOB2") | sort -u | crontab -


# 替换路由文件
sudo cp -f /root/v2bx-scr/route.json /etc/V2bX/
sudo cp -f /root/v2bx-scr/custom_outbound.json /etc/V2bX/
sudo cp -f /root/v2bx-scr/sing_origin.json /etc/V2bX/

V2bX restart

# 输出完成信息
echo "NodeID 已更新成功！已自动配置warp解锁，v2bx已启动"
