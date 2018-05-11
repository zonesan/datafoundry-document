# GlusterFS集群本地部署


**以下假设iptables和firewall都关闭。**

## 安装glusterfs服务
```
yum install -y centos-release-gluster
yum install -y glusterfs glusterfs-server glusterfs-fuse glusterfs-rdma
```

*离线环境需要先行下载安装glusterfs所需要的rpm包或通过搭建的yum安装.*


## 启动glusterfs服务
```
systemctl start glusterd.service
systemctl enable glusterd.service
systemctl start glusterfsd.service
systemctl enable glusterfsd.service
```

## 添加gluster节点
```
gluster peer probe <each-address-of-other-glusterfs-machine>
```

## 安装heketi
```
yum install heketi heketi-client
```
*离线环境需要先行下载安装heketi所需要的rpm包或通过搭建的yum安装.*


## 生成heketi的key
```
ssh-keygen -f /etc/heketi/heketi_key -t rsa -N ''
chown heketi:heketi /etc/heketi/heketi_key
```

## 将刚生成的key添加到其他机器的authorized_keys
```
cat /etc/heketi/heketi_key.pub


其他机器添加公钥
vi /root/.ssh/authorized_keys
```

## 编辑heketi.json
```
sudo vi /etc/heketi/heketi.json
```
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
## 启动heketi服务
```
systemctl start heketi
systemctl enable heketi
```
## 初始化盘
*不要使用glusterfs客户端挂盘，要通过heketi来挂盘。*  

每个glusterfs machine上挂一快同样大小的未格式化过磁盘。
如果已经格式化过，使用下面任意一条命令重置磁盘(假设磁盘挂在/dev/vdc)：
*为了节约时间建议使用第一条命令*
```
pvcreate --metadatasize=128M --dataalignment=256K /dev/vdc
shred -v /dev/vdc
dd if=/dev/zero of=/dev/vdc bs=1M
```


## 编辑topology.json 文件
```
vi /etc/heketi/topology.json
```

*把其中的ip地址换成各个glusterfs machine的ip*
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


## 挂盘
```
第一次挂盘:
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv topology load --json=/etc/heketi/topology.json


查看结果：
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv topology info


以后也可以对每个node单独挂盘：
heketi-cli --json --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv device add	--name="/dev/vdd" --node="<node-id>"
```

## 其它heketi客户端常用命令：
```
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv cluster list
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv cluster info <cluster-id>
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv node info <node-id>




heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv volume list
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv volume create --size=1 --replica=2
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv volume info <volune-id>
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv volume expand --volume=<volune-id> --expand-size=1
heketi-cli --server=http://localhost:8080 --user=admin --secret=kLd834dadEsfwcv volume delete <volune-id>
```