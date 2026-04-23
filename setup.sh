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
chmod +x /root/v2bx-scr/socks5-check.sh
chmod +x /root/v2bx-scr/clean_logs.sh

# 检测并添加虚拟内存
chmod +x /root/v2bx-scr/swap.sh && /root/v2bx-scr/swap.sh

# 网络调优
CONF="/etc/sysctl.conf"

# 删除旧配置
sed -i '
/net.core.default_qdisc/d
/net.ipv4.tcp_congestion_control/d
/net.ipv4.tcp_ecn/d
/net.ipv4.tcp_fastopen/d
/net.ipv4.tcp_mtu_probing/d
/net.ipv4.tcp_notsent_lowat/d
/net.ipv4.tcp_limit_output_bytes/d
/net.ipv4.tcp_sack/d
/net.ipv4.tcp_timestamps/d
/net.ipv4.tcp_window_scaling/d
' "$CONF"

# 写入新配置
cat >> "$CONF" << 'EOF'

# BBR 优化
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# TCP 队列
net.core.somaxconn = 4096

# TCP 优化
net.ipv4.tcp_ecn=0
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_mtu_probing=0

EOF

# 应用配置
sysctl --system


# 安装v2bx
wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh && bash install.sh v0.3.5

# 修改为上海时区
sudo timedatectl set-timezone Asia/Shanghai

# 安装warp并设置本地socks5代理
wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh <<< $'2\n5\n1\n1\n40000\n'

# 限制warp内存占用
sudo mkdir -p /etc/systemd/system/warp-svc.service.d && echo -e "[Service]\nMemoryMax=150M" | sudo tee /etc/systemd/system/warp-svc.service.d/override.conf
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart warp-svc

# 添加定时任务（凌晨4点自动重启v2bx，每分钟检测warp状态，自动清理vps日志，凌晨4:30重启warp-svc）
CRON_JOB1='0 4 * * * /usr/bin/v2bx restart'
CRON_JOB2='*/2 * * * * /root/v2bx-scr/socks5-check.sh'
CRON_JOB3='0 5 * * * /root/v2bx-scr/clean_logs.sh'
CRON_JOB4='30 4 * * * systemctl restart warp-svc'

# 将任务添加到 crontab 并避免重复
(crontab -l 2>/dev/null; echo "$CRON_JOB1"; echo "$CRON_JOB2"; echo "$CRON_JOB3"; echo "$CRON_JOB4") | sort -u | crontab -

# 替换路由文件
cp -f /root/v2bx-scr/route.json /etc/V2bX/
cp -f /root/v2bx-scr/custom_outbound.json /etc/V2bX/
cp -f /root/v2bx-scr/sing_origin.json /etc/V2bX/
cp -f /root/v2bx-scr/hy2config.yaml /etc/V2bX/

V2bX restart

# 输出完成信息
echo "NodeID 已更新成功！已自动配置warp解锁，v2bx已启动"
