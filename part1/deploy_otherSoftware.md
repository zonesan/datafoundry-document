#相关组件安装
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

zookeeper集群安装
zookeeper部署
1.下载zookeeper包
http://mirrors.hust.edu.cn/apache/zookeeper/
2.在zk主机上解压压缩包在相同的路径
3.vi conf/zoo.cfg

tickTime=2000
initLimit=10
syncLimit=5
datalogdir=/data/data1/data/
dataDir=/data/data1/data/zookeeper
clientPort=2181
server.1=10.174.64.179:2888:3888
server.2=10.174.64.180:2888:3888
server.3=10.174.64.181:2888:3888

4.创建dataDir目录,并创建myid文件，文件内容为server.x的x
cat /data/data1/data/zookeeper/myid
1

5.由于zk起在master上，iptables是打开的，需要修改/etc/sysconfig/iptables
-A INPUT -p udp -m state --state NEW --dport 2888 -j ACCEPT
-A INPUT -p tcp -m state --state NEW --dport 2888 -j ACCEPT
-A INPUT -p udp -m state --state NEW --dport 3888 -j ACCEPT
-A INPUT -p tcp -m state --state NEW --dport 3888 -j ACCEPT
-A INPUT -p udp -m state --state NEW --dport 2181 -j ACCEPT
-A INPUT -p tcp -m state --state NEW --dport 2181 -j ACCEPT

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

glusterfs部署
建议先执行11步，准备盘需要很长时间，此过程中可以安装服务。
以下假设iptables和firewall都关闭。
解压zkgfs.tar.gz包

每台机器都安装glusterfs
解压base.tar.gz安装基础依赖包
解压glusterfs.tar，进入到解压的文件夹glusterfs，执行命令make install安装glusterfs

启动glusterfs服务
sudo systemctl start glusterd.service
sudo systemctl enable glusterd.service
添加gluster节点
gluster peer probe <each-address-of-other-glusterfs-machine>
选择一台机器安装heketi
解压heketi.tar.gz，安装heketi开头的rpm包，其他的包为依赖包，不缺少不安装
6.生成heketi的key
sudo ssh-keygen -f /etc/heketi/heketi_key -t rsa -N ''
sudo chown heketi:heketi /etc/heketi/heketi_key
7.将刚生成的key添加到其他机器的authorized_keys
cat /etc/heketi/heketi_key.pub
其他机器添加公钥
Vi /root/.ssh/authorized_keys
修改所有机器/root/.bashrc文件添加一行，因为gluster不再默认路径下
export PATH=/usr/local/openssl1.0.2a/bin:/usr/local/openssh7.2p2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin:/bin:/sbin
编辑heketi.json
sudo vi /etc/heketi/heketi.json

{
  "_port_comment": "Heketi Server Port Number",
  "port": "8080",

  "_use_auth": "Enable JWT authorization. Please enable for deployment",
  "use_auth": true,

  "_jwt": "Private keys for access",
  "jwt": {
    "_admin": "Admin has access to all APIs",
    "admin": {
      "key": "kLd834dadEsfwcv"
    },
    "_user": "",
    "user": {
      "key": "Lkj763sdedsF"
    }

  },

  "_glusterfs_comment": "GlusterFS Configuration",
  "glusterfs": {
    "_executor_comment": [
      "Execute plugin. Possible choices: mock, ssh",
      "mock: This setting is used for testing and development.",
      "      It will not send commands to any node.",
      "ssh:  This setting will notify Heketi to ssh to the nodes.",
      "      It will need the values in sshexec to be configured.",
      "kubernetes: Communicate with GlusterFS containers over",
      "            Kubernetes exec api."
    ],
    "executor": "ssh",

    "_sshexec_comment": "SSH username and private key file information",
    "sshexec": {
      "keyfile": "/etc/heketi/heketi_key",
      "user": "root",
      "port": "22",
      "fstab": "/etc/fstab"
    },

    "_db_comment": "Database file name",
    "db": "/var/lib/heketi/heketi.db",
    "brick_min_size_gb": 1,

    "_loglevel_comment": [
      "Set log level. Choices are:",
      "  none, critical, error, warning, info, debug",
      "Default is warning"
    ],
    "loglevel" : "debug"
  }
}
启动heketi服务
sudo systemctl start heketi
sudo systemctl enable heketi
挂盘
不要使用glusterfs客户端挂盘，要通过heketi来挂盘。

