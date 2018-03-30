##搭建过程 

###一.安装基础环境

####1.安装docker、ansiable 

<font color=#FF4500 size=3>注：所有机器均需安装docker</font>

#####1.1 安装docker 
如果机器有访问外网的能力找一个可用的yum源（阿里源 163源都可以）

    yum install -y docker 

#####1.2 如果主机没有访问外网能力，需要手动下载docker1.12的rpm包 

    rpm -ivh   docker-1.12.xxxxxxx.centos.x86_64.rpm 

如果缺少依赖的话 自行查看报错信息解决依赖问题

#####1.3 启动docker 

    service docker start 

#####1.4 下载ansible-playbook（10.174.64.179主机，三台master其中一台就可以）
 
    git clone -b release-3.6 https://github.com/openshift/openshift-ansible.git 

#####1.5 安装ansiable（ 10.174.64.179主机和ansible-playbook安装到同一台主机上）
openshift-playbook需要的环境要求：<br>
	   ansible >= 2.2.2.0 <br>
	   Jinja >= 2.7 <br>
      pyOpenSSL  <br> 
      python-lxml <br>
如果主机有外网能力可以用yum的方式安装

    yum install -y ansible pyOpenSSL python-cryptography python-lxml 

或者自行下载rpm 

    rpm -ivh ansible-2.2.0.0-4.el7.noarch.rpm   xxx.rpm xxx.rpm xxx.rpm 

根据提示安装依赖。

#####1.6 配置互信 
将ansiable机器的key加到所有机器上，包括ansiable机器本身。

编辑文件jiedian.txt此文件只是方便执行ansiable命令。
>[master] <br>
10.174.64.179 <br>
10.174.64.180 <br>
10.174.64.181 <br>
[lb] <br>
10.174.64.182 <br>
[node] <br>
10.174.64.183 <br>
10.174.64.184 <br>

测试连通性

    ansible -i jiedian.txt all -m ping 

注意：我们集群的docker版本是1.12.6，ansiable版本是2.3.0.0（可作为参照）<br>
安装基础包 <br>
#####1.6.1 lb机器安装haproxy , iptables-services 

    rpm -Uvh iptables-1.4.21-16.el7.x86_64.rpm 

    rpm -ivh haproxy-1.5.14-3.el7.x86_64.rpm iptables-devel-1.4.21-16.el7.x86_64.rpm iptables-utils-1.4.21-16.el7.x86_64.rpm iptables-services-1.4.21-16.el7.x86_64.rpm 

#####1.6.2 etcd(master)机器安装etcd客户端。

    ansible -i jiedian.txt master -m shell -a "rpm -ivh etcd-3.1.9-2.el7.x86_64.rpm" 

#####1.6.3 所有机器安装dfpack/docker/os下面的net-tools、bridge-utils、bind-utils、bash-completion的包，已安装的低版本进行升级。 <br>
配置docker-storage（可选）<br>
修改/etc/sysconfig/docker-storage-setup文件 

    cat /etc/sysconfig/docker-storage-setup 
>DEVS=/dev/sdb <br>
VG=docker-vg <br>
DATA_SIZE=98G <br>

node 节点：

    ansible -i jiedian.txt node -m copy -a "src=/etc/sysconfig/docker-storage-setup dest=/etc/sysconfig/docker-storage-setup" 
    ansible -i jiedian.txt node -m shell -a "docker-storage-setup"   
    ansible -i jiedian.txt node -m shell -a "service docker start" 
    
master节点：
       
    ansible -i jiedian.txt master -m copy -a "src=/etc/sysconfig/docker-storage-setup dest=/etc/sysconfig/docker-storage-setup" 
    ansible -i jiedian.txt master -m shell -a "docker-storage-setup" 
    ansible -i jiedian.txt master -m shell -a "service docker start" 
lb节点：

    ansible -i jiedian.txt lb -m copy -a "src=/etc/sysconfig/docker-storage-setup dest=/etc/sysconfig/docker-storage-setup" 
    ansible -i jiedian.txt lb -m shell -a "docker-storage-setup"    
    ansible -i jiedian.txt lb -m shell -a "service docker start" 
将需要的镜像push到私有镜像库 <br>
解压images.tar 

    tar -zxvf images.tar.gz 

加载镜像 

    cd images && ll|awk '{print $9}'|grep tar| awk '{print "docker load -i "$1}'|sh 

在/etc/sysconfig/docker最下面添加一行，将私有镜像库配置为可信任的，ip地址为所选机器ip：5000 <br>
>INSECURE_REGISTRY='--insecure-registry 10.174.64.184:5000' <br>

重启docker 

    service docker resart

搭建私有镜像库(镜像库地址为  主机IP:5000) 

    docker run -d -p 5000:5000 registry:2 

将加载好的镜像push到私有镜像库 <br>

