#openshift部署文档 <br/>

##主机方案 <br>

master*3  etcd*3  node*2  lb*1（每台master机器上同时搭master和etcd）<br>
master负责整个集群调度编排资源管理 <br>
10.174.64.179 <br>
10.174.64.180 <br>
10.174.64.181 <br>
etcd负责集群信息存储 k/v <br>
10.174.64.179 <br>
10.174.64.180 <br>
10.174.64.181 <br>
lb负责master的load balance <br>
10.174.64.182 <br>
node负责执行任务 <br>
10.174.64.183 <br>
10.174.64.184 <br>
ansible负责跑安装集群的ansible-playbook,统一配置集群等（三台master任选一台）<br>
10.174.64.179 <br>
集群外一台机器单独使用部署本地的docker镜像仓库registry，以及service-broker的etcd <br>
10.174.64.184 <br>