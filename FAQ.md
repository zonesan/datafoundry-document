# 常见问题处理

## ErrImagePull

```
pod的状态为ErrImagePull，oc describe pod <pod_name>为:
Events:
  FirstSeen	LastSeen	Count	From			SubObjectPath		Type		Reason		Message
  ---------	--------	-----	----			-------------		--------	------		-------
  17s		17s		1	default-scheduler				Normal		Scheduled	Successfully assigned ngx3-1-fq1vb to 10.19.14.20
  <invalid>	<invalid>	1	kubelet, 10.19.14.20	spec.containers{ngx3}	Normal		Pulling		pulling image "registry.new.dataos.io/wangyd/nginx:123abc"
  <invalid>	<invalid>	1	kubelet, 10.19.14.20	spec.containers{ngx3}	Warning		Failed		Failed to pull image "registry.new.dataos.io/wangyd/nginx:123abc": rpc error: code = 2 desc = manifest unknown: manifest unknown
  <invalid>	<invalid>	2	kubelet, 10.19.14.20				Warning		FailedSync	Error syncing pod
  <invalid>	<invalid>	1	kubelet, 10.19.14.20	spec.containers{ngx3}	Normal		BackOff		Back-off pulling image "registry.new.dataos.io/wangyd/nginx:123abc"
```
可能由于镜像的tag无效，在镜像库中无法找到镜像。
```
解决方法：
1.oc edit dc/rc <dc/rc_name>

2. 将一下部分修改为有效tag
        image: registry.new.dataos.io/wangyd/nginx:123abc
```



## BUILD Error

```
问题描述：

builder.go:204] Error: build error: API error (404): could not find image: no such id: docker-2054/docker-2048-4:699aa458
```
> 通过bc构建镜像，镜像名与预期不同，正常情况下构建镜像名应该是"內建镜像库 svcip/namespace/imagename:tag",但是在异常节点上构建的镜像名是"library/namespace/imagename:hash_tag",同时在异常节点上通执行sudo docker build -t docker-2048 https://github.com/yepengxj/github.git 得到的镜像名也会自动增加 library/docker-2048.


```
解决方法：

修改 /etc/sysconfig/docker 文件中的
ADD_REGISTRY='--add-registry=index.alauda.cn/library' 为 
ADD_REGISTRY='--add-registry=index.alauda.cn'
```

## route正确，无法访问
```
问题描述：
[root@h-uxm4ntnd ~]# curl  ngx.abc.dataos.io 
curl: (7) Failed connect to ngx.abc.dataos.io:80; Connection refused
```

> 对node节点进行操作后，导致router的pod启动在其他的节点(事先未固定启在某节点)，与域名服务器中配置的泛域名IP不一致.

```
解决方法：
1.修改域名服务器的IP地址为router所在节点的地址。
2.将router固定在某一节点
```

## POD运行状态不同步
```
问题描述：
POD的启动过程事件与POD的最终状态不一致，从POD的启动事件上看POD是已经启动或者完成的，但是POD得最终状态仍然是Creating状态。
```
```
解决方法：
从日志分析可以看出此时kubelet并没有根据POD状态的变化和api server同步状态，在重启服务器后kubelet工作恢复正常。
```
```
查看pod状态：oc get pod
查看pod详细信息：oc describe pod $podname
查看pod日志：oc logs -f $podname
```

## docker pull无法从router的443端口执行
```
问题描述：
执行docker pull时，router返回50x错误.是因为router没有配置为支持https.
```
```
解决方法：
配置router同时支持80和443(加密)的访问。此解决方案适用于所有需要https访问的route.

Example:
    apiVersion: v1
    kind: Route
    metadata:
    labels:
        docker-registry: default
    name: docker-registryspec:
    host: registry.example.com
    port:
        targetPort: 5000-tcp
    tls:
        insecureEdgeTerminationPolicy: Allow
        termination: edge
    to:
        kind: Service
    name: docker-registry
```


## 集群中大量构建提示调用docker api错误（500）
```
解决方法：
集群节点上安装的doker被安装其他软件时升级，openshift无法调用，将docker版本降级后正常.
```

## 通过web或者cli登陆平台是提示500错误
```
解决办法：
1、检查目前平台鉴权方式与用户所对应的鉴权方式是否一致。例如目前平台为ldap鉴权，但是用户所对应的鉴权方式缺位all_allow，如果两者不一致，则通过oc delete user username方式重新设置用户的鉴权方式。

2、identity数据异常，oc delete identity identityname ,其中identityname可以根据登陆用户名判断
```

## build失败，无法push到内置镜像库
```
问题描述：
error: build error: Failed to push image: Put http://docker-registry.default.svc:5000/v1/repositories/mysql-cluster/datafoundryvolume/: dial tcp: lookup docker-registry.default.svc on 10.19.14.20:53: no such host
```

>dns无法解析docker-registry.default.svc

```
解决方法：
手动在/etc/resolv.conf添加
search svc.cluster.local cluster.local
```

## pod一直处于terminating状态资源不释放
```
问题描述：
pod一直处于terminating，无法删除，导致占用资源无法释放。
```
```
解决方法：
1.登录到node节点，将Exited的container删除。
2.重启origin-node服务。
```


## 集群刚搭建完成，无法调度或创建pod
```
问题描述:
pod无法正常启动，oc describe pod <pod_name>，events如下提示：
Events:
  FirstSeen	LastSeen	Count	From			SubObjectPath		Type		Reason		Message
  ---------	--------	-----	----			-------------		--------	------		-------
  3m		3m		1	default-scheduler				Normal		Scheduled	Successfully assigned ngx2-1-h8f4x to 10.19.14.20
  3m		2m		4	kubelet, 10.19.14.20				Warning		FailedSync	Error syncing pod
  3m		2m		4	kubelet, 10.19.14.20	spec.containers{ngx2}	Normal		Pulling		pulling image "registry.new.dataos.io/wangyd/nginx:latest"
  3m		2m		4	kubelet, 10.19.14.20	spec.containers{ngx2}	Normal		Pulled		Successfully pulled image "registry.new.dataos.io/wangyd/nginx:latest"
  3m		2m		4	kubelet, 10.19.14.20	spec.containers{ngx2}	Normal		Created		Created container
  3m		2m		4	kubelet, 10.19.14.20	spec.containers{ngx2}	Normal		Started		Started container
  3m		2m		5	kubelet, 10.19.14.20	spec.containers{ngx2}	Warning		BackOff		Back-off restarting failed container
```

>新搭建的集群，scc为默认设置，重新设置一下。

```
解决方法：
1.oc edit scc restricted

2.删除以下部分：
requiredDropCapabilities:
- KILL
- MKNOD
- SYS_CHROOT
- SETUID
- SETGID

3.修改
runAsUser:
  type: MustRunAsRange
为：
runAsUser:
  type: RunAsAny
保存退出。
```
