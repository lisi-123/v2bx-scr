# v2bx自动化部署

执行安装脚本：

```bash
apt-get install wget -y && wget -O setup.sh https://raw.githubusercontent.com/lisi-123/v2bx-scr/main/setup.sh && chmod +x setup.sh && ./setup.sh

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
