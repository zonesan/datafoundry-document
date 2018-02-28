##glusterfs集群部署

<font color=#FF4500 size=3>建议先执行11步，准备盘需要很长时间，此过程中可以安装服务。</font>

以下假设iptables和firewall都关闭。<br>
1.解压zkgfs.tar.gz包 <br>

2.每台机器都安装glusterfs <br>
解压base.tar.gz安装基础依赖包 <br>
解压glusterfs.tar，进入到解压的文件夹glusterfs，执行命令make install安装glusterfs <br>

3.启动glusterfs服务

    sudo systemctl start glusterd.service
    sudo systemctl enable glusterd.service

4.添加gluster节点

    gluster peer probe <each-address-of-other-glusterfs-machine>

5.选择一台机器安装heketi <br>
解压heketi.tar.gz，安装heketi开头的rpm包，其他的包为依赖包，不缺少不安装 <br>
6.生成heketi的key

    sudo ssh-keygen -f /etc/heketi/heketi_key -t rsa -N ''
    sudo chown heketi:heketi /etc/heketi/heketi_key

7.将刚生成的key添加到其他机器的authorized_keys

    cat /etc/heketi/heketi_key.pub

其他机器添加公钥

    vi /root/.ssh/authorized_keys

8.修改所有机器/root/.bashrc文件添加一行，因为gluster不再默认路径下
>export PATH=/usr/local/openssl1.0.2a/bin:/usr/local/openssh7.2p2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin:/bin:/sbin

9.编辑heketi.json

    sudo vi /etc/heketi/heketi.json
```json
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
```
10.启动heketi服务

    sudo systemctl start heketi
    sudo systemctl enable heketi
11.挂盘
不要使用glusterfs客户端挂盘，要通过heketi来挂盘。

每个glusterfs machine上挂一快同样大小的未格式化过磁盘。
如果已经格式化过，使用下面任意一条命令重置磁盘(假设磁盘挂在/dev/vdc)：

    sudo pvcreate --metadatasize=128M --dataalignment=256K /dev/vdc
    sudo shred -v /dev/vdc
    sudo dd if=/dev/zero of=/dev/vdc bs=1M
12.编辑topology.json 文件

    vi /etc/heketi/topology.json 
```json
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
```
把其中的ip地址换成各个glusterfs machine的ip <br>
13.第一次挂盘:

    heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv topology load --json=/etc/heketi/topology.json

查看结果：

    heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv topology info

以后也可以对每个node单独挂盘：

    heketi-cli --json --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv device add	--name="/dev/vdd" --node="<node-id>"

16.创建end point

    cat gluster-endpoints.yaml
```json
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
 ```   
\# 将上面的ip换成各个glusterfs machine的ip <br>

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