每个glusterfs machine上挂一快同样大小的未格式化过磁盘。
如果已经格式化过，使用下面任意一条命令重置磁盘(假设磁盘挂在/dev/vdc)：

sudo pvcreate --metadatasize=128M --dataalignment=256K /dev/vdc
sudo shred -v /dev/vdc
sudo dd if=/dev/zero of=/dev/vdc bs=1M
编辑topology.json 文件
vi /etc/heketi/topology.json 

{
    "clusters": [
        {
            "nodes": [
                {
                    "node": {
                        "hostnames": {
                            "manage": [
                                "10.247.33.84"
                            ],
                            "storage": [
                                "10.247.33.84"
                            ]
                        },
                        "zone": 1
                    },
                    "devices": [
                        "/dev/vdc"
                    ]
                },
                {
                    "node": {
                        "hostnames": {
                            "manage": [
                                "10.247.33.85"
                            ],
                            "storage": [
                                "10.247.33.85"
                            ]
                        },
                        "zone": 1
                    },
                    "devices": [
                        "/dev/vdc"
                    ]
                },
                {
                    "node": {
                        "hostnames": {
                            "manage": [
                                "10.247.33.86"
                            ],
                            "storage": [
                                "10.247.33.86"
                            ]
                        },
                        "zone": 1
                    },
                    "devices": [
                        "/dev/vdc"
                    ]
                }
            ]
        }
    ]
}

把其中的ip地址换成各个glusterfs machine的ip
第一次挂盘:
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv topology load --json=/etc/heketi/topology.json
查看结果：
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv topology info
以后也可以对每个node单独挂盘：
heketi-cli --json --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv device add	--name="/dev/vdd" --node="<node-id>"

16.创建end point

cat gluster-endpoints.yaml

apiVersion: v1
kind: Endpoints
metadata:
  name: glusterfs-cluster
subsets:
- addresses:
  - ip: 10.247.33.83
  - ip: 10.247.33.84
  - ip: 10.247.33.85
  ports:
  - port: 1
    protocol: TCP
    
# 将上面的ip换成各个glusterfs machine的ip

oc project service-brokers
oc create -f gluster-endpoints.yaml

17.运行datafoundry_volume程序

oc project datafoundry
oc new-app --name datafoundryservicevolume https://github.com/asiainfoLDP/datafoundry_volume.git#support-expand \
    -e  GLUSTER_ENDPOINTS_NAME="glusterfs-cluster" \
    \
    -e  HEKETI_HOST_ADDR="10.247.33.85" \
    -e  HEKETI_HOST_PORT="8080" \
    -e  HEKETI_USER="admin" \
    -e  HEKETI_KEY="kLd834dadEsfwcv" \
    \
    -e  DATAFOUNDRY_HOST_ADDR="10.247.33.60:8443" \
    -e  DATAFOUNDRY_ADMIN_USER="san" \
    -e  DATAFOUNDRY_ADMIN_PASS="any"

oc expose service datafoundryservicevolume

oc start-build datafoundryservicevolume
oc deploy datafoundryservicevolume --latest

启动之后，可以登到datafoundryservicevolume的pod里测试一下
（其中的Bearer token为oc whoami -t的返回结果）：

curl -i -X POST -d '{"size":1,"name":"aaa"}' -H "Authorization: Bearer q5rDX4iDIbMyda1GMtCDvI91IH7B9npkPNNvUvUEKes" http://localhost:9095/lapi/v1/namespaces/service-brokers/volumes

curl -i -X PUT -d '{"new-size":2, "old-size":1,"name":"aaa"}' -H "Authorization: Bearer q5rDX4iDIbMyda1GMtCDvI91IH7B9npkPNNvUvUEKes"  http://localhost:9095/lapi/v1/namespaces/service-brokers/volumes

curl -i -X DELETE -H "Authorization: Bearer q5rDX4iDIbMyda1GMtCDvI91IH7B9npkPNNvUvUEKes" http://localhost:9095/lapi/v1/namespaces/service-brokers/volumes/aaa

18.将datafoundry_volume的svc内网地址或者route配置为
   datafoundry_servicebroker_openshift程序中的环境变量
   DATAFOUNDRYPROXYADDR的值。
增加节点
在节点机器安装docker，4个基础工具包 ，都在cqmcall.tar 
按照安装基础环境的方法安装docker和4个基础工具包在需要添加的节点

将ansible机器的key加到新的节点

