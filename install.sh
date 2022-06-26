
source config.sh

#------------------------------------------------------------------------------------------------#

mkdir -p "${install_dir}"
mkdir -p "${temp_dir}/logs"
mkdir -p "${temp_data_dir}"
mkdir -p "${zookeeper_data_dir}"
mkdir -p "${redis_cluster_conf_dir}"

# hadoop解压文件夹名
hadoop_address_array=(${hadoop_address//// })
hadoop_file_name=${hadoop_address_array[-1]}
if [ ${hadoop_file_name:0-4:4} == ".tgz" ]
then
	hadoop_dir=${hadoop_file_name:0:-4}
else
	hadoop_dir=${hadoop_file_name:0:-7}
fi
# zk解压文件夹名
zookeeper_address_array=(${zookeeper_address//// })
zookeeper_file_name=${zookeeper_address_array[-1]}
if [ ${zookeeper_file_name:0-4:4} == ".tgz" ]
then
	zookeeper_dir=${zookeeper_file_name:0:-4}
else
	zookeeper_dir=${zookeeper_file_name:0:-7}
fi
# spark解压文件夹名
spark_address_array=(${spark_address//// })
spark_file_name=${spark_address_array[-1]}
if [ ${spark_file_name:0-4:4} == ".tgz" ]
then
	spark_dir=${spark_file_name:0:-4}
else
	spark_dir=${spark_file_name:0:-7}
fi

# hbase解压文件夹名
hbase_address_array=(${hbase_address//// })
hbase_file_name=${hbase_address_array[-1]}
if [ ${hbase_file_name:0-4:4} == ".tgz" ]
then
	hbase_dir=${hbase_file_name:0:-8}
else
	hbase_dir=${hbase_file_name:0:-11}
fi

# kafka解压文件夹名
kafka_address_array=(${kafka_address//// })
kafka_file_name=${kafka_address_array[-1]}
if [ ${kafka_file_name:0-4:4} == ".tgz" ]
then
	kafka_dir=${kafka_file_name:0:-4}
else
	kafka_dir=${kafka_file_name:0:-7}
fi

# flume解压文件夹名
flume_address_array=(${flume_address//// })
flume_file_name=${flume_address_array[-1]}
if [ ${flume_file_name:0-4:4} == ".tgz" ]
then
	flume_dir=${flume_file_name:0:-4}
else
	flume_dir=${flume_file_name:0:-7}
fi

# redis解压文件夹名
redis_address_array=(${redis_address//// })
redis_file_name=${redis_address_array[-1]}
if [ ${redis_file_name:0-4:4} == ".tgz" ]
then
	redis_dir=${redis_file_name:0:-4}
else
	redis_dir=${redis_file_name:0:-7}
fi

#------------------------------------------------------------------------------------------------#
# 下载并解压
if [ $hadoop_install == "true" ]
then
	if [ ${hadoop_address:0:1} == "/" ]
   	then
		mv "${hadoop_address}" "${temp_dir}/"
	else
   		wget -P "${temp_dir}/" "${hadoop_address}"
   	fi
   	echo "开始解压Hadoop"
   	tar -zxPf "${temp_dir}/${hadoop_file_name}" -C "${install_dir}/"
fi

if [ $zookeeper_install == "true" ]
then
	if [ ${zookeeper_address:0:1} == "/" ]
   	then
		mv "${zookeeper_address}" "${temp_dir}/"
	else
   		wget -P "${temp_dir}/" "${zookeeper_address}"
   	fi
   	echo "开始解压zookeeper"
   	tar -zxPf "${temp_dir}/${zookeeper_file_name}" -C "${install_dir}/"
fi

if [ $spark_install == "true" ]
then
	if [ ${spark_address:0:1} == "/" ]
   	then
		mv "${spark_address}" "${temp_dir}/"
	else
   		wget -P "${temp_dir}/" "${spark_address}"
   	fi
   	echo "开始解压Spark"
   	tar -zxPf "${temp_dir}/${spark_file_name}" -C "${install_dir}/"
fi

if [ $hbase_install == "true" ]
then
	if [ ${hbase_address:0:1} == "/" ]
   	then
		mv "${hbase_address}" "${temp_dir}/"
	else
   		wget -P "${temp_dir}/" "${hbase_address}"
   	fi
   	echo "开始解压Hbase"
   	tar -zxPf "${temp_dir}/${hbase_file_name}" -C "${install_dir}/"
fi

if [ $kafka_install == "true" ]
then
	if [ ${kafka_address:0:1} == "/" ]
   	then
		mv "${kafka_address}" "${temp_dir}/"
	else
   		wget -P "${temp_dir}/" "${kafka_address}"
   	fi
   	echo "开始解压Kafka"
   	tar -zxPf "${temp_dir}/${kafka_file_name}" -C "${install_dir}/"
fi

if [ $flume_install == "true" ]
then
	if [ ${flume_address:0:1} == "/" ]
   	then
		mv "${flume_address}" "${temp_dir}/"
	else
   		wget -P "${temp_dir}/" "${flume_address}"
   	fi
   	echo "开始解压Flume"
   	tar -zxPf "${temp_dir}/${flume_file_name}" -C "${install_dir}/"
fi

if [ $redis_install == "true" ]
then
	if [ ${redis_address:0:1} == "/" ]
   	then
		mv "${redis_address}" "${temp_dir}/"
	else
   		wget -P "${temp_dir}/" "${redis_address}"
   	fi
   	echo "开始解压Redis"
   	tar -zxPf "${temp_dir}/${redis_file_name}" -C "${install_dir}/"
fi
#------------------------------------------------------------------------------------------------#
if [ $hadoop_install == "true" ]
then	
	# 修改hadoop-env.sh的JAVA_HOME项
	# 生成日志文件
	sed -n "s|\${JAVA_HOME}|${java_path}|gp" "${install_dir}/${hadoop_dir}/etc/hadoop/hadoop-env.sh" > "${temp_dir}/logs/hadoop-env.sh.log"
	# 替换
	sed -i "s|\${JAVA_HOME}|${java_path}|" "${install_dir}/${hadoop_dir}/etc/hadoop/hadoop-env.sh"


	# 修改core-site.xml
	echo "修改core-site.xml"
	# 加载文件
	core_site=$(cat ./resource/core-site-sub.xml)
	# 替换集群名称
	core_site="${core_site//\$\{cluster_name\}/${cluster_name}}"
	# 替换Hadoop工作目录
	core_site="${core_site//\$\{hadoop_workspace\}/${hadoop_workspace}}"
	# 替换zookeeper集群访问地址
	zookeeper_cluster_address="${zookeeper_node[$[${#zookeeper_node[@]} - 1]]}:${zookeeper_port}"
	for((i=$[${#zookeeper_node[@]} - 2];i>-1;i--))
	do
		zookeeper_cluster_address="${zookeeper_node[i]}:${zookeeper_port},${zookeeper_cluster_address}"
	done
	core_site="${core_site//\$\{zookeeper_cluster_address\}/${zookeeper_cluster_address}}"
	# 生成日志文件
	sed -n "s|<configuration>|&${core_site}|p" "${install_dir}/${hadoop_dir}/etc/hadoop/core-site.xml" > "${temp_dir}/logs/core-site.xml.log"
	# 替换
	sed -i "s|<configuration>|&${core_site}|" "${install_dir}/${hadoop_dir}/etc/hadoop/core-site.xml"


	# 修改hdfs-site.xml
	echo "修改hdfs-site.xml"
	# 加载文件
	hdfs_site=$(cat ./resource/hdfs-site-sub.xml)
	# 替换集群名称
	hdfs_site="${hdfs_site//\$\{cluster_name\}/${cluster_name}}"
	# 替换rpc_namenode
	hdfs_site="${hdfs_site//\$\{rpc_namenode01\}/${name_node[0]}:${rpc_namenode_port}}"
	hdfs_site="${hdfs_site//\$\{rpc_namenode02\}/${name_node[1]}:${rpc_namenode_port}}"
	# 替换http_namenode
	hdfs_site="${hdfs_site//\$\{http_namenode01\}/${name_node[0]}:${http_namenode_port}}"
	hdfs_site="${hdfs_site//\$\{http_namenode02\}/${name_node[1]}:${http_namenode_port}}"
	# 替换bak_num
	hdfs_site="${hdfs_site//\$\{bak_num\}/${bak_num}}"
	# 替换journal集群访问地址
	journal_cluster_address="${journal_node[$[${#journal_node[@]} - 1]]}:${journal_node_port}"
	for((i=`expr ${#journal_node[@]} - 2`;i>-1;i--))
	do
		journal_cluster_address="${journal_node[i]}:${journal_node_port};${journal_cluster_address}"
	done
	hdfs_site="${hdfs_site//\$\{journal_cluster_address\}/${journal_cluster_address}}"
	# 生成日志文件
	sed -n "s|<configuration>|&${hdfs_site}|p" "${install_dir}/${hadoop_dir}/etc/hadoop/hdfs-site.xml" > "${temp_dir}/logs/hdfs-site.xml.log"
	# 替换
	sed -i "s|<configuration>|&${hdfs_site}|" "${install_dir}/${hadoop_dir}/etc/hadoop/hdfs-site.xml"


	# 修改mapred-site.xml
	echo "修改mapred-site.xml"
	# 加载文件
	mapred_site=$(cat ./resource/mapred-site-sub.xml)
	# 替换mr框架
	mapred_site="${mapred_site//\$\{mr_framework\}/${mr_framework}}"
	# 替换mapreduce的历史服务器地址和端口号
	mapred_site="${mapred_site//\$\{jobhistory_address\}/${jobhistory_node}:${jobhistory_service_port}}"
	# mapreduce历史服务器的web访问地址
	mapred_site="${mapred_site//\$\{jobhistory_webapp\}/${jobhistory_node}:${jobhistory_webapp_port}}"
	# 生成日志文件
	echo "${mapred_site}" > "${temp_dir}/logs/mapred-site.xml.log"
	# 生成文件
	echo "${mapred_site}" > "${install_dir}/${hadoop_dir}/etc/hadoop/mapred-site.xml"


	# 修改yarn-site.xml
	echo "修改yarn-site.xml"
	# 加载文件
	yarn_site=$(cat ./resource/yarn-site-sub.xml)
	# 替换yarn集群ID
	yarn_site="${yarn_site//\$\{rm_cluster_id\}/${rm_cluster_id}}"
	# 替换yarn集群主节点ID
	yarn_site="${yarn_site//\$\{rm01\}/${resource_manager[0]}}"
	yarn_site="${yarn_site//\$\{rm02\}/${resource_manager[1]}}"
	# 替换zookeeper集群主节点ID
	yarn_site="${yarn_site//\$\{zookeeper_cluster_address\}/${zookeeper_cluster_address}}"
	# 生成日志文件
	sed -n "s|<configuration>|&${yarn_site}|p" "${install_dir}/${hadoop_dir}/etc/hadoop/yarn-site.xml" > "${temp_dir}/logs/yarn-site.xml.log"
	# 生成文件
	sed -i "s|<configuration>|&${yarn_site}|" "${install_dir}/${hadoop_dir}/etc/hadoop/yarn-site.xml"

	# 修改slaves
	echo "修改slaves"
	echo "${data_node[0]}" > "${install_dir}/${hadoop_dir}/etc/hadoop/slaves"
	for((i=1;i<${#data_node[@]};i++))
	do
		echo "${data_node[i]}" >> "${install_dir}/${hadoop_dir}/etc/hadoop/slaves"
	done
fi

#------------------------------------------------------------------------------------------------#
# zookeeper配置
if [ $zookeeper_install == "true" ]
then
	echo "创建zoo.cfg"
	# 创建zoo.cfg
	cp "${install_dir}/${zookeeper_dir}/conf/zoo_sample.cfg" "${install_dir}/${zookeeper_dir}/conf/zoo.cfg"
	# 修改zoo.cfg
	# 替换数据目录生成日志
	sed -n "s|dataDir=/tmp/zookeeper|dataDir=${zookeeper_data_dir}|gp" "${install_dir}/${zookeeper_dir}/conf/zoo.cfg" >> "${temp_dir}/logs/zoo.cfg.log"
	# 替换
	sed -i "s|dataDir=/tmp/zookeeper|dataDir=${zookeeper_data_dir}|" "${install_dir}/${zookeeper_dir}/conf/zoo.cfg"

	# 替换端口生成日志
	sed -n "s|clientPort=2181|clientPort=${zookeeper_port}|gp" "${install_dir}/${zookeeper_dir}/conf/zoo.cfg" >> "${temp_dir}/logs/zoo.cfg.log"
	# 替换
	sed -i "s|clientPort=2181|clientPort=${zookeeper_port}|" "${install_dir}/${zookeeper_dir}/conf/zoo.cfg"

	for((i=0;i<${#zookeeper_node[@]};i++))
	do
		echo "server.`expr ${i} + 1`=${zookeeper_node[i]}:${zookeeper_in_port}:${zookeeper_leader_port}" >> "${install_dir}/${zookeeper_dir}/conf/zoo.cfg"
	done
fi

#------------------------------------------------------------------------------------------------#
# spark配置
if [ $spark_install == "true" ]
then
	echo "复制spark-env.sh"
	# 创建spark-env.sh
	cp "${install_dir}/${spark_dir}/conf/spark-env.sh.template" "${install_dir}/${spark_dir}/conf/spark-env.sh"
	# 日志
	echo "export YARN_CONF_DIR=${install_dir}/${hadoop_dir}/etc/hadoop" > "${temp_dir}/logs/spark-env.sh.log"
	# 修改spark-env.sh
	echo "export YARN_CONF_DIR=${install_dir}/${hadoop_dir}/etc/hadoop" >> "${install_dir}/${spark_dir}/conf/spark-env.sh"

	echo "复制spark-defaults.conf.template"
	# 创建spark-defaults.conf.template
	cp "${install_dir}/${spark_dir}/conf/spark-defaults.conf.template" "${install_dir}/${spark_dir}/conf/spark-defaults.conf"
	# 日志
	echo -e "spark.yarn.historyServer.address ${spark_yarn_historyServer_address}\nspark.history.ui.port              ${spark_history_ui_port}\nspark.history.fs.logDirectory      hdfs://${cluster_name}${spark_history_fs_logDirectory}\nspark.eventLog.enabled             true\nspark.eventLog.dir                 hdfs://${cluster_name}${spark_eventLog_dir}\nspark.eventLog.compress            true\nspark.yarn.archive                 hdfs://${cluster_name}${spark_yarn_archive}/spark-jars.tar.gz\nspark.yarn.jars                    hdfs://${cluster_name}${spark_yarn_jars}" > "${temp_dir}/logs/spark-defaults.conf.log"
	# 修改spark-defaults.conf
	echo -e "spark.yarn.historyServer.address ${spark_yarn_historyServer_address}\nspark.history.ui.port              ${spark_history_ui_port}\nspark.history.fs.logDirectory      hdfs://${cluster_name}${spark_history_fs_logDirectory}\nspark.eventLog.enabled             true\nspark.eventLog.dir                 hdfs://${cluster_name}${spark_eventLog_dir}\nspark.eventLog.compress            true\nspark.yarn.archive                 hdfs://${cluster_name}${spark_yarn_archive}/spark-jars.tar.gz\nspark.yarn.jars                    hdfs://${cluster_name}${spark_yarn_jars}" >> "${install_dir}/${spark_dir}/conf/spark-defaults.conf"
fi
#------------------------------------------------------------------------------------------------#
# Hbase配置
if [ $hbase_install == "true" ]
then
	# 修改hbase-env.sh
	echo "修改hbase-env.sh"
	echo -e "export JAVA_HOME=${JAVA_HOME}\n#禁用Hbase自带的zookeeper\nexport HBASE_MANAGES_ZK=false" > "${temp_dir}/logs/hbase-env.sh.log"
	echo -e "export JAVA_HOME=${JAVA_HOME}\n#禁用Hbase自带的zookeeper\nexport HBASE_MANAGES_ZK=false" >> "${install_dir}/${hbase_dir}/conf/hbase-env.sh"

	echo "修改hbase_site.xml"
	# 加载文件
	hbase_site=$(cat ./resource/hbase-site-sub.xml)
	# 替换hbase在HDFS上存储的路径
	hbase_site="${hbase_site//\$\{hbase_rootdir\}/${hbase_rootdir}}"
	# 替换zookeeper集群访问地址
	zookeeper_cluster_address="${zookeeper_node[$[${#zookeeper_node[@]} - 1]]}:${zookeeper_port}"
	for((i=$[${#zookeeper_node[@]} - 2];i>-1;i--))
	do
		zookeeper_cluster_address="${zookeeper_node[i]}:${zookeeper_port},${zookeeper_cluster_address}"
	done

	hbase_site="${hbase_site//\$\{zookeeper_cluster_address\}/${zookeeper_cluster_address}}"
	# 生成日志文件
	sed -n "s|<configuration>|&${hbase_site}|" "${install_dir}/${hbase_dir}/conf/hbase-site.xml" >> "${temp_dir}/logs/hbase-site.xml.log"
	# 生成文件
	sed -i "s|<configuration>|&${hbase_site}|" "${install_dir}/${hbase_dir}/conf/hbase-site.xml"

	echo "修改regionservers"
	for((i=0;i<${#hbase_node[@]};i++))
	do 
		if [ i == 0 ]
		then
			echo ${hbase_node[i]} > "${install_dir}/${hbase_dir}/conf/regionservers"
			# 日志
			echo ${hbase_node[i]} > "${temp_dir}/logs/regionservers.log"
		else
			echo ${hbase_node[i]} >> "${install_dir}/${hbase_dir}/conf/regionservers"
			echo ${hbase_node[i]} >> "${install_dir}/${hbase_dir}/conf/backup-masters"
			# 日志
			echo ${hbase_node[i]} >> "${temp_dir}/logs/regionservers.log"
			echo ${hbase_node[i]} >> "${temp_dir}/logs/backup-masters.log"
		fi
	done

	echo "复制hadoop配置文件"
	cp ${install_dir}/${hadoop_dir}/etc/hadoop/core-site.xml ${install_dir}/${hbase_dir}/conf/
	cp ${install_dir}/${hadoop_dir}/etc/hadoop/hdfs-site.xml ${install_dir}/${hbase_dir}/conf/
fi
#------------------------------------------------------------------------------------------------#
# Kafka配置
if [ $kafka_install == "true" ]
then
	# 修改server.properties
	# 生成日志文件
	sed -n "s|log.dirs=/tmp/kafka-logs|log.dirs=${kafka_logs}|gp" "${install_dir}/${kafka_dir}/config/server.properties" >> "${temp_dir}/logs/server.properties.log"
	# 替换kafka_logs
	sed -i "s|log.dirs=/tmp/kafka-logs|log.dirs=${kafka_logs}|" "${install_dir}/${kafka_dir}/config/server.properties"
	
	zookeeper_cluster_address="${zookeeper_node[$[${#zookeeper_node[@]} - 1]]}:${zookeeper_port}"
	for((i=$[${#zookeeper_node[@]} - 2];i>-1;i--))
	do
		zookeeper_cluster_address="${zookeeper_node[i]}:${zookeeper_port},${zookeeper_cluster_address}"
	done
	sed -n "s|zookeeper.connect=localhost:2181|zookeeper.connect=${zookeeper_cluster_address}|gp" "${install_dir}/${kafka_dir}/config/server.properties" >> "${temp_dir}/logs/server.properties.log"
	# 替换zookeeper.connect
	sed -i "s|zookeeper.connect=localhost:2181|zookeeper.connect=${zookeeper_cluster_address}|" "${install_dir}/${kafka_dir}/config/server.properties"
fi
#------------------------------------------------------------------------------------------------#
# flume配置
if [ $flume_install == "true" ]
then
	echo "flume配置"
fi
#------------------------------------------------------------------------------------------------#
# redis配置
if [ $redis_install == "true" ]
then
for((i=0;i<${#redis_node[@]};i++))
do
ssh "${linux_user_name}@${redis_node[i]}" > /dev/null 2>&1 << redispath
mkdir -p ${redis_cluster_conf_dir}/6379
mkdir -p ${redis_cluster_conf_dir}/6380
exit
redispath
done

cp ./resource/redis.conf ${redis_cluster_conf_dir}/6379/
cp ./resource/redis.conf ${redis_cluster_conf_dir}/6380/
sed -i "s|port 6379|port 6380|" "${redis_cluster_conf_dir}/6380/redis.conf"

for((i=1;i<${#redis_node[@]};i++))
do
scp ${redis_cluster_conf_dir}/6379/redis.conf ${linux_user_name}@${redis_node[i]}:${redis_cluster_conf_dir}/6379/
scp ${redis_cluster_conf_dir}/6380/redis.conf ${linux_user_name}@${redis_node[i]}:${redis_cluster_conf_dir}/6380/
done
fi
#-------------------------------------------------------------------------------------------------#
#Hadoop安装包分发
if [ $hadoop_install == "true" ]
then
echo "Hadoop安装包分发"
tar -zcPf "${temp_dir}/hadoop-new.tar.gz" "${install_dir}/${hadoop_dir}/"
echo "开始分发hadoop安装包"
for((i=0;i<${#hadoop_all_node[@]};i++))
do

ssh "${linux_user_name}@${hadoop_all_node[i]}" > /dev/null 2>&1 << createpath
mkdir -p "${install_dir}"
mkdir -p "${temp_dir}"
mkdir -p "${temp_data_dir}"
exit
createpath

ssh "${linux_user_name}@${hadoop_all_node[i]}" > /dev/null 2>&1 << hadoopath
echo export HADOOP_HOME=${install_dir}/${hadoop_dir} >> ~/.bashrc
echo export PATH=\\\$PATH:\\\$HADOOP_HOME/bin:\\\$HADOOP_HOME/sbin >> ~/.bashrc
source  ~/.bashrc
hadoopath

if [ "${hadoop_all_node[i]}" != "${this_node}" ]
then
ssh "${linux_user_name}@${hadoop_all_node[i]}" > /dev/null 2>&1 << hadoopmkdir
mkdir -p "${install_dir}"
mkdir -p "${temp_dir}/logs"
exit
hadoopmkdir

echo "分发${hadoop_all_node[i]}"
scp "${temp_dir}/hadoop-new.tar.gz" "${linux_user_name}@${hadoop_all_node[i]}:${temp_dir}/"
ssh "${linux_user_name}@${hadoop_all_node[i]}" > /dev/null 2>&1 << hadoopzxf
tar -zxPf "${temp_dir}/hadoop-new.tar.gz" -C "${install_dir}/"
exit
hadoopzxf
fi
echo "done!${hadoop_all_node[i]}"
done
fi
#-------------------------------------------------------------------------------------------------#
#zookeeper安装包分发
if [ $zookeeper_install == "true" ]
then
echo "开始分发zookeeper安装包"
tar -zcPf "${temp_dir}/zookeeper-new.tar.gz" "${install_dir}/${zookeeper_dir}/"

for((i=0;i<${#zookeeper_node[@]};i++))
do

ssh "${linux_user_name}@${zookeeper_node[i]}" > /dev/null 2>&1 << createpath
mkdir -p "${install_dir}"
mkdir -p "${temp_dir}"
mkdir -p "${temp_data_dir}"
mkdir -p "${zookeeper_data_dir}"
exit
createpath

ssh "${linux_user_name}@${zookeeper_node[i]}" > /dev/null 2>&1 << zookeeperpath
tar -zxPf "${temp_dir}/zookeeper-new.tar.gz" -C "${install_dir}/"
echo export ZOOKEEPER_HOME=${install_dir}/${zookeeper_dir} >> ~/.bashrc
echo export PATH=\\\$PATH:\\\$ZOOKEEPER_HOME/bin >> ~/.bashrc
source  ~/.bashrc
exit
zookeeperpath

echo "正在创建zookeeperId,`expr ${i} + 1`"
ssh "${linux_user_name}@${zookeeper_node[i]}" > /dev/null 2>&1 << zookeepermkdir
mkdir -p "${zookeeper_data_dir}"
echo "`expr ${i} + 1`" > "${zookeeper_data_dir}/myid"
exit
zookeepermkdir

if [ "${zookeeper_node[i]}" != "${this_node}" ]
then
scp "${temp_dir}/zookeeper-new.tar.gz" "${linux_user_name}@${zookeeper_node[i]}:${temp_dir}/"
ssh "${linux_user_name}@${zookeeper_node[i]}" > /dev/null 2>&1 << zookeeperzxf
tar -zxPf "${temp_dir}/zookeeper-new.tar.gz" -C "${install_dir}/"
exit
zookeeperzxf
fi
echo "done!${zookeeper_node[i]}"
done
fi

#-------------------------------------------------------------------------------------------------#
#spark环境变量配置
if [ $spark_install == "true" ]
then
ssh "${linux_user_name}@${this_node}" > /dev/null 2>&1 << sparkpath
echo export SPARK_HOME=${install_dir}/${spark_dir} >> ~/.bashrc
echo export PATH=\\\$PATH:\\\$SPARK_HOME/bin:\\\$SPARK_HOME/sbin >> ~/.bashrc
source  ~/.bashrc
mv \$SPARK_HOME/sbin/start-all.sh \$SPARK_HOME/sbin/start-spark-all.sh
mv \$SPARK_HOME/sbin/stop-all.sh \$SPARK_HOME/sbin/stop-spark-all.sh
exit
sparkpath
fi
#-------------------------------------------------------------------------------------------------#
#Hbase安装包分发
if [ $hbase_install == "true" ]
then
echo "Hbase安装包分发"
tar -zcPf "${temp_dir}/hbase-new.tar.gz" "${install_dir}/${hbase_dir}/"
echo "开始分发Hbase安装包"
for((i=0;i<${#hbase_node[@]};i++))
do

ssh "${linux_user_name}@${hbase_node[i]}" > /dev/null 2>&1 << createpath
mkdir -p "${install_dir}"
mkdir -p "${temp_dir}"
mkdir -p "${temp_data_dir}"
exit
createpath

# 配置环境变量
ssh "${linux_user_name}@${hbase_node[i]}" > /dev/null 2>&1 << hbasepath
echo export HBASE_HOME=${install_dir}/${hbase_dir} >> ~/.bashrc
echo export PATH=\\\$PATH:\\\$HBASE_HOME/bin >> ~/.bashrc
source  ~/.bashrc
exit
hbasepath

echo "分发${hbase_node[i]}"
scp "${temp_dir}/hbase-new.tar.gz" "${linux_user_name}@${hbase_node[i]}:${temp_dir}/"
ssh "${linux_user_name}@${hbase_node[i]}" > /dev/null 2>&1 << hbasezxf
tar -zxPf "${temp_dir}/hbase-new.tar.gz" -C "${install_dir}/"
exit
hbasezxf
echo "HBase done!${hbase_node[i]}"
done
fi
#-------------------------------------------------------------------------------------------------#
#Kafka安装包分发
if [ $kafka_install == "true" ]
then
echo "Kafka安装包分发"
tar -zcPf "${temp_dir}/kafka-new.tar.gz" "${install_dir}/${kafka_dir}/"
echo "开始分发Kafka安装包"
for((i=0;i<${#kafka_node[@]};i++))
do

ssh "${linux_user_name}@${kafka_node[i]}" > /dev/null 2>&1 << createpath
mkdir -p "${install_dir}"
mkdir -p "${temp_dir}"
mkdir -p "${temp_data_dir}"
mkdir -p "${temp_data_dir}/kafka"
exit
createpath

# 配置环境变量
ssh "${linux_user_name}@${kafka_node[i]}" > /dev/null 2>&1 << kafkapath
echo export KAFKA_HOME=${install_dir}/${kafka_dir} >> ~/.bashrc
echo export PATH=\\\$PATH:\\\$KAFKA_HOME/bin >> ~/.bashrc
source  ~/.bashrc
exit
kafkapath

echo "分发${kafka_node[i]}"
scp "${temp_dir}/kafka-new.tar.gz" "${linux_user_name}@${kafka_node[i]}:${temp_dir}/"
ssh "${linux_user_name}@${kafka_node[i]}" > /dev/null 2>&1 << kafkazxf
tar -zxPf "${temp_dir}/kafka-new.tar.gz" -C "${install_dir}/"
sed -i "s|broker.id=0|broker.id=${i}|" "${install_dir}/${kafka_dir}/config/server.properties"
mkdir -p ${kafka_logs}
exit
kafkazxf
echo "Kafka done!${kafka_node[i]}"
done
fi
#-------------------------------------------------------------------------------------------------#
#Flume安装包分发
if [ $flume_install == "true" ]
then
echo "flume安装包分发"
tar -zcPf "${temp_dir}/flume-new.tar.gz" "${install_dir}/${flume_dir}/"
echo "开始分发flume安装包"
for((i=0;i<${#flume_node[@]};i++))
do

ssh "${linux_user_name}@${flume_node[i]}" > /dev/null 2>&1 << createpath
mkdir -p "${install_dir}"
mkdir -p "${temp_dir}"
mkdir -p "${temp_data_dir}"
exit
createpath

# 配置环境变量
ssh "${linux_user_name}@${flume_node[i]}" > /dev/null 2>&1 << flumepath
echo export FLUME_HOME=${install_dir}/${flume_dir} >> ~/.bashrc
echo export PATH=\\\$PATH:\\\$FLUME_HOME/bin >> ~/.bashrc
source  ~/.bashrc
exit
flumepath

echo "分发${flume_node[i]}"
scp "${temp_dir}/flume-new.tar.gz" "${linux_user_name}@${flume_node[i]}:${temp_dir}/"
ssh "${linux_user_name}@${flume_node[i]}" > /dev/null 2>&1 << flumezxf
tar -zxPf "${temp_dir}/flume-new.tar.gz" -C "${install_dir}/"
exit
flumezxf
echo "Flume done!${flume_node[i]}"
done
fi
#-------------------------------------------------------------------------------------------------#
#Redis安装包分发
if [ $redis_install == "true" ]
then
echo "redis安装包分发"
tar -zcPf "${temp_dir}/redis-new.tar.gz" "${install_dir}/${redis_dir}/"
echo "开始分发redis安装包"

for((i=0;i<${#redis_node[@]};i++))
do

ssh "${linux_user_name}@${redis_node[i]}" > /dev/null 2>&1 << createpath
mkdir -p "${install_dir}"
mkdir -p "${temp_dir}"
mkdir -p "${temp_data_dir}"
mkdir -p "${redis_cluster_conf_dir}"
exit
createpath

# 配置环境变量
ssh "${linux_user_name}@${redis_node[i]}" > /dev/null 2>&1 << redispath
echo export REDIS_HOME=${install_dir}/${redis_dir} >> ~/.bashrc
echo export PATH=\\\$PATH:\\\$REDIS_HOME/bin >> ~/.bashrc
source  ~/.bashrc
exit
redispath

echo "分发${redis_node[i]}"
scp -r "${temp_dir}/redis-new.tar.gz" "${linux_user_name}@${redis_node[i]}:${temp_dir}/"

ssh "${linux_user_name}@${redis_node[i]}" > /dev/null 2>&1 << rediszxf
tar -zxPf "${temp_dir}/redis-new.tar.gz" -C "${install_dir}/"
exit
rediszxf

echo "Redis done!${redis_node[i]}"
done
fi
#------------------------------------------------------------------------------------------------#
# zookeeper启动
if [ $zookeeper_install == "true" ]
then
for((i=0;i<${#zookeeper_node[@]};i++))
do
ssh "${linux_user_name}@${zookeeper_node[i]}" > /dev/null 2>&1 << zookeeperstart
zkServer.sh start
exit
zookeeperstart
echo "zookeeper启动${zookeeper_node[i]}"
done
echo "等待10秒"
sleep 10
# journal_node启动
for((i=0;i<${#journal_node[@]};i++))
do
ssh "${linux_user_name}@${journal_node[i]}" > /dev/null 2>&1 << journalnodestart
hadoop-daemon.sh start journalnode
exit
journalnodestart
echo "journalnode启动${journal_node[i]}"
done
fi
echo "等待10秒"
sleep 10
# 格式化并启动Namenode
if [ $hadoop_install == "true" ]
then
echo "格式化Namenode"
ssh "${linux_user_name}@${name_node[0]}" > "${temp_dir}/logs/nameFormat.log" 2>&1 << namenodeformat
hadoop namenode -format
sleep 10
hadoop-daemon.sh start namenode
exit
namenodeformat


echo "等待10秒"
sleep 10
# 复制格式化数据
echo "复制格式化数据"
ssh "${linux_user_name}@${name_node[1]}" > /dev/null 2>&1 << namenodecopy
hadoop namenode -bootstrapStandby
exit
namenodecopy

# 格式化ZK
echo "格式化ZK"
ssh "${linux_user_name}@${name_node[0]}" > /dev/null 2>&1 << formatZK
hdfs zkfc -formatZK
exit
formatZK

#启动dfs
ssh "${linux_user_name}@${name_node[0]}" > /dev/null 2>&1 << startDFS
start-dfs.sh
exit
startDFS

# 启动resource_manager
echo "启动resource_manager"
for((i=0;i<${#resource_manager[@]};i++))
do
ssh "${linux_user_name}@${resource_manager[i]}" > /dev/null 2>&1 << resourcestart
start-yarn.sh
exit
resourcestart
echo "resourcemanager${resource_manager[i]}"
done

# 启动jobhistory
echo "启动jobhistory"
ssh "${linux_user_name}@${jobhistory_node}" > /dev/null 2>&1 << jobhistorystart
mr-jobhistory-daemon.sh start historyserver
exit
jobhistorystart
fi
#------------------------------------------------------------------------------------------------#
# 启动spark-jobhistory
source  ~/.bashrc
if [ $spark_install == "true" ]
then
echo "启动spark-jobhistory"
hdfs dfs -mkdir -p /spark/logs
hdfs dfs -mkdir -p /spark/jars
start-history-server.sh > /dev/null 2>&1
fi
#------------------------------------------------------------------------------------------------#
# 启动hbase
if [ $hbase_install == "true" ]
then
echo "启动hbase"
hdfs dfs -mkdir -p /hbase
start-hbase.sh > /dev/null 2>&1
fi
#------------------------------------------------------------------------------------------------#
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
#------------------------------------------------------------------------------------------------#
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
echo "${redis_node[i]}启动Redis"
done
$redis_c
fi

#------------------------------------------------------------------------------------------------#
# 创建spark-jars.tar-gz
echo "${install_dir}/${spark_dir}/jars/*创建spark-jars.tar-gz"
hdfs dfs -mkdir -p ${spark_yarn_archive}
hdfs dfs -mkdir -p ${spark_yarn_jars}
cd ${install_dir}/${spark_dir}/jars
tar -zcf spark-jars.tar.gz ./*
hdfs dfs -put spark-jars.tar.gz ${spark_yarn_archive}

# 显示
echo hadoop UI:${name_node[0]}:50070.${name_node[1]}:50070
echo hadoop history UI:${jobhistory_node}:8088
echo spark history UI:${this_node}:18080
echo hbase UI:${name_node[0]}:16010