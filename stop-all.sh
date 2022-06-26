source config.sh

for((i=0;i<${#redis_node[@]};i++))
do
ssh "${linux_user_name}@${redis_node[i]}" > /dev/null 2>&1 << redisstop
ps -ef|grep redis|awk '{print \$2}'|xargs kill -9
exit
redisstop
done
echo "redis已停止"

for((i=0;i<${#flume_node[@]};i++))
do
ssh "${linux_user_name}@${flume_node[i]}" > /dev/null 2>&1 << flumestop
ps -ef|grep flume|awk '{print \$2}'|xargs kill -9
exit
flumestop
done
echo "flume已停止"

for((i=0;i<${#kafka_node[@]};i++))
do
ssh "${linux_user_name}@${kafka_node[i]}" > /dev/null 2>&1 << kafkastop
kafka-server-stop.sh
exit
kafkastop
done
echo "kafka已停止"

ssh "${linux_user_name}@${hbase_node[0]}" > /dev/null 2>&1 << hbasestop
stop-hbase.sh
exit
hbasestop
echo "hbasae已停止"

ssh "${linux_user_name}@${this_node}" > /dev/null 2>&1 << sparkhistorystop
stop-history-server.sh
exit
sparkhistorystop
echo "spark-history已停止"

for((i=0;i<${#name_node[@]};i++))
do
ssh "${linux_user_name}@${name_node[i]}" > /dev/null 2>&1 << startstop
stop-dfs.sh
exit
startstop
done
echo "name_node已停止"

ssh "${linux_user_name}@${jobhistory_node}" > /dev/null 2>&1 << jobhistorystop
mr-jobhistory-daemon.sh stop historyserver
exit
jobhistorystop
echo "jobhistory_node已停止"

for((i=0;i<${#resource_manager[@]};i++))
do
ssh "${linux_user_name}@${resource_manager[i]}" > /dev/null 2>&1 << stopyarn
stop-yarn.sh
exit
stopyarn
done
echo "resource_manager已停止"

# zookeeper停止
for((i=0;i<${#zookeeper_node[@]};i++))
do
ssh "${linux_user_name}@${zookeeper_node[i]}" > /dev/null 2>&1 << zookeeperstop
zkServer.sh stop
rm -f ~/zookeeper.out
exit
zookeeperstop
done
echo "zookeeper已停止"

echo "停止完成"