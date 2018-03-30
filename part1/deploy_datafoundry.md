##安装集群

<font color=#FF4500 size=3>注：建议先安装dns服务器，避免不必要的麻烦</font>
###1.1 执行ansible-playbook脚本

    ansible-playbook -i hosts dfpack/openshift-ansible/playbooks/byo/config.yml
离线安装时hostsubnet需要手动创建，会报如下错误





编辑hostsubnet.yaml文件 <br>
```json
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
kind: List
metadata: {}
```

    oc create -f hostsubnet.yaml

在集群安装好以后登录到node节点，安装glusterfs客户端，否则会给容器挂盘挂不上：<br>
解压gfs-cli.tar.gz

    tar -zxvf gfs-cli.tar.gz
安装testgfs下的所有包

###1.2 安装service-brokers
容器启动一个service-brokers的etcd，此次选择在lb上启动service-brokers的etcd。<br>

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
安装etcd客户端

    rpm -ivh dfpack/etcd-2.3.7-2.el7.x86_64.rpm
   
\#创建root用户设置密码

    etcdctl user add root << EOF
    rootpasswd
    EOF
    etcdctl auth enable												#开启认证
    etcdctl -u root:rootpasswd role revoke guest --path '/*' -readwrite #收回guest权限
配置好etcd 需要写入catalog

    git clone  https://github.com/lileitongxue/ETCD.git

使用方法参照git上的说明

创建service-brokers的项目：

    oc new-project service-brokers
编辑datafoundryservicebrokeropenshift.yaml文件 <br>
```json
apiVersion: v1
kind: DeploymentConfig
metadata:
  annotations:
    openshift.io/deployment.cancelled: "11"
    openshift.io/generated-by: OpenShiftNewApp
  creationTimestamp: null
  labels:
    app: datafoundryservicebrokeropenshift
  name: datafoundryservicebrokeropenshift
spec:
  replicas: 1
  selector:
    app: datafoundryservicebrokeropenshift
    deploymentconfig: datafoundryservicebrokeropenshift
  strategy:
    resources: {}
    rollingParams:
      intervalSeconds: 1
      maxSurge: 25%
      maxUnavailable: 25%
      timeoutSeconds: 600
      updatePeriodSeconds: 1
    type: Rolling
  template:
    metadata:
      annotations:
        openshift.io/container.datafoundryservicebrokeropenshift.image.entrypoint: '["/bin/bash"]'
        openshift.io/generated-by: OpenShiftNewApp
      creationTimestamp: null
      labels:
        app: datafoundryservicebrokeropenshift
        deploymentconfig: datafoundryservicebrokeropenshift
    spec:
      containers:
      - env:
        - name: BROKERPORT
          value: "8888"
        - name: ETCDENDPOINT
          value: http://10.174.64.182:2379
        - name: ETCDUSER
          value: root
        - name: ETCDPASSWORD
          value: rootpasswd
        - name: OPENSHIFTADDR
          value: 10.174.64.182:443
        - name: OPENSHIFTPASS
          value: password
        - name: OPENSHIFTUSER
          value: chaizs
        - name: SBNAMESPACE
          value: service-brokers
        - name: ENDPOINTSUFFIX
          value: instance.app-dacp.dataos.io
        - name: DATAFOUNDRYPROXYADDR
          value: datafoundryservicevolume-datafoundry.app-dacp.dataos.io
        - name: ETCDIMAGE
          value: 172.16.184.84:5000/service-brokers/etcd-openshift-orchestration-2
        - name: KAFKAIMAGE
          value: 172.16.184.84:5000/service-brokers/kafka-openshift-orchestration
        - name: CASSANDRAIMAGE
          value: 172.16.184.84:5000/service-brokers/cassandra-openshift-orchestration-3
        - name: REDISIMAGE
          value: 172.16.184.84:5000/service-brokers/redis-openshift-2
        - name: STORMIMAGE
          value: 172.16.184.84:5000/service-brokers/storm-openshift-orchestration:v10_dep_dns
        - name: ZOOKEEPERIMAGE
          value: 172.16.184.84:5000/service-brokers/zookeeper-openshift-orchestration
        - name: KETTLEIMAGE
          value: 172.16.184.84:5000/service-brokers/kettle-service-2
        - name: NIFIIMAGE
          value: 172.16.184.84:5000/service-brokers/nifi-imported
        - name: TENSORFLOWIMAGE
          value: 172.16.184.84:5000/service-brokers/tensorflow-imported:0.8.0
        - name: ETCDBOOTIMAGE
          value: 172.16.184.84:5000/service-brokers/etcd-imported:v2.3.0
        - name: RABBITMQIMAGE
          value: 172.16.184.84:5000/service-brokers/service-brokers-rabbitmq-volumes
        - name: SPARKIMAGE
          value: 172.16.184.84:5000/service-brokers/spark-imported
        - name: ZEPPLINIMAGE
          value: 172.16.184.84:5000/service-brokers/zepplin-imported
        - name: REDISPHPADMINIMAGE
          value: 172.16.184.84:5000/service-brokers/php-redis-admin-imported
        - name: ZOOKEEPEREXHIBITORIMAGE
          value: 172.16.184.84:5000/service-brokers/zookeeper--envxhibitor-imported-2
        - name: SIMPLEFILEUPLOADERIMAGE
          value: 172.16.184.84:5000/service-brokers/simple-file-uploader
        - name: PYSPIDERIMAGE
          value: 172.16.184.84:5000/service-brokers/pyspider
        - name: ELASTICSEARCHVOLUMEIMAGE
          value: 172.16.184.84:5000/service-brokers/elasticsearch
        - name: ETCDVOLUMEIMAGE
          value: 172.16.184.84:5000/service-brokers/service-brokers-etcd-volumes
        - name: MONGOVOLUMEIMAGE
          value: 172.16.184.84:5000/service-brokers/mongo-volumes
        - name: KAFKAVOLUMEIMAGE
          value: 172.16.184.84:5000/service-brokers/service-brokers-kafka-volumes
        - name: NEO4JVOLUMEIMAGE
          value: 172.16.184.84:5000/service-brokers/neo4j
        - name: DNSMASQ_SERVER
          value: 192.168.12.8
        - name: NODE_ADDRESSES
          value: 10.174.64.183,10.174.64.185
        - name: REDIS32IMAGE
          value: 172.16.184.84:5000/service-brokers/redis:3.2
        - name: NODE_DOMAINS
          value: node154.local.dataos.io,node155.local.dataos.io
        - name: STORMEXTERNALIMAGE
          value: 172.16.184.84:5000/service-brokers/storm:external
        - name: EXTERNALZOOKEEPERSERVERS
          value: 10.1.236.92,10.1.236.93,10.1.236.94
        image: 172.16.184.84:5000/service-brokers/datafoundryservicebrokeropenshift@sha256:500d055833612ffb66ae7f4af4b66bee98939bb3bfdd6516e9452f0b1571d77d
        imagePullPolicy: Always
        name: datafoundryservicebrokeropenshift
        ports:
        - containerPort: 8888
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      securityContext: {}
      terminationGracePeriodSeconds: 30
  test: false
  triggers:
  - type: ConfigChange
  - imageChangeParams:
      automatic: true
      containerNames:
      - datafoundryservicebrokeropenshift
      from:
        kind: ImageStreamTag
        name: datafoundryservicebrokeropenshift:nocpulimit
    type: ImageChange
status: {}
```
没有集群用户chaizs需要手动创建

    Useradd xxx
    cp /usr/local/bin/oc /home/xxx/
    su xxx
    cd
    oc login <masterIP/LBip>:443
    chaizs
    passwd
