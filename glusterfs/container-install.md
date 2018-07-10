# 容器安装GlusterFS

>详情参照官网：https://docs.openshift.com/container-platform/3.7/install_config/install/advanced_install.html#advanced-install-glusterfs-persistent-storage


**所需镜像**
```
registry.new.dataos.io/glusterfs/glusterblock-provisioner
registry.new.dataos.io/glusterfs/gluster-centos
registry.new.dataos.io/glusterfs/heketi:4-danli-build
docker.io/heketi/heketi:dev
```

**注意事项：**
离线安装环境中，每个节点都需要docker.io/heketi/heketi:dev镜像，不要更换tag。



## 初始化磁盘

登录到需要安装的节点，使用以下任意一条命令初始化磁盘：

*为了节约时间建议使用第一条命令*
```
pvcreate --metadatasize=128M --dataalignment=256K /dev/vdc
shred -v /dev/vdc
dd if=/dev/zero of=/dev/vdc bs=1M
```

## 修改hosts文件
在hosts文件添加以下内容：
```
[OSEv3:children]
glusterfs
...


[OSEv3:vars]
#glusterfs
openshift_storage_glusterfs_namespace=glusterfs
openshift_storage_glusterfs_name=storage

##gluster image
openshift_storage_glusterfs_image=registry.new.dataos.io/glusterfs/gluster-centos
openshift_storage_glusterfs_version=latest

##glusterfs-provisioner image
openshift_storage_glusterfs_block_image=registry.new.dataos.io/glusterfs/glusterblock-provisioner
openshift_storage_glusterfs_block_version=latest

##heketi image
openshift_storage_glusterfs_heketi_image=registry.new.dataos.io/glusterfs/heketi
openshift_storage_glusterfs_heketi_version=4-danli-build
...

[glusterfs]
10.19.14.19 glusterfs_ip=10.19.14.19 glusterfs_devices='[ "/dev/vdb2" ]'
10.19.14.20 glusterfs_ip=10.19.14.20 glusterfs_devices='[ "/dev/vdb2" ]'
10.19.14.21 glusterfs_ip=10.19.14.21 glusterfs_devices='[ "/dev/vdc2" ]'
```


## 执行ansible-playbook
```
ansible-playbook -i hosts \
3.6/openshift-ansible/playbooks/byo/openshift-glusterfs/config.yaml
```


生成的router可能是不可用的，具体router 要根据你集群绑定的域名自己导出来一个可用的router




## 创建pvc
通过pvc.yaml文件创建pvc,storageClassName与StorageClass名字匹配
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: test1
spec:
 accessModes:
  - ReadWriteMany
 resources:
   requests:
        storage: 1Gi
 storageClassName: gluster-heketi
```

```
#查看pvc
oc get pvc

#显示为以下内容即为正常创建
NAME      STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS     AGE
test1     Bound     pvc-312d4648-840e-11e8-aa7d-fa163e6d21ac   1Gi        RWX           gluster-heketi   9s
```
