Redis cluster -> Redis cluster
## 拉取源码
1.git clone https://github.com/JokerQueue/redis-migrate-tool.git
## 编译
2.yum install automake libtool autoconf bzip2 -y
cd redis-migrate-tool
autoreconf -fvi
./configure
make
## 同步两个集群
3.src/redis-migrate-tool -c rmt.conf -o log -d
