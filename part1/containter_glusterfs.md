##容器安装glusterfs

具体参照官网：<br>
https://docs.openshift.com/container-platform/3.7/install_config/install/advanced_install.html#advanced-install-glusterfs-persistent-storage


修改hosts文件
>[OSEv3:children] <br>
masters <br>
etcd <br>
nodes <br>
lb <br>
glusterfs <br>
。。。。。。。<br>
[OSEv3:vars] <br>
openshift_storage_glusterfs_namespace=glusterfs <br>
openshift_storage_glusterfs_name=storage <br>

>[glusterfs] <br>
10.19.14.19 glusterfs_ip=10.19.14.19 glusterfs_devices='[ "/dev/vdb2" ]' <br>
10.19.14.20 glusterfs_ip=10.19.14.20 glusterfs_devices='[ "/dev/vdb2" ]' <br>
10.19.14.21 glusterfs_ip=10.19.14.21 glusterfs_devices='[ "/dev/vdc2" ]’ <br>

执行ansible-playbook

    ansible-playbook -i hosts 3.6/openshift-ansible/playbooks/byo/openshift-glusterfs/config.yaml


<font color=#FF4500 size=3>注：sudo pvcreate --metadatasize=128M --dataalignment=256K /dev/vdc
这一步一定要先执行，先把物理盘做成pv，glusterfs会自动创建vg</font>

生成的router是不可用的，具体router 要根据你集群绑定的域名自己导出来一个可用的router