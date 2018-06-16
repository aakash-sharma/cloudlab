#!/bin/sh

if test -b /dev/sdb && ! grep -q /dev/sdb /etc/fstab; then
    mke2fs -F -j /dev/sdb
    mount /dev/sdb /mnt
    chmod 755 /mnt
    echo "/dev/sdb	/mnt	ext3	defaults	0	0" >> /etc/fstab
fi

mkdir /mnt/hadoop
chmod 1777 /mnt/hadoop

if ! grep -q fs.defaultFS /usr/local/hadoop-2.7.3/etc/hadoop/core-site.xml; then
cat > /usr/local/hadoop-2.7.3/etc/hadoop/core-site.xml <<EOF
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://namenode:9000/</value>
  </property>
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/mnt/hadoop</value>
    <final>true</final>
  </property>
</configuration>
EOF
fi

grep -o -E 'slave[0-9]+$' /etc/hosts > /usr/local/hadoop-2.7.3/etc/hadoop/slaves

if ! grep -q dfs.namenode.name.dir /usr/local/hadoop-2.7.3/etc/hadoop/hdfs-site.xml; then
cat > /usr/local/hadoop-2.7.3/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/mnt/hadoop</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>/mnt/hadoop</value>
  </property>
</configuration>
EOF
fi

if ! grep -q yarn.resourcemanager.hostname /usr/local/hadoop-2.7.3/etc/hadoop/yarn-site.xml; then
cat > /usr/local/hadoop-2.7.3/etc/hadoop/yarn-site.xml <<EOF
<configuration>
  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>resourcemanager</value>
  </property>
  <property>
    <name>yarn.resourcemanager.webapp.address</name>
    <value>0.0.0.0:8088</value>
  </property>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
  <property>
    <name>yarn.nodemanager.resource.percentage-physical-cpu-limit</name>
    <value>90</value>
  </property>
</configuration>
EOF
fi

if ! grep -q mapreduce.framework.name /usr/local/hadoop-2.7.3/etc/hadoop/mapred-site.xml; then
cat > /usr/local/hadoop-2.7.3/etc/hadoop/mapred-site.xml <<EOF
<configuration>
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
  <property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>0.0.0.0:19888</value>
  </property>
  <property>
    <name>mapreduce.map.cpu.vcores</name>
    <value>4</value>
  </property>
  <property>
    <name>mapreduce.reduce.cpu.vcores</name>
    <value>2</value>
  </property>
</configuration>
EOF
fi

sed -i orig -e 's@^export JAVA_HOME.*@export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64@' -e 's@^export HADOOP_CONF_DIR.*@export HADOOP_CONF_DIR=/usr/local/hadoop-2.7.3/etc/hadoop@' /usr/local/hadoop-2.7.3/etc/hadoop/hadoop-env.sh

if hostname | grep -q namenode; then
    if ! test -d /mnt/hadoop/current; then
	/usr/local/hadoop-2.7.3/bin/hadoop namenode -format
    fi
    /usr/local/hadoop-2.7.3/sbin/hadoop-daemon.sh --script hdfs start namenode
elif hostname | grep -q resourcemanager; then
    /usr/local/hadoop-2.7.3/sbin/yarn-daemon.sh start resourcemanager
else
    /usr/local/hadoop-2.7.3/sbin/yarn-daemon.sh start nodemanager
    /usr/local/hadoop-2.7.3/sbin/hadoop-daemon.sh --script hdfs start datanode
	apt install zabbix-agent
	sed -i -e 's@^Server=127.0.0.1@Server=10.10.1.2@' -e 's@^ServerActive=127.0.0.1@ServerActive=10.10.1.2@' /etc/zabbix/zabbix_agentd.conf
	service zabbix-agent restart
fi

if hostname | grep -q namenode; then
    /usr/local/hadoop-2.7.3/bin/hdfs dfs -mkdir /user
    /usr/local/hadoop-2.7.3/bin/hdfs dfs -mkdir /tmp
    /usr/local/hadoop-2.7.3/bin/hdfs dfs -mkdir /tmp/hadoop-yarn
    /usr/local/hadoop-2.7.3/bin/hdfs dfs -mkdir /tmp/hadoop-yarn/staging
    /usr/local/hadoop-2.7.3/bin/hdfs dfs -chmod 1777 /tmp
    /usr/local/hadoop-2.7.3/bin/hdfs dfs -chmod 1777 /tmp/hadoop-yarn
    /usr/local/hadoop-2.7.3/bin/hdfs dfs -chmod 1777 /tmp/hadoop-yarn/staging
fi
