# yum源搭建

## 安装基础工具
```
yum install httpd createrepo
```

## 解压包文件
```
tar -xf yumrepo.tar -C /var/www/html/
```

## 创建repo  
```
createrepo /var/www/html/base/  
createrepo /var/www/html/xxxx/  
```

## 客户端配置repo文件
```
cat /etc/yum.repos.d/local.repo
[base]
name=base
baseurl=http://10.1.1.x/base
enabled=1
gpgcheck=0
```
