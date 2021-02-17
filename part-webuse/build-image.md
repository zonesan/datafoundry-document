# 构建镜像

## 新建构建

![](../images/webuse/build-image-1.png)

## 代码库选择

### 绑定代码库
可以直接通过绑定github或者gitlab来构建自己git仓库中的项目。

![](../images/webuse/build-image-2.png)

### 自定义代码库
也可以直接使用git仓库的url。

![](../images/webuse/build-image-3.png)

## 构建镜像
点击查看构建日志。

![](../images/webuse/build-image-4.png)

提示 Push successful 则镜像构建成功。构建状态显示为构建成功。

![](../images/webuse/build-image-5.png)

报错通过查看构建日志，调整Dockerfile。