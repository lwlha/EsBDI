source config.sh

# zookeeper启动
for((i=0;i<${#zookeeper_node[@]};i++))
do
ssh "${linux_user_name}@${zookeeper_node[i]}" > /dev/null 2>&1 << zookeeperstart
zkServer.sh start
exit
zookeeperstart
done
echo "zookeeper启动完成"

# 启动spark-jobhistory
if [ $hadoop_install == "true" ]
then
for((i=0;i<${#name_node[@]};i++))
do
ssh "${linux_user_name}@${name_node[i]}" > /dev/null 2>&1 << startdfs
start-dfs.sh
exit
startdfs
done
echo "NameNode启动完成"

for((i=0;i<${#resource_manager[@]};i++))
do
ssh "${linux_user_name}@${resource_manager[i]}" > /dev/null 2>&1 << startyarn
start-yarn.sh
exit
startyarn
done
echo "Yarn启动完成"

ssh "${linux_user_name}@${jobhistory_node}" > /dev/null 2>&1 << jobhistorystart
mr-jobhistory-daemon.sh start historyserver
exit
jobhistorystart
echo "jobhistory启动完成"
fi

# 启动spark-jobhistory
if [ $spark_install == "true" ]
then
echo "启动spark-jobhistory"
hdfs dfs -mkdir -p /spark/logs
hdfs dfs -mkdir -p /spark/jars
start-history-server.sh > /dev/null 2>&1
fi

# 启动hbase
if [ $hbase_install == "true" ]
then
echo "启动hbase"
hdfs dfs -mkdir -p /hbase
start-hbase.sh > /dev/null 2>&1
fi

# 启动kafka
if [ $kafka_install == "true" ]
then
echo "启动kafka"
for((i=0;i<${#kafka_node[@]};i++))
do
ssh "${linux_user_name}@${kafka_node[i]}" > /dev/null 2>&1 << kafkastart
kafka-server-start.sh -daemon ${KAFKA_HOME}/config/server.properties
exit
kafkastart
done
fi

# 启动redis
if [ $redis_install == "true" ]
then
echo "启动redis"
for((i=0;i<${#redis_node[@]};i++))
do
ssh "${linux_user_name}@${redis_node[i]}" > /dev/null 2>&1 << redisstart
cd ${redis_cluster_conf_dir}/6379
redis-server ./redis.conf
cd ${redis_cluster_conf_dir}/6380
redis-server ./redis.conf
exit
redisstart
done
fi

#------------------------------------------------------------------------------------------------#
# 显示
echo "hadoop UI:${name_node[0]}:50070.${name_node[1]}:50070"
echo "hadoop history UI:${jobhistory_node}:8088"
echo "spark history UI:${this_node}:18080"
echo "hbase UI:${name_node[0]}:16010"