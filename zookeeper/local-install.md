# zookeeper集群安装

## 下载zookeeper包
http://mirrors.hust.edu.cn/apache/zookeeper/

*在zk主机上解压压缩包在相同的路径*

## 编辑zk的配置文件
```
vi conf/zoo.cfg
```
```
tickTime=2000
initLimit=10
syncLimit=5
datalogdir=/data/data1/data/
dataDir=/data/data1/data/zookeeper
clientPort=2181
server.1=10.174.64.179:2888:3888
server.2=10.174.64.180:2888:3888
server.3=10.174.64.181:2888:3888
```


## 创建dataDir目录,并创建myid文件，文件内容为server.x的x
```
cat /data/data1/data/zookeeper/myid
```

## 所有机器启动zk服务
```
cd zookeeper-3.4.10/bin
./zkServer.sh start
./zkServer.sh restart
./zkServer.sh status


成功显示：
Mode: follower/leader
```


## 防火墙需要开放的端口

```
-A INPUT -p udp -m state --state NEW --dport 2888 -j ACCEPT
-A INPUT -p tcp -m state --state NEW --dport 2888 -j ACCEPT
-A INPUT -p udp -m state --state NEW --dport 3888 -j ACCEPT
-A INPUT -p tcp -m state --state NEW --dport 3888 -j ACCEPT
-A INPUT -p udp -m state --state NEW --dport 2181 -j ACCEPT
-A INPUT -p tcp -m state --state NEW --dport 2181 -j ACCEPT
```

参考资料：
http://blog.csdn.net/lihao21/article/details/51778255