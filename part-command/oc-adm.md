# 管理员命令
```
oc adm
```

**创建新的project**
```
oc adm new-project <NAME>

Options:
  --admin                             project 管理员名称
  --description                       project 描述
  --display-name                      project 显示名称
  --node-selector                     project 中的 pod 只能在指定标签的 node 节点启动

Example:
  #创建一个 test 的 project，且 pod 只能在 node=n1 的节点启动
  oc adm new-project test --node-selector='node=n1'
```


**策略**
```
oc adm policy
```

```
remove-user                           从当前项目删除用户
remove-group                          从当前项目删除组

add-role-to-group                     为当前项目添加一个组

add-cluster-role-to-user              添加用户集群管理员权限
remove-cluster-role-from-user         删除用户集群管理员权限
```

```
add-role-to-user                      为当前项目添加一个角色或者一个 serviceaccount

Option：
  -z, --serviceaccount                指定 serviceaccount 名称

Example：
  #给 user1 添加当前 project view 权限
  oc adm policy add-role-to-user view user1
```

**管理节点**
```
oc adm manage-node

Options:
  --force                             删除不被副本控制器支持的pod
  --grace-period                      删除等待延迟
  --list-pods                         列出节点 pod 目录
  --pod-selector=''                   指定 node 节点的标签选择器
  --schedulable                       控制节点是否开启调度
  --selector=''                       节点标签选择器

Example:
  #关闭 mynode 的调度，此 node 节点将不再起 pod
  oc adm manage-node <mynode> --schedulable=false

  #迁移选择的 pod 到其他节点
  oc adm manage-node <mynode> --evacuate --pod-selector="<service=myapp>"

  #列出 mynode1 下的所有 pod
  oc adm manage-node <mynode1> --list-pods
```


**节点调度管理**
```
oc adm cordon <mynode>        关闭节点调度
oc adm uncordon <mynode>      开启节点调度
```

```
oc adm drain <mynode>         关闭节点调度并驱逐节点上的pod
```