拷贝到用户目录下的oc需要切到用户目录下使用。oc login的ip建议是lb的ip，单master直接使用master  ip。集群没有对用户进行认证，所有用户都可以登录，密码随意，登录的用户都是普通用户，需要切会到root下的管理员用户进行提权：

    oc adm policy add-cluster-role-to-user cluster-admin <username>
service-brokers映射一个svc

    oc expose dc datafoundryservicebrokeropenshift --port=8888
映射路由

    oc expose svc servicebroker-openshift —hostname=servicebroker.dataos.io

创建service-brokers
     
    oc new-servicebroker etcd --username=asiainfoLDP --password=2016asia --url=http://servicebroker.dataos.io

    oc get sb

查看状态为active，即为service-brokers创建成功

失败原因可能是域名无法解析，配置dns服务器，配置完成后需要重启集群docker，才能生效.

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

###1.3 添加node节点

1.3.1 在节点机器安装docker，4个基础工具包 ，都在cqmcall.tar 

按照安装基础环境的方法安装docker和4个基础工具包在需要添加的节点

1.3.2 将ansible机器的key加到新的节点

修改新节点的/etc/sysconfig/docker文件,修改OPTIONS，添加红色字段

>OPTIONS=' --insecure-registry=172.16.0.0/16 --log-driver=json-file --log-opt max-size=50m' <br>
... <br>
<font color="#dd0000">ADD_REGISTRY='--add-registry 10.174.64.184:5000'</font><br /> 
<font color="#dd0000">INSECURE_REGISTRY='--insecure-registry 10.174.64.184:5000'</font><br /> 

修改/etc/sysconfig/docker需要重启docker

    service docker restart

手动修改集群的hostsubnet <br>
编辑hostsubnet.yaml文件，在master（10.174.64.179）/data/data1下 <br>
需要添加几个机器就添加几个红色字段：<br>
```json
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
```
备份旧的hosts文件

    cp hosts hosts.bak

修改hosts文件，添加红色字段

>[OSEv3:children]
masters <br>
nodes <br>
etcd <br>
lb <br>
<font color="#dd0000">new_nodes</font><br /> 
... <br>
... <br>
... <br>
[nodes] <br>
10.174.64.183 openshift_node_labels="{'region': 'infra', 'zone': 'default'}" containerized=true openshift_ip=10.174.64.183 openshift_hostname=10.174.64.183 <br>
<font color="#dd0000">[new_nodes]</font><br /> 
<font color="#dd0000">10.174.64.185 openshift_node_labels="{'region': 'primary', 'zone': 'default'}" containerized=true openshift_ip=10.174.64.185 openshift_hostname=10.174.64.185 </font><br /> 

需要添加几个节点就在[new_nodes]下面添加几行，把ip修改一下即可.

5.执行添加节点脚本

    ansible-playbook  -i hosts dfpack/openshift-ansible/playbooks/byo/openshift-node/scaleup.yml

查看新加节点

    oc get node 

添加成功后修改hosts文件，将[new_nodes]下的字段移动到[nodes]，因为增加节点时候脚本会把[new_nodes] <br>里面的机器上安装node。不移动，会重新部署一边node。 <br>
安装glusterfs客户端 <br>
解压gfs-cli.tar.gz <br>

    tar -zxvf gfs-cli.tar.gz

安装testgfs下的所有包


官网文档：
https://docs.openshift.org/1.2/install_config/adding_hosts_to_existing_cluster.html#adding-nodes-advanced




