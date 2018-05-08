# dns服务器搭建

## 安装服务
```
yum install dnsmasq
```

## 添加解析域名

```
echo "address=/xxx.com/10.1.1.x" > /etc/dnsmasq.d/address.conf

service iptables restart
```

## 客户端配置
```
echo "nameserver 10.1.1.x" >> /etc/resolv.conf
```