source config.sh
for((i=0;i<${#hadoop_all_node[@]};i++))
do
ssh "${linux_user_name}@${hadoop_all_node[i]}" > /dev/null 2>&1 << cleans
rm -rf "${install_dir}"
rm -rf "${temp_data_dir}"
rm -rf /tmp/*hadoop* /tmp/*journal* /tmp/Jetty* /tmp/*spark* /tmp/*hbase* /tmp/*kafka* /tmp/*flume* /tmp/*redis*
sed -i '/HADOOP_HOME/d' ~/.bashrc
sed -i '/ZOOKEEPER_HOME/d' ~/.bashrc
sed -i '/SPARK_HOME/d' ~/.bashrc
sed -i '/HBASE_HOME/d' ~/.bashrc
sed -i '/KAFKA_HOME/d' ~/.bashrc
sed -i '/FLUME_HOME/d' ~/.bashrc
sed -i '/REDIS_HOME/d' ~/.bashrc
exit
cleans
echo "完成${hadoop_all_node[i]}"
done