修改新节点的/etc/sysconfig/docker文件,修改OPTIONS，添加红色字段
OPTIONS=' --insecure-registry=172.16.0.0/16 --log-driver=json-file --log-opt max-size=50m'
...
...
ADD_REGISTRY='--add-registry 10.174.64.184:5000'
INSECURE_REGISTRY='--insecure-registry 10.174.64.184:5000'

修改/etc/sysconfig/docker需要重启docker
service docker restart

手动修改集群的hostsubnet
编辑hostsubnet.yaml文件，在master（10.174.64.179）/data/data1下
需要添加几个机器就添加几个红色字段：
vi hostsubnet.yaml
apiVersion: v1
items:
- apiVersion: v1
  host: 10.174.64.183
  hostIP: 10.174.64.183
  kind: HostSubnet
  metadata:
    creationTimestamp: null
    name: 10.174.64.183
  subnet: 172.31.0.0/24
- apiVersion: v1
  host: 10.174.64.185-------------------------------新节点ip
  hostIP: 10.174.64.185----------------------------新节点ip
  kind: HostSubnet
  metadata:
    creationTimestamp: null
    name: 10.174.64.185--------------------------新节点ip
  subnet: 172.31.1.0/24----------------修改为172.31.x.0/24，与文件中其他该段不冲突即可
kind: List
metadata: {}

备份旧的hosts文件
cp hosts hosts.bak
修改hosts文件，添加红色字段
[OSEv3:children]
masters
nodes
etcd
lb
new_nodes
...
...
...
[nodes]
10.174.64.183 openshift_node_labels="{'region': 'infra', 'zone': 'default'}" containerized=true openshift_ip=10.174.64.183 openshift_hostname=10.174.64.183
[new_nodes]
10.174.64.185 openshift_node_labels="{'region': 'primary', 'zone': 'default'}" containerized=true openshift_ip=10.174.64.185 openshift_hostname=10.174.64.185

需要添加几个节点就在[new_nodes]下面添加几行，把ip修改一下即可.
5.执行添加节点脚本
ansible-playbook  -i hosts dfpack/openshift-ansible/playbooks/byo/openshift-node/scaleup.yml
查看新加节点
oc get node 
添加成功后修改hosts文件，将[new_nodes]下的字段移动到[nodes]，因为增加节点时候脚本会把[new_nodes]里面的机器上安装node。不移动，会重新部署一边node。
安装glusterfs客户端
解压gfs-cli.tar.gz
tar -zxvf gfs-cli.tar.gz
安装testgfs下的所有包


官网文档：
https://docs.openshift.org/1.2/install_config/adding_hosts_to_existing_cluster.html#adding-nodes-advanced



5）容器安装glusterfs
具体参照官网：
https://docs.openshift.com/container-platform/3.7/install_config/install/advanced_install.html#advanced-install-glusterfs-persistent-storage


修改hosts文件
[OSEv3:children]
masters
etcd
nodes
lb
glusterfs
。。。。。。。
[OSEv3:vars]
openshift_storage_glusterfs_namespace=glusterfs
openshift_storage_glusterfs_name=storage

[glusterfs]
10.19.14.19 glusterfs_ip=10.19.14.19 glusterfs_devices='[ "/dev/vdb2" ]'
10.19.14.20 glusterfs_ip=10.19.14.20 glusterfs_devices='[ "/dev/vdb2" ]'
10.19.14.21 glusterfs_ip=10.19.14.21 glusterfs_devices='[ "/dev/vdc2" ]’
执行ansible-playbook
ansible-playbook -i hosts 3.6/openshift-ansible/playbooks/byo/openshift-glusterfs/config.yaml

注：sudo pvcreate --metadatasize=128M --dataalignment=256K /dev/vdc
这一步一定要先执行，先把物理盘做成pv，glusterfs会自动创建vg

生成的router是不可用的，具体router 要根据你集群绑定的域名自己导出来一个可用的router

通过命令申请一个后端服务（例如redis）
选择要申请后端服务的project
oc project <project_name>
查看集群后端服务
oc get bs -n openshift
查看服务plan
oc describe bs <bs_name> -n openshift
oc describe bs Redis -n openshift
申请redis实例
oc new-instance <bsi_name> --service=<service_name> --plan=<Plan>
oc new-instance redistest --service=Redis --plan=volumes_single
查看后端服务实例
oc get bsi

所有的后端服务实例具体的容器都在service-brokers下面.