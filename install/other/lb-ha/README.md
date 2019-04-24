# lb 高可用配置

## 安装haproxy,keepalived
```
yum install haproxy keeyalived
```

## 配置haproxy,keepalived文件
两个主机配置相同的haproxy，一台主机用keepalived.conf-master,另一台用keepalived.conf-salve

## 配置启动脚本
1.添加脚本文件keepalive启动脚本start-keepalived.sh
2.配置crontab
```
执行crontab -e，添加：
##DF: auto start keepalived after haproxy started.
#* * * * * /home/aisware/bin/start-keepalived.sh & >>/home/aisware/log.txt  2>&1

* * * * * /home/aisware/bin/start-keepalived.sh & >/dev/null
```


## 启动服务
```
systemctl enable haproxy keepalive
systemctl start haproxy keepalive
```



## ansible hosts文件配置lb

```

[OSEv3:vars]
...
# Native HA with External LB VIPs
openshift_master_cluster_method=native
openshift_master_cluster_hostname=<VIP>
openshift_master_cluster_public_hostname=<VIP>

```
hosts里面不要 添加[lb模块],lb模块的haproxy已经启动了，直接配置使用vip即可.
