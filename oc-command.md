# 常用命令
* [基础命令](#basic)
* [构建和部署命令](#buildDeploy)
* [应用管理](#appManagement)

## <span id="basic">基础命令</span>

**各种类型的介绍**

    oc types

**登录集群**

    oc login <server_url>

    Options:
       -u, --username=''  用户名 
       -p, --password=''  密码  
    
    Example:
    
     #使用abc用户登录10.19.14.19集群
     oc login 10.19.14.19:8443 -u abc -p abc
    
**创建新的project**

    oc new-project <name>
    
    Options:
      --description=''   project 的描述
      --display-name=''  project 的显示名称
    
    Example:
    
     #创建一个test的project
     oc new-project test



**创建应用**

    oc new-app <image | imageStream | template | Dockerfile path | Dockerfile url>

    Options:           
      -e, --env=[]               添加 dc 中的环境变量
      -f, --file=[]              指定应用 template 文件路径
      -i, --image-stream=[]      使用的 Image Stream 名称
      --insecure-registry=false  如果为 true,表示对镜像库绕过证书检查 
      -l, --labels=''            设置应用的标签
      --name=''                  设置应用名称(包括 bc、dc的名称)
      --template=[]              指定应用 template 的名称

      Example:
      
       #使用git的url创建一个应用
       oc new-app https://github.com/openshift/ruby-ex.git

**显示所在 project**

    oc project

**切换 project**

    oc project <project name>

    Example:

     #切换到test2的project
     oc project test2

**列出用户权限下的所有 project**

    oc projects
    oc get project

## <span id="buildDeploy">构建和部署命令</span>

**部署**

    oc rollout [command] dc/<dcName>

    Available Commands:
      cancel      取消部署
      latest      启动最新部署
      retry       重试最新失败的部署
      status      查看部署状态

    Example：

     #将dc-test部署为最新版本
     oc rollout latest dc/dc-test

**回滚**

    oc rollback <dcName>   回滚到最后一个成功的部署

    Example:

     #将dc-test回滚到上一个成功部署的版本
     oc rollback dc-test

**新建构建镜像**

    oc new-build <url | path ... >      用于构建一个新的镜像

    Options：
      -e, --env=[]               设置镜像的键值对环境变量
      -i, --image-stream=[]      构建成的 imageStream 名称
      -l, --labels=''            添加label

    Example:

      #根据当前目录下的Dockerfile文件，构建一个tag名为test的镜像
      oc new-build . --name=test

**启动构建镜像**

    oc start-build <bc>          启动构建
    
    Example:

    #根据bc-test的bc开始构建镜像
    oc start-build bc-test


**取消构建镜像**

    oc cancel-build <bcNmae>     取消构建

    Example：

    #取消bc-test的bc的镜像构建
    oc cancel-build bc-test

**添加tag**

    oc tag <source> <dest>     将镜像修改一个新的tag,类似于docker tag

    Example：

    #将tag为test1:latest的镜像,添加一个名称为test2:latest的tag
    oc tag test1 test2:latest


## <span id="appManagement">应用管理</span>

**列出一种或多种资源类型**

    oc get <type/name>     typeName可以是 oc types 看到的所有 type
    
    Options：
      --all-namespaces    列出所有namespaces类型资源
      -o, --output=''     输出格式，可以是 yaml、json、wide、name...
      --show-labels       列出label
      -w, --watch         持续监听

    Example：

    #列出当前namespaces下的pod
    oc get pod

    #列出当前namespaces下pod的更多信息
    oc get pod -o wide

    #以yaml格式输出名为 test 单个 pod 的信息
    oc get pod test -o yaml

    #列出所有 namespaces 的 pod
    oc get pod --all-anmespaces

    #列出 node 节点的 label
    oc get node --show-labels


**显示资源类型的详情信息**

    oc describe < type/name >
     
    Options:
      --all-namespaces    列出所有namespaces类型资源

    Example:
    
    #查看名为test的pod的详情信息
    oc describe pod/test

    #查看当前namespace下的所有pod的详情信息
    oc describe pod

**修改资源类型**

    oc edit <type/name>

    Example:

    #修改名为 test1 的 svc
    oc edit svc test1

    #修改名为 test1 的 dc
    #oc edit dc/test1

**配置应用的资源**  

       oc set <COMMAND>


* env

      oc set env 
    
      Options：
        --all                       指定范围为全部
        --list                      列出所有环境变量
        --overwrite                 如果为 true,允许环境变量被覆盖
        -c, --containers            当pod中有多个container时，通过此参数指定具体的container，* 表示pod中的所有容器

      Example：
        #为test1的dc添加一组环境变量
        oc set env dc/test1 NUMBER="1"

        #列出test1的dc所有环境变量
        oc set env dc/test --list

        #删除test dc的NUMBER环境变量
        oc set env dc/test NUMBER-


* resources
    
      oc set resources

      Options:
      --limits=''              整个  pod 所能请求的最大资源
      --requests=''            pod 创建时所请求的资源
      -c, --containers         当pod中有多个container时，通过此参数指定具体的container，* 表示pod中的所有容器
      
      Example：

      #限制dc test中创建container1时最大的请求资源
      
      oc set resources dc test -c=container1 --limits=cpu=100m,memory=100Mi

      #限制dc test的最大资源是100m cpu 100Mi内存，创建pod时的pod的大小为30m cpu 30Mi内存

      oc set resources dc test --limits=cpu=100m,memory=100Mi --requests=cpu=30m,memory=30Mi

      #移除资源请求
      oc set resources dc/test --limits=cpu=0,memory=0 --requests=cpu=0,memory=0

      




    

      















