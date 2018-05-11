# 私有镜像库搭建

## 启动私有镜像库
```
docker run -d -p 5000:5000 registry.new.dataos.io/library/registry:2
```

## 导入镜像文件到私有镜像库
```
#导入镜像文件
docker load -i xxx.tar

#修改tag
docker tag xxx:xx  private_registry_ip:5000/xxx:xx

#push
docker push private_registry_ip:5000/xxx:xx
```

## 客户端配置
*创建的私有镜像库需要手动添加信任*
修改/etc/docker/daemon.json文件，添加信任：
```json
vi /etc/docker/daemon.json
{
    "insecure-registries": [
        ...
        "private_registry_ip:5000"
        ...
    ]
}


#重启服务
service docker restart

#客户端测试
docker pull <image>
```

