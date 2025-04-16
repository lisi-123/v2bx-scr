# v2bx自动化部署

拉取库

```bash
apt-get update
apt install sudo -y
sudo apt install git -y

git clone https://github.com/lisi-123/v2bx-scr.git

```


您可以通过以下命令一键下载并执行安装脚本：

```bash
sudo chmod +x /root/v2bx-scr/setup.sh && sudo /root/v2bx-scr/setup.sh

```


<br>

## 临时禁用ipv6
当vps同时存在v4和v6,且v6优先时候，可能会导致安装脚本出问题

执行以下脚本可临时禁用ipv6，重启vps即可恢复

```bash
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
```

<br>


xiao佬的v2bx: https://github.com/wyx2685/V2bX


<br>
