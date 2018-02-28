##dns服务器
安装dnsmasq <br>

    rpm -ivh dnsmasq-2.66-21.el7.x86_64.rpm

修改系统配置文件

    echo 'nameserver 127.0.0.1' > /etc/resolv.conf
    cp /etc/resolv.conf /etc/resolv.dnsmasq.conf
    echo 'nameserver 8.8.8.8' >> /etc/resolv.dnsmasq.conf
    echo 'nameserver 202.106.0.20' >> /etc/resolv.dnsmasq.conf
    cp /etc/hosts /etc/dnsmasq.hosts
    chmod 664 resolv.dnsmasq.conf
    chmod 755 dnsmasq.hosts

dnsmasq配置

    cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak #先做个备份
    echo 'resolv-file=/etc/resolv.dnsmasq.conf' >> /etc/dnsmasq.conf
    echo 'addn-hosts=/etc/dnsmasq.hosts' >> /etc/dnsmasq.conf

由于此次安装dns服务器与私有镜像库在同一台机器，iptables服务是启动的，需要开放53端口
>-A INPUT -p udp -m state --state NEW --dport 53 -j ACCEPT <br>
-A INPUT -p tcp -m state --state NEW --dport 53 -j ACCEPT

重启iptables服务

    service iptables restart

注：重启iptables服务时，docker会重启，查看一下私有镜像库是否停止，停止需要手动启动一下

    docker ps -a
    docker start <container_id>

启动dnsmasq服务

    service iptables restart

在需要的机器上，配置/etc/resolv.conf文件

    cat /etc/resolv.conf
    nameserver 10.174.64.184

注：如果集群已经启动需要修改完/etc/resolv.conf之后重启集群。
相关资料：
http://michaelkang.blog.51cto.com/1553154/1305756