##zookeeper集群安装
zookeeper部署 <br>
1.下载zookeeper包
http://mirrors.hust.edu.cn/apache/zookeeper/
2.在zk主机上解压压缩包在相同的路径
3.编辑zk的配置文件

    vi conf/zoo.cfg

>tickTime=2000 <br>
initLimit=10 <br>
syncLimit=5 <br>
datalogdir=/data/data1/data/ <br>
dataDir=/data/data1/data/zookeeper <br>
clientPort=2181 <br>
server.1=10.174.64.179:2888:3888 <br>
server.2=10.174.64.180:2888:3888 <br>
server.3=10.174.64.181:2888:3888 <br>

4.创建dataDir目录,并创建myid文件，文件内容为server.x的x

    cat /data/data1/data/zookeeper/myid

5.由于zk起在master上，iptables是打开的，需要修改/etc/sysconfig/iptables

>-A INPUT -p udp -m state --state NEW --dport 2888 -j ACCEPT <br>
-A INPUT -p tcp -m state --state NEW --dport 2888 -j ACCEPT <br>
-A INPUT -p udp -m state --state NEW --dport 3888 -j ACCEPT <br>
-A INPUT -p tcp -m state --state NEW --dport 3888 -j ACCEPT <br>
-A INPUT -p udp -m state --state NEW --dport 2181 -j ACCEPT <br>
-A INPUT -p tcp -m state --state NEW --dport 2181 -j ACCEPT <br>

重启iptables服务

    systemctl restart iptables 

6.所有机器启动zk服务

    cd zookeeper-3.4.10/bin
    ./zkServer.sh start
    ./zkServer.sh restart
    ./zkServer.sh status
成功显示：
Mode: follower/leader

相关资料：
http://blog.csdn.net/lihao21/article/details/51778255