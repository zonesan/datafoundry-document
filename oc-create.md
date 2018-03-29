# 创建

```
oc create
```

**集群资源配额**

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

**ConfigMap**
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

**deployment**
```
oc create deployment <NAME> --image=<IMAGE_TAG>

Example:
  #使用 nginx 镜像创建一个 deployment
  oc create deployment abc --image=nginx:latest
```

**deployment config**
```
oc create deploymentconfig <NAME> --image=<IMAGE_TAG>

Example:
  #使用 nginx 镜像创建一个 dc
  oc create deploymentconfig abc --image=nginx
```

**image stream**
```
oc create imagestream nginx
```


