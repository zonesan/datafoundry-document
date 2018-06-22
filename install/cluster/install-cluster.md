# 集群安装
* [安装基础环境](#安装基础环境)

* [需要准备的镜像](#需要准备的镜像)

* [修改hosts文件](#修改hosts文件)

* [执行脚本安装集群](#执行脚本安装集群)

* [安装service-brokers](#安装service-brokers)

* [部署df页面](#部署df页面)


## 安装基础环境

>如果是离线安装需要提前准备以下辅助工具：  
>1.yum源  
>2.私有镜像库  



### 1.1 安装ansible 
**离线安装**  
yum源中有ansible的包,直接使用yum命令安装。
```
yum install ansible 
```

**在线安装**
```
yum -y install https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm 

sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

 yum -y --enablerepo=epel install ansible pyOpenSSL
```


### 1.2 编辑jiedian.txt文件
编辑文件jiedian.txt此文件只是方便执行ansiable命令，模版如下：
```
[master] 
<master1_ip>
<master2_ip>
<master3_ip>
[lb] 
<lb_ip>
[node] 
<node1_ip>
<node2_ip>
```

### 1.3 配置互信 
将所有ip都加入到下面命令。
```
ssh-keygen -t rsa

for i in master1 \
 <ip1> \
 <ip2> \
 <ip3> ; \
 do ssh-copy-id -i $i; \
 done
```

测试连通性
```
ansible -i jiedian.txt all -m ping 
```

### 1.4 安装docker 
yum源中有docker的包，直接使用yum命令安装。
```
yum install -y docker
```
### 1.5 配置私有镜像库信任
```
cat /etc/docker/daemon.json
{
    "insecure-registries": [
        "172.25.0.0/16",
        "10.1.1.x:5000",
        "docker-registry.default.svc:5000"
    ]
}

ansible -i hosts-list all -s -m copy -a "/etc/docker/daemon.json dest=/etc/docker/daemon.json"

```
### 1.6 配置docker存储

```
ansible -i hosts-list node -s -m shell -a "pvcreate /dev/xxx"
ansible -i hosts-list node -s -m shell -a "vgcreate vgdocker /dev/xxx"
ansible -i hosts-list node -s -m shell -a "lvcreate -L 100G -n lvdocker vgdocker"
ansible -i hosts-list node -s -m shell -a "mkfs -t xfs /dev/mapper/vgdocker-lvdocker"
ansible -i hosts-list node -s -m shell -a "mount /dev/mapper/vgdocker-lvdocker /var/lib/docker"
ansible -i hosts-list node -s -m shell -a "echo '/dev/mapper/vgdocker-lvdocker /var/lib/docker xfs defaults 0 0' >> /etc/fstab" 
ansible -i hosts-list node -s -m shell -a "service docker restart"
```

### 1.7 启动docker 
```
service docker start
```

#### 1.8 下载ansible-playbook
```
git clone https://github.com/wangyadongd/openshift-ansible.git -b release-3.6
```


## 需要准备的镜像

公网环境可以直接pull下面镜像
```
registry.dataos.io/openshift/ldp-origin:v1.1.6-ldp0.4.19
registry.new.dataos.io/datafoundry/datafoundryvolume:latest

registry.new.dataos.io/openshift/node:v3.6.0  
registry.new.dataos.io/openshift/openvswitch:v3.6.0  
registry.new.dataos.io/openshift/origin:v3.6.0  
registry.new.dataos.io/openshift/origin-deployer:v3.6.0  
registry.new.dataos.io/openshift/origin-docker-builder:v3.6.0  
registry.new.dataos.io/openshift/origin-docker-registry:v3.6.0  
registry.new.dataos.io/openshift/origin-haproxy-router:v3.6.0  
registry.new.dataos.io/openshift/origin-pod:v3.6.0
registry.new.dataos.io/coreetcd/etcd:v2.3.7   
```

## 修改hosts文件
根据现场环境，修改模版下的[hosts](file-template/hosts)

## 执行脚本安装集群
hosts为刚才修改的hosts
```
 ansible-playbook -i hosts openshift-ansible/playbooks/byo/config.yml
```

## 安装service-brokers

### 5.1 创建brokers的etcd
将里面的ip更改为有效ip
```
docker run -d -p 2380:2380 -p 2379:2379 \
 --name etcd 10.174.64.184:5000/coreetcd/etcd:v2.3.7 \
 -name etcd0 \
 -advertise-client-urls http://10.174.64.182:2379 \
 -listen-client-urls http://0.0.0.0:2379 \
 -initial-advertise-peer-urls http://10.174.64.182:2380 \
 -listen-peer-urls http://0.0.0.0:2380 \
 -initial-cluster-token etcd-cluster-1 \
 -initial-cluster etcd0=http://10.174.64.182:2380 \
 -initial-cluster-state new
```

安装etcd客户端
```
yum install etcd
```

### 5.2 创建root用户设置密码
```
    etcdctl user add root << EOF
    rootpasswd
    EOF
    etcdctl auth enable												#开启认证
    etcdctl -u root:rootpasswd role revoke guest --path '/*' -readwrite #收回guest权限
配置好etcd 需要写入catalog
```

### 5.3 写入catlog
```
git clone  https://github.com/lileitongxue/ETCD.git
```
使用方法参照git上的说明

### 5.4 创建brokers服务
在当前集群创建service-brokers的项目：
```
oc new-project service-brokers
```

创建集群管理员
```
oadm policy add-cluster-role-to-user cluster-admin <user_name>
```

编辑datafoundryservicebrokeropenshift.yaml文件

根据yaml文件创建dc
```
oc create -f datafoundryservicebrokeropenshift.yaml
```

service-brokers映射一个svc
```
oc expose dc datafoundryservicebrokeropenshift --port=8888
```

映射路由
```
oc expose svc servicebroker-openshift —hostname=servicebroker.dataos.io
```

### 启动all-in-one容器
```
docker run -d -p 8443:8443 --name "openshift-origin" \
 --privileged --net=host \
-v /:/rootfs:ro -v /var/run:/var/run:rw -v /sys:/sys:ro -v /var/lib/docker:/var/lib/docker:rw \
registry.dataos.io/openshift/ldp-origin:v1.1.6-ldp0.4.19 start
```

### 创建brokers
```
docker exec -it openshift-origin bash

oc new-servicebroker etcd --username=asiainfoLDP --password=2016asia --url=http://servicebroker.dataos.io
```


## 部署df页面
### 6.1 创建datafoundry-web的tempalte资源
```
#创建
oc create -f df-web-template.yaml -n openshift

#查看
oc get template |grep datafoundry-web
```

### 6.2 创建df页面的project
```
oc new-project datafoundry
```

### 6.3 在datafoundry下创建页面服务
```
 oc process -n openshift datafoundry-web \
 DATAFOUNDRY_WEB_URL=<VALUE1> \
 DATAFOUNDRY_APISERVER_ADDR=<VALUE2> \
 DATAFOUNDRY_ADMIN_USER=<VALUE3> \
 DATAFOUNDRY_ADMIN_PASS=<VALUE4> \
 HEKETI_USER=<VALUE5> \
 HEKETI_KEY=<VALUE6> \
 ROUTER_DOMAIN_SUFFIX=<VALUE7> \
 REGISTRY_PRIVATE_ADDR=<VALUE8> \
 REGISTRY_PUBLIC_ADDR=<VALUE9> \
 | oc create -f -
```

**变量说明：**
```
DATAFOUNDRY_WEB_URL                     应用创建成功后，访问的域名地址，需遵守当前集群使用泛域名，如：dfweb-test.lo.dataos.io

DATAFOUNDRY_APISERVER_ADDR              api入口，一般为lb地址，如：10.1.234.34

DATAFOUNDRY_ADMIN_USER                  集群管理员用户名

DATAFOUNDRY_ADMIN_PASS                  集群管理员密码

HEKETI_USER                             heketi管理员用户

HEKETI_KEY                              heketi管理员用户的key

ROUTER_DOMAIN_SUFFIX                    创建应用时，自动生成域名所使用的泛域名，如：*.app.prd.asiainfo.com

REGISTRY_PRIVATE_ADDR                   集群default下的docker-registry的域名地址,如：docker-registry-default.lo.dataos.io

REGISTRY_PUBLIC_ADDR                    公共镜像库的域名地址，如：registry.new.dataos.io

```


### 6.4 查看访问页面
```
# 查看pod状态
oc get pod
NAME                               READY     STATUS    RESTARTS   AGE
datafoundrypayment-1-5gs45         1/1       Running   0          5m
datafoundryservicevolume-1-cdwjl   1/1       Running   0          5m
gitter-1-4vw69                     1/1       Running   0          5m
web-console-1-3dm5v                2/2       Running   0          5m

# 查看url，访问
oc get route|grep web-console|awk '{print $2}'
```
