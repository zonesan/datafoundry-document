# 需要开放的端口

## 对集群以外的机器
```
80                  用于路由器的HTTP / HTTPS
443                 节点与master API通信，接受任务，返回节点状态
8443                集群Web控制台使用，与API服务器共享
30000-32767         默认NodePort端口
```

## 集群间机器

### 多主集群开放端口
```
22                  供管理员SSH使用
53                  集群服务的DNS解析
80                  用于路由器的HTTP / HTTPS
443                 节点与master API通信，接受任务，返回节点状态
8443                集群Web控制台使用，与API服务器共享
4789                Pod之间通信
10250               供Kubelet使用
2379                etcd通信
2380                etcd通信
```

### 单主集群必须开放的端口
```
53                  集群服务的DNS解析
2049                安装NFS时需要开放的端口
4789                Pod之间通讯
```


### 有相关组件时需要开放端口
#### Elasticsearch
```
9200                Elasticsearch API
9300                Elasticsearch群集间通信使用
```

#### GlusterFS
```
24007               Gluster Daemon
24008               Management
49152 - 49251       For client communication with Red Hat Gluster Storage 2.1 and for brick processes depending on the availability of the ports.        
111                 portmapper 
```

#### 私有镜像库
```
5000                镜像库使用端口
```

#### yum源
```
80                  由于使用的httpd搭建yum源，使用默认端口80
```
