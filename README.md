```shell
安装失败后需要执行:
bash stop-all.sh
bash clean.sh
此脚本仅适合搭建学习环境,运行在集群的任意一个节点即可
节点之间首先充分配置好免密登录(包括A节点与A节点自己也要配)
必须软件安装
sudo yum install wget psmisc -y

如果你懒的配置
请准备3台机器;分别名为bd01,bd02,bd03;JDK路径为/opt/jdk;用户名为hadoop;充分配置好免密
在bd01机器上执行bash install.sh即可
```