修改所有镜像的tag 

    例：docker tag registry.dataos.io/openshift/ldp-origin:v1.1.6-ldp0.4.19 10.174.64.182:5000/openshift/ldp-origin:v1.1.6-ldp0.4.19 

push所有镜像到私有镜像库 

    例：docker push 10.174.64.182:5000/openshift/ldp-origin:v1.1.6-ldp0.4.19 
将私有镜像库配置为可信任的 <br>
需要为所有机器将私有镜像库设置为可信任的，修改ansiable机器下的/etc/sysconfig/docker文件，在复制到所有机器上 <br>

>INSECURE_REGISTRY='--insecure-registry 10.174.64.184:5000' <br>
ansible -i jiedian.txt all -m copy -a "src=/etc/sysconfig/docker dest=/etc/sysconfig/docker" <br>

重启服务

    ansible -i jiedian.txt all -m shell -a "service docker restart" 

编辑pull.sh文件(可选) <br>
不执行此步，集群在执行playbook时会自动去pull镜像。

    cat pull.sh 

>\#!/bin/bash <br>
IMAGETAG=v1.1.6 <br>
REPO=10.174.64.184:5000 <br>
docker pull ${REPO}/openshift/ldp-node:${IMAGETAG} <br>
docker pull ${REPO}/openshift/ldp-origin-docker-builder:${IMAGETAG} <br>
docker pull ${REPO}/openshift/ldp-origin-deployer:${IMAGETAG} <br>
docker pull ${REPO}/openshift/ldp-origin-docker-registry:${IMAGETAG} <br>
docker pull ${REPO}/openshift/ldp-origin-custom-docker-builder:${IMAGETAG} <br>
docker pull ${REPO}/openshift/ldp-openvswitch:${IMAGETAG} <br>
docker pull ${REPO}/openshift/ldp-origin-pod:${IMAGETAG} <br>
docker pull ${REPO}/openshift/ldp-origin-haproxy-router:${IMAGETAG} <br>

复制pull.sh到所有机器 

    ansible -i jiedian.txt all -m copy -a "src=/data/data1/pull.sh dest=/data/data1/pull.sh" 
执行脚本 
    
    ansible -i jiedian.txt all -m shell -a "sh /data/data1/pull.sh"
编辑hosts文件 <br>
>[OSEv3:children] <br>
masters <br>
nodes <br>
etcd <br>
lb <br>

>[OSEv3:vars] <br>
ansible_ssh_user=root <br>
ansible_become=true <br>
deployment_type=origin <br>

>osm_image=10.174.64.184:5000/openshift/ldp-origin <br>
osn_image=10.174.64.184:5000/openshift/ldp-node <br>
osn_ovs_image=10.174.64.184:5000/openshift/ldp-openvswitch <br>
openshift_pkg_version='v1.1.6-ldp0.3.7.1' <br>
openshift_image_tag='v1.1.6-ldp0.3.7.1' <br>

>oreg_url=10.174.64.184:5000/openshift/ldp-origin-${component}:${version} <br>
cli_docker_additional_registries=10.174.64.184:5000 <br>
cli_docker_insecure_registries=10.174.64.184:5000 <br>
openshift_master_api_port=443 <br>
openshift_master_console_port=443 <br>
osm_cluster_network_cidr=172.31.0.0/16 <br>
openshift_portal_net=172.16.0.0/16 <br>
osm_host_subnet_length=8 <br>
openshift_use_dnsmasq=False <br>

>openshift_master_cluster_method=native <br>
openshift_master_cluster_hostname=10.174.64.182 <br>
openshift_master_cluster_public_hostname=10.174.64.182 <br>

>osm_etcd_image=10.174.64.184:5000/etcd_redhat/etcd:latest <br>

>\# host group for masters <br>
[masters] <br>
10.174.64.179 containerized=true openshift_hostname=10.174.64.179 openshift_ip=10.174.64.179 <br>
10.174.64.180 containerized=true openshift_hostname=10.174.64.180 openshift_ip=10.174.64.180 <br>
10.174.64.181 containerized=true openshift_hostname=10.174.64.181 openshift_ip=10.174.64.181 <br>

>\# host group for etcd <br>
[etcd] <br>
10.174.64.179 containerized=true openshift_public_hostname=10.174.64.179 openshift_ip=10.174.64.179 <br>
10.174.64.180 containerized=true openshift_public_hostname=10.174.64.180 openshift_ip=10.174.64.180 <br>
10.174.64.181 containerized=true openshift_public_hostname=10.174.64.181 openshift_ip=10.174.64.181 <br>

>\# Specify load balancer host <br>
[lb] <br>
10.174.64.182 openshift_hostname=10.174.64.182 openshift_ip=10.174.64.182 <br>

>\# host group for nodes, includes region info <br>
[nodes] <br>
10.174.64.183 openshift_node_labels="{'region': 'infra', 'zone': 'default'}" containerized=true openshift_ip=10.174.64.183 openshift_hostname=10.174.64.183 <br>