# 应用部署

## 镜像选择

### 构建的镜像
通过代码库构建成功的镜像。

![](../images/webuse/run-app-1.png)


### 公共镜像
如果没有构建镜像，也可以直接到公共镜像库中选择镜像使用。


## 部署
如果无特殊要求，确定开放端口正确直接创建即可。
![](../images/webuse/run-app-2.png)

### 高级设置
* 弹性伸缩
根据pod的cpu使用情况自动扩缩容pod的数量。
![](../images/webuse/run-app-3.png)

* 路由设置

![](../images/webuse/run-app-4.png)
