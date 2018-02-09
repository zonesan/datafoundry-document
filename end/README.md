## 本地使用 GitBook 以及多人协作书写本手册

### 安装 gitbook-cli 
```
$ npm install gitbook-cli -g
```

windows安装参考文档：https://www.cnblogs.com/Lam7/p/6109872.html

### fork 并克隆本项目
```
$ git clone https://github.com/${YOUR_NAME}/datafoundry-document
```
### 安装 gitbook 插件
```
$ cd datafoundry-document
$ gitbook install
```

### 启动 gitbook server
```
$ gitbook serve
```
gitbook 默认启动端口为4000。通过浏览器查看本手册 http://localhost:4000。

文件内容发生变化时，页面会自动刷新。

### Pull Request

提交至自己的仓库，并向[datafoundry-document](https://github.com/asiainfoLDP/datafoundry-document)发起一个 Pull Request。


## 书写规范

本手册将由多人协作完成，为保持文档风格统一和水准，请遵循一定的书写规范。

文档书写规范参考[中文技术文档的写作规范](https://github.com/ruanyf/document-style-guide)以及[文案风格指南](http://open.leancloud.cn/copywriting-style-guide.html)。

## 更多参考链接

* [产品手册中文写作规范](http://wenku.baidu.com/view/23cc1a6527d3240c8447efbf.html), by 华为
* [写作规范和格式规范](http://docs.daocloud.io/write-docs/format), by DaoCloud
* [技术写作技巧在日汉翻译中的应用](http://www.hitachi-tc.co.jp/company/thesis/thesis.pdf), by 刘方
* [简体中文规范指南](https://www.lengoo.de/documents/styleguides/lengoo_styleguide_ZH.pdf), by lengoo
* [文档风格指南](https://open.leancloud.cn/copywriting-style-guide.html), by LeanCloud
* [豌豆荚文案风格指南](https://docs.google.com/document/d/1R8lMCPf6zCD5KEA8ekZ5knK77iw9J-vJ6vEopPemqZM/edit), by 豌豆荚
* [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines), by sparanoid
* [中文排版需求](http://w3c.github.io/clreq/), by W3C
* [为什么文件名要小写？](http://www.ruanyifeng.com/blog/2017/02/filename-should-be-lowercase.html), by 阮一峰
* [Google Developer Documentation Style Guide](https://developers.google.com/style/), by Google

