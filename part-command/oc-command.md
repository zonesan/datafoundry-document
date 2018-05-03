# 常用命令
* [基础命令](#基础命令)
  * [集群类型介绍(oc types)](#集群类型介绍)
  * [登录集群(oc login)](#登录集群)
  * [创建新的project(oc new-project)](#创建新的project)
  * [创建新应用(oc new-app)](#创建新应用)
  * [显示/切换所在project(oc project)](#显示or切换所在project)
  * [列出用户权限下的所有project(oc projects)](#列出用户权限下的所有project)
* [构建和部署命令](#构建和部署命令)
  * [部署(oc rollout)](#部署)
  * [回滚(oc rollback)](#回滚)
  * [新建构建镜像(oc new-build)](#新建构建镜像)
  * [启动构建镜像(oc start-build)](#启动构建镜像)
  * [取消构建镜像(oc cancel-build)](#取消构建镜像)
  * [添加镜像tag(oc tag)](#添加镜像tag)
* [应用管理](#应用管理)
  * [查看资源类型列表(oc get)](#查看资源类型列表)
  * [查看资源类型的详情信息(oc describe)](#查看资源类型的详情信息)
  * [修改资源类型信息(oc edit)](#修改资源类型信息)
  * [配置应用的资源(oc set)](#配置应用的资源)
  * [标签操作(oc label)](#标签操作)
  * [svc/router映射(oc expose)](#svc或router映射)
  * [删除(oc delete)](#删除)
  * [调度(oc scale)](#调度)
  * [弹性伸缩(oc autoscale)](#弹性伸缩)
  * [secret(oc secret)](#secret)
* [运维命令](#运维命令)
  * [日志(oc logs)](#日志)
  * [进入pod(oc rsh)](#进入pod)
  * [文件传输(oc rsync)](#文件传输)
  * [run(oc run)](#run)
  * [拷贝(oc cp)](#拷贝)
* [高级命令](#高级命令)
  * [创建(oc create)](#创建)
    * [创建集群资源配额(oc create clusterresourcequota)](#创建集群资源配额)
    * [创建configMap(oc create configmap)](#创建configmap)
    * [创建deployment(oc create deployment)](#创建deployment)
    * [创建deploymentconfig(oc create deploymentconfig)](#创建deploymentconfig)
    * [创建imagestream(oc create imagestream)](#创建imagestream)
  * [导出模版配置(oc export)](#导出模版配置)
  * [提取secret/configmap(oc extract)](#提取secret或configmap)
  * [登出(oc logout)](#登出)
  * [显示当前用户(oc whoami)](#显示当前用户)
  * [查看版本(oc version)](#查看版本)
* [管理员命令](oc-adm.md)

## 基础命令

### 集群类型介绍
```
oc types
```

### 登录集群
```
oc login <SERVER_URL>

Options:
  -u, --username=''             用户名 
  -p, --password=''             密码  

Example:
    #使用 abc 用户登录 10.19.14.19 集群
    oc login 10.19.14.19:8443 -u abc -p abc
``` 

### 创建新的project
```
oc new-project <NAME>

Options:
  --description=''              project 的描述
  --display-name=''             project 的显示名称

Example:

    #创建一个 test 的 project
    oc new-project test
```

### 创建新应用
```
oc new-app <image | imageStream | template | Dockerfile path | Dockerfile url>

Options:           
  -e, --env=[]                  添加 dc 中的环境变量
  -f, --file=[]                 指定应用 template 文件路径
  -i, --image-stream=[]         使用的 Image Stream 名称
  --insecure-registry=false     如果为 true,表示对镜像库绕过证书检查 
  -l, --labels=''               设置应用的标签
  --name=''                     设置应用名称(包括 bc、dc 的名称)
  --template=[]                 指定应用 template 的名称

Example:    
  #使用 git 的 url 创建一个应用
  oc new-app https://github.com/openshift/ruby-ex.git
```

### 显示or切换所在project
```
oc project <PROJECT_NAME>

Example:
  #显示当前project
  oc project 

  #切换到 test2 的 project
  oc project test2
```

### 列出用户权限下的所有project
```
oc projects
oc get project
```

## 构建和部署命令

### 部署
```
oc rollout [command] dc/<dcName>

Available Commands:
  cancel                        取消部署
  latest                        启动最新部署
  retry                         重试最新失败的部署
  status                        查看部署状态

Example：
  #将 dc-test 部署为最新版本
  oc rollout latest dc/dc-test
```
### 回滚
```
oc rollback <dcName>

Example:
  #将 dc-test 回滚到上一个成功部署的版本
  oc rollback dc-test
```

### 新建构建镜像
```
oc new-build <url | path ... >      用于构建一个新的镜像

Options：
  -e, --env=[]                      设置镜像的键值对环境变量
  -i, --image-stream=[]             构建成的 imageStream 名称
  -l, --labels=''                   添加label

Example:
  #根据当前目录下的 Dockerfile 文件，构建一个 tag 名为 test 的镜像
  oc new-build . --name=test
```

### 启动构建镜像
```
oc start-build <bc>

Example:
  #根据 bc-test 的 bc 开始构建镜像
  oc start-build bc-test
```

### 取消构建镜像
```
oc cancel-build <bcNmae>

Example：
  #取消 bc-test 的 bc 的镜像构建
  oc cancel-build bc-test
```

### 添加镜像tag
```
oc tag <source> <dest>

Example：
  #将 tag 为 test1:latest 的镜像,添加一个名称为 test2:latest 的 tag
  oc tag test1 test2:latest
```

## 应用管理

### 查看资源类型列表
```
oc get <type/name>                  typeName 可以是 oc types 看到的所有 type

Options：
  --all-namespaces                  列出所有 namespaces 类型资源
  -o, --output=''                   输出格式，可以是 yaml、json、wide、name...
  --show-labels                     列出label
  -w, --watch                       持续监听

Example：
  #列出当前 namespaces 下的 pod
  oc get pod

  #列出当前 namespaces 下 pod 的更多信息
  oc get pod -o wide

  #以 yaml 格式输出名为 test 单个 pod 的信息
  oc get pod test -o yaml

  #列出所有 namespaces 的 pod
  oc get pod --all-anmespaces

  #列出 node 节点的 label
  oc get node --show-labels
```

### 查看资源类型的详情信息
```
oc describe <type/name>
    
Options:
  --all-namespaces                  列出所有 namespaces 类型资源

Example:
  #查看名为 test 的 pod 的详情信息
  oc describe pod/test

  #查看当前 namespace 下的所有 pod 的详情信息
  oc describe pod
```

### 修改资源类型信息
```
oc edit <type/name>

Example:
  #修改名为 test1 的 svc
  oc edit svc test1

  #修改名为 test1 的 dc
  oc edit dc/test1
```

### 配置应用的资源
```
oc set <COMMAND>

Available Commands:
  env
  resources
  volumes
```

* env
```
oc set env <RESOURCE/NAME> <KEY1=VLA1>...

Options：
  --all                             指定范围为全部
  --list                            列出所有环境变量
  --overwrite                       如果为 true,允许环境变量被覆盖
  -c,--containers='*'               当 pod 中有多个 container 时，通过此参数指定具体的 container ，* 表示pod中的所有容器

Example：
  #为 test1 的 dc 添加一组环境变量
  oc set env dc/test1 NUMBER="1"

  #列出 test1 的 dc 所有环境变量
  oc set env dc/test --list

  #删除 test dc 的 NUMBER 环境变量
  oc set env dc/test NUMBER-
```

* resources
 ```   
oc set resources <RESOURCE/NAME>

Options:
  --limits=''                       整个  pod 所能请求的最大资源
  --requests=''                     pod 创建时所请求的资源
  -c,--containers                   当 pod 中有多个 container 时，通过此参数指定具体的 container，* 表示 pod 中的所有容器

Example：
  #限制 dc test 中创建 container1 时最大的请求资源
  oc set resources dc test -c=container1 --limits=cpu=100m,memory=100Mi

  #限制 dc test 的最大资源是 100m cpu,100Mi 内存，创建pod时的pod的大小为 30m cpu,30Mi 内存
  oc set resources dc test --limits=cpu=100m,memory=100Mi --requests=cpu=30m,memory=30Mi

  #移除资源请求
  oc set resources dc/test --limits=cpu=0,memory=0 --requests=cpu=0,memory=0
```
      
* volumes
```
oc set volumes <RESOURCE/NAME>

Options:
  --add                             添加卷或者挂载卷
  -m,--mount-path=''                挂载容器内的路径
  --name=''                         在 dc 中挂载部分的名称
  --remove                          移除挂载
  -t, --type=''                     挂载类型，可以是：emptyDir, hostPath, secret, configmap, persistentVolumeClaim
  --path=''                         当挂载类型为 hostPath 时，指定挂载主机的路径
  --secret-name=''                  当类型为 secret 时，挂载 secret 的名称
  --overwrite                       覆盖

Example：
  #使用现有的pvc覆盖原有的 volume 'v1'
  oc set volume dc/registry --add --name=v1 -t pvc --claim-name=pvc1 --overwrite

  #删除 dc 中 volume 'v1'
  oc set volume dc/registry --remove --name=v1
```

### 标签操作
```
oc label <RESOURCE/NAME> <KEY1=VLA1>...

Example：
  #为 test pod 添加 status=unhealthy 的标签，若 key 'status' 已存在则更新 value 的值为 unhealthy
  oc label --overwrite pods test status=unhealthy

  #移除 pod 'test' 中key为 status 的标签
  oc label pods test status-
```

### svc或router映射
```
oc expose <RESOURCE/NAME>

Options:
  --hostname=''                     指定映射出 route 的域名
  --name=''                         映射出 svc 或 router 的名称
  --path=''                         设置新 route 的路径
  --port=''                         映射 svc 时候的端口
  --type=''                         设置 svc 的类型，常用的有：ClusterIP, NodePort

Example：
  #映射一个指定端口的 svc
  oc expose dc ruby-hello-world --port=8080

  #映射一个指定域名的 router
  oc expose service ruby-hello-world --hostname=www.example.com

  #映射一个 NodePort 类型的 svc
  oc expose dc ruby-hello-world --port=8080 --type NodePort
```

### 删除
```
oc delete <RESOURCE/NAME>

Options:
  --all                             全选

Example：
  #删除当前 project 下的所有 pod
  oc delete pod --all

  #删除具体名为 test-1-skgr 的 pod
  oc delet pod test-1-skgr

  #删除所有 svc
  oc delete svc --all
```

### 调度
```
oc scale --replicas=<COUNT> <RESOURCE/NAME>

Options:
  --replicas=-1                     副本数

Example:
  #修改 dc 的副本数
  oc scale --replicas=10 dc test

  #修改 rc 的副本数
  oc scale --replicas=0  rc test-1
```

### 弹性伸缩
```
oc autoscale <RESOURCE/NAME>

Options：
  --cpu-percent=-1                  cpu 利用率，超过设置范围自动扩缩容
  --max=-1                          自动调节器设置 pod 的上限
  --min=-1                          自动调节器设置 pod 的下限
  --name=''                         指定名称

Example：
  #设置 dc 弹性伸缩的范围是 2 到 10
  oc autoscale dc/test --min=2 --max=10

  #设置 rc 弹性伸缩的范围是 1 到 5,cpu 的利用率为 80% 进行调整
  oc autoscale rc/test-1 --max=5 --cpu-percent=80
```

### secret
```
oc secret new <NAME>

Example：
  #创建一个包含两部分的 secret,ssh-privatekey 和 ssh-publickey 为 secret 中数据名称
  oc secrets new my-secret ssh-privatekey=~/.ssh/id_rsa ssh-publickey=~/.ssh/id_rsa.pub

  #创建 /a 文件夹的 secret
  oc secrets new test /
```  

## 运维命令

### 日志
```
oc logs <POD>

Options：
  -f                                持续监听
  -c,--container=''                 多个容器时，指定具体容器名

Example：
  #持续监听 test pod 的日志
  oc logs -f test-zdgj

  #查看 test pod 中 test1 容器的日志
  oc logs test-zdgj -c test1
```

### 进入pod
```
oc rsh <POD> [COMMAND]

pod的状态必须为Running

Options:
  -c,--container=''                  多个容器时，指定具体容器名

Example：
  #进入 test 的 pod
  oc rsh test-zdgj

  #进入到容器，并执行命令"cat /etc/resolv.conf"
  oc rsh test-zdgj cat /etc/resolv.conf
```

### 文件传输
```
oc rsync <SOURCE> <DESTINATION>

Example：
  #同步本地文件到 pod 中
  oc rsync ./local/dir/  <POD_NAME>:/test

  #同步容器中的文件到本地
  oc rsync <POD_NAME>:/test ./local/dir/
```


### run
```
oc run --image=<IMAGE>

Options:
  --env=[]                          添加环境变量
  --image=''                        镜像名称
  --port=''                         容器公开的端口
  --replicas=1                      pod的副本数
  --restart                         重新启动策略,包括Always, OnFailure, Never 三种策略

Example:
  #用 nginx 镜像启动一个实例 ngx
  oc run ngx --image=nginx

  #启动一个 nginx 实例,并添加环境变量
  oc run ngx --image=nginx  --env='a=b'

  #启动一个副本数为5的实例
  oc run ngx --image=nginx --replicas=5
```

### 拷贝
```
oc cp <FILE_SRC> <FILE_DEST>

ps：
  容器中没有tar命令，则不能使用oc cp命令

Options:
  -c,--container=''                 多个容器时，指定具体容器名

Example：
  #将容器 ngx-1-n2b10 中 /test/11 文件中的内容，拷贝到本地 /t/1 文件中
  oc cp ngx-1-n2b10:test/11 /t/1

  #将容器 ngx-1-n2b10 中 /test/a 文件夹中的内容，拷贝到本地 /t/a 文件夹中
  oc cp ngx-1-n2b10:test/a /t/a
```


## 高级命令

### 创建
```
oc create
```

* #### 创建集群资源配额

```
oc create clusterresourcequota <NAME>


Options:
  --hard                                  限制的资源，RESOURCE=QUANTITY(pods=10)
  --project-annotation-selector=''        注释选择器
  --project-label-selector=''             标签选择器

Example:
#限制某些注释的 project 的 pod 上限是 10
  oc create clusterresourcequota test  --project-annotation-selector=openshift.io/requester=user-bob --hard=pods=10
```

* #### 创建configmap
```
oc create configmap <NAME>

Options:
  --from-file=[]                          指定在 cm 中插入的文件
  --from-literal=[]                       指定在 cm 中插入的文字

Example:
  #基于文件或文件夹创建 configmap
  oc create configmap /test/test

  #创建包含 key1 和 key2 两部分内容的 configmap
  oc create configmap my-config --from-literal=key1=config1 --from-literal=key2=config2

```

* #### 创建deployment
```
oc create deployment <NAME> --image=<IMAGE_TAG>

Example:
  #使用 nginx 镜像创建一个 deployment
  oc create deployment abc --image=nginx:latest
```

* #### 创建deploymentconfig
```
oc create deploymentconfig <NAME> --image=<IMAGE_TAG>

Example:
  #使用 nginx 镜像创建一个 dc
  oc create deploymentconfig abc --image=nginx
```

* #### 创建imagestream
```
oc create imagestream nginx
```

&nbsp;
&nbsp;
  
### 导出模版配置
```
oc export <RESOURCE/NAME> 
以配置的方式导出某一资源

Options:
  -o                                导出的格式类型，常用的有 yaml，json...
Example:
  #按照 json 格式导出 dc test
  oc export dc/test -o json
```

### 提取secret或configmap
```
oc extract <RESOURCE/NAME>

Options:
  --keys                            keys的名字，默认是所有
  --to                              导出的文件路径

Example:
  #导出 ngx 的 configmap 中为 nginx.conf 的 key 到 /tmp 下
  oc extract configmap/nginx --to=/tmp --keys=nginx.conf
```


### 登出
```
oc logout
```

### 显示当前用户
```
oc whoami

Options:
   -t，--show-token         打印当前用户的临时token

Example:
  #查看当前用户的名称
  oc whoami

  #打印当前用户的临时token
  oc whoami -t
```


### 查看版本
```
查看客户端和服务端版本
oc version
```
