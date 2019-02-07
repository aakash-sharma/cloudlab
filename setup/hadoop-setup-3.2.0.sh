#!/bin/sh

if test -b /dev/sdb && ! grep -q /dev/sdb /etc/fstab; then
    mke2fs -F -j /dev/sdb
    mount /dev/sdb /mnt
    chmod 755 /mnt
    echo "/dev/sdb	/mnt	ext3	defaults	0	0" >> /etc/fstab
fi

chown -R aakashsh:scheduler-PG0 /mnt/hadoop
chown -R aakashsh:scheduler-PG0 /mnt/data

hostname=`hostname | cut -d "." -f 1`
hostname $hostname

grep -o -E 'slave[0-9]+$' /etc/hosts > /usr/local/hadoop-3.2.0/etc/hadoop/slaves

cat > /usr/local/hadoop-3.2.0/etc/hadoop/yarn-site.xml <<EOF
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
    <name>yarn.resourcemanager.scheduler.class</name>
    <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
  </property>
  <property>
    <name>yarn.scheduler.fair.user-as-default-queue</name>
    <value>True</value>
  </property>
  <property>
    <name>org.apache.hadoop.yarn.server.resourcemanager.scheduler.drf.SchedulingPolicy</name>
    <value>True</value>
  </property>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
  <property>
    <name>yarn.nodemanager.resource.percentage-physical-cpu-limit</name>
    <value>90</value>
  </property>
  <property>
    <name>yarn.scheduler.minimum-allocation-mb</name>
    <value>2048</value>
  </property>
  <property>
    <name>yarn.scheduler.minimum-allocation-vcores</name>
    <value>2</value>
  </property>
  <property>
    <name>yarn.resourcemanager.bind-host</name>
    <value>0.0.0.0</value>
  </property>
  <property>
    <name>yarn.nodemanager.bind-host</name>
    <value>0.0.0.0</value>
  </property>
  <property>
    <name>yarn.timeline-service.bind-host</name>
    <value>0.0.0.0</value>
  </property>
  <property>
    <name>yarn.log-aggregation-enable</name>
    <value>true</value>
  </property>
  <property>
    <name>yarn.scheduler.fair.allocation.file</name>
    <value>mapred-queues.xml</value>
  </property>
EOF
#fi

cat > /usr/local/hadoop-3.2.0/etc/hadoop/mapred-queues.xml <<EOF
<?xml version="1.0"?>
<allocations>
  <queue name="root">
    <aclSubmitApps>mapr</aclSubmitApps>                                      
    <aclAdministerApps>mapr</aclAdministerApps>
    <queue name="mapr">
      <minResources>20000 mb,1 vcores</minResources>
      <maxResources>30000 mb,1000 vcores</maxResources>
      <maxRunningApps>10</maxRunningApps>
      <weight>1.0</weight>
      <label>mapper</label>
      <schedulingPolicy>fair</schedulingPolicy>
      <aclSubmitApps>mapr</aclSubmitApps>
    </queue>
  </queue>
</allocations>
EOF

if hostname | grep -q namenode; then
	cat >> /usr/local/hadoop-3.2.0/etc/hadoop/yarn-site.xml <<EOF
</configuration>
EOF
	sudo -H -u aakashsh bash -c 'mkdir -p /mnt/hadoop/nameNode/'
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hadoop namenode -format'
    	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/sbin/hadoop-daemon.sh --script hdfs start namenode'
elif hostname | grep -q resourcemanager; then
	cat >> /usr/local/hadoop-3.2.0/etc/hadoop/yarn-site.xml <<EOF
  <property>
    <name>yarn.node-labels.enabled</name>
    <value>true</value>
  </property>
  <property>
    <name>yarn.node-labels.fs-store.root-dir</name>
    <value>file:///users/aakashsh/node-labels</value>
  </property>
</configuration>
EOF
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/sbin/mr-jobhistory-daemon.sh start historyserver'
else
	cat >> /usr/local/hadoop-3.2.0/etc/hadoop/yarn-site.xml <<EOF
</configuration>
EOF
	sudo -H -u aakashsh bash -c 'mkdir -p /mnt/hadoop/dataNode'
	sudo chown -R aakashsh:scheduler-PG0 /mnt/hadoop
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/sbin/yarn-daemon.sh start nodemanager'
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/sbin/hadoop-daemon.sh --script hdfs start datanode'
	service zabbix-agent start
fi

if hostname | grep -q namenode; then
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hdfs dfs -mkdir /user'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hdfs dfs -mkdir /tmp'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hdfs dfs -mkdir /tmp/hadoop-yarn'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hdfs dfs -mkdir /tmp/hadoop-yarn/staging'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hdfs dfs -chmod 1777 /tmp'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hdfs dfs -chmod 1777 /tmp/hadoop-yarn'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hdfs dfs -chmod 1777 /tmp/hadoop-yarn/staging'
fi

