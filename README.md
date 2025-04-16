# v2bx自动化部署

执行安装脚本：

```bash
apt-get install wget -y && wget -O setup.sh https://raw.githubusercontent.com/lisi-123/v2bx-scr/main/setup.sh && chmod +x setup.sh && ./setup.sh

```

<br>

### 说明

+ 脚本自带端口映射：UDP 35000-36000 转发到 50000

+ warp默认ipv4优先，如果需要ipv6优先

  &nbsp;&nbsp;&nbsp;修改 /etc/V2bX/config.json 中的SendIP为
  
```bash
"SendIP": "::",
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
