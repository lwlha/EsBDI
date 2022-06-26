#!/bin/bash

#########################################
# 安装失败后需要执行bash clean.sh
# 此脚本仅适合搭建学习环境,运行在集群的任意一个节点即可
# 节点之间首先充分配置好免密登录(包括A节点与A节点自己也要配)
# 必须软件安装
# sudo yum install wget psmisc -y
#########################################

# 如果你懒的配置
# 请准备3台机器;分别名为bd01,bd02,bd03;JDK路径为/opt/jdk;用户名为hadoop;充分配置好免密
# 在bd01机器上执行bash install.sh即可
# 

#——————————————————————必选配置-----------------------#
# 选择安装(合理选择，如果安装Hadoop\Hbase则必须勾选安装zookeeper)
# 如果不安装某项，对应的配置项可以直接忽略
hadoop_install="true"
zookeeper_install="true"
spark_install="true"
hbase_install="true"
kafka_install="true"
# 只分发和配置环境变量，需要根据自己情况手动配置
flume_install="true"
#只能使用编译后的文件
redis_install="false"

# redis集群初始化方式
redis_c="redis-cli --cluster create 192.168.0.211:6379 192.168.0.212:6379 192.168.0.213:6379 192.168.0.213:6380 192.168.0.211:6380 192.168.0.212:6380 --cluster-replicas 1"
# jobhistoryserver这里只能写ip
jobhistory_node="192.168.0.202"

# 本机器节点(通讯需要，请先给所有机器设置好hosts文件)
this_node="bd01"
# 所有机器统一使用的用户名
linux_user_name="hadoop"
# 所有机器的jdk路径(请确保所有机器已经安装JDK且都是此路径)
java_path="/opt/jdk"

# 安装包临时文件目录(末尾不要加"/")
temp_dir=~/package
# 缓存数据目录
temp_data_dir=~/bdData
# hadoop、zookeeper等安装目录(末尾不要加"/")
install_dir=~/apps

# 支持网络资源和本地文件
# 例如： 
# hadoop_address="https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz"
# hadoop_address="/home/hadoop/package/hadoop-2.7.7.tar.gz"
# 以上两种路径都可以被支持

# Hadoop版本
# # 如果你已经手动把安装包放在了${temp_dir},并且${hadoop_package_local}设置为true,这里请填写不带后缀的文件名(例如文件名是xxxx.tar.gz,那么这里填xxxx即可)
hadoop_address="https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz"
# Zookeeper版本
# https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
# 同上
zookeeper_address="https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz"
# Spark版本
# https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz
# 同上
spark_address="https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz"
# HBase版本
# https://mirrors.tuna.tsinghua.edu.cn/apache/hbase/2.2.4/hbase-2.2.4-bin.tar.gz
# 同上
hbase_address="https://mirrors.tuna.tsinghua.edu.cn/apache/hbase/2.2.4/hbase-2.2.4-bin.tar.gz"
# Kafka版本
# https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/2.4.1/kafka_2.11-2.4.1.tgz
# 同上
kafka_address="https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/2.4.1/kafka_2.11-2.4.1.tgz"
# flume版本
# https://mirrors.tuna.tsinghua.edu.cn/apache/flume/1.9.0/apache-flume-1.9.0-bin.tar.gz
flume_address="https://mirrors.tuna.tsinghua.edu.cn/apache/flume/1.9.0/apache-flume-1.9.0-bin.tar.gz"
# Redis版本只能使用编译后的文件
redis_address="/home/hadoop/package/redis.tar.gz"


# Hadoop相关节点分配(多个用空格隔开)
# 与Hadoop有关的所有节点(分发安装包使用)
hadoop_all_node=("bd01" "bd02" "bd03")
# namenode高可用日志文件共享节点
journal_node=("bd01" "bd02" "bd03")
# NameNode节点
name_node=("bd01" "bd02")
# yarn主节点
resource_manager=("bd01" "bd02")
data_node=("bd01" "bd02" "bd03")
node_manager=("bd01" "bd02" "bd03")
# Zookeeper节点
zookeeper_node=("bd01" "bd02" "bd03")
# HBase节点
hbase_node=("bd01" "bd02" "bd03")
# Kafka节点
kafka_node=("bd01" "bd02" "bd03")
# klume节点
flume_node=("bd01" "bd02" "bd03")
# Redis节点
redis_node=("bd01" "bd02" "bd03")






#——————————————————————可选配置-----------------------#
# zookeeper数据目录
zookeeper_data_dir=${temp_data_dir}/zookeeper
# Hadoop工作目录(末尾建议加上"/")
hadoop_workspace=${temp_data_dir}/hadoopdata/


# 集群名称
cluster_name="mycluster"
# yarn集群ID
rm_cluster_id="yrc"

# 指定mr框架
mr_framework="yarn"

# 端口
http_namenode_port=50070
rpc_namenode_port=8020
journal_node_port=8485
# 对外端口
zookeeper_port=2181
# zookeeper内部通讯端口
zookeeper_in_port=2888
# zookeeper选主端口
zookeeper_leader_port=3888

jobhistory_service_port=10020
jobhistory_webapp_port=19888
# 副本数量
bak_num=2

# spark默认以yran提交模式安装
spark_yarn_historyServer_address=$this_node:18080
spark_history_ui_port=18080
# 填写hdfs目录，已自动省去前缀
spark_history_fs_logDirectory=/spark/logs
spark_eventLog_dir=/spark/logs
spark_yarn_archive=/spark/libs
spark_yarn_jars=/spark/jars

# Hbase配置
hbase_rootdir=hdfs://${cluster_name}/hbase

# kafka配置
kafka_logs=${temp_data_dir}/kafka

# redis配置
redis_cluster_conf_dir=${temp_data_dir}/redis
