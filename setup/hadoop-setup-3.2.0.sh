#!/bin/sh

if test -b /dev/sdb && ! grep -q /dev/sdb /etc/fstab; then
    mke2fs -F -j /dev/sdb
    mount /dev/sdb /mnt
    chmod 755 /mnt
    echo "/dev/sdb	/mnt	ext3	defaults	0	0" >> /etc/fstab
fi

apt install cpulimit
apt-get -y purge --auto-remove openjdk*
apt-get -y update
apt-get -y install openjdk-8-jdk
apt-get -y install maven

chown -R aakashsh:scheduler-PG0 /mnt/hadoop
chown -R aakashsh:scheduler-PG0 /mnt/data

hostname=`hostname | cut -d "." -f 1`
hostname $hostname

cat >> /users/aakashsh/.bashrc <<EOF
export HADOOP_HOME=/usr/local/hadoop-3.2.0/
export HADOOP_CONF_DIR=/usr/local/hadoop-3.2.0/etc/hadoop
export PATH=/usr/local/hadoop-3.2.0/bin:$PATH
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
alias cds="cd /proj/scheduler-PG0/hadoop_scripts"
EOF

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
    <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value>
    <!--<value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>-->
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
<!--  <property>
    <name>yarn.scheduler.fair.allocation.file</name>
    <value>mapred-queues.xml</value>
  </property> -->
EOF
#fi

cat > /usr/local/hadoop-3.2.0/etc/hadoop/capacity-scheduler.xml <<EOF
<configuration>

  <property>
    <name>yarn.scheduler.capacity.maximum-applications</name>
    <value>10000</value>
    <description>
      Maximum number of applications that can be pending and running.
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.maximum-am-resource-percent</name>
    <value>0.2</value>
    <description>
      Maximum percent of resources in the cluster which can be used to run
      application masters i.e. controls number of concurrent running
      applications.
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.resource-calculator</name>
    <value>org.apache.hadoop.yarn.util.resource.DominantResourceCalculator</value>
    <description>
      The ResourceCalculator implementation to be used to compare
      Resources in the scheduler.
      The default i.e. DefaultResourceCalculator only uses Memory while
      DominantResourceCalculator uses dominant-resource to compare
      multi-dimensional resources such as Memory, CPU etc.
    </description>
  </property>

<!-- configuration of queue root -->

  <property>
    <name>yarn.scheduler.capacity.root.queues</name>
    <value>default</value>
    <description>
      The queues at the this level (root is the root queue).
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.maximum-capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.accessible-node-labels</name>
    <value>*</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.accessible-node-labels.X.capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.accessible-node-labels.X.maximum-capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.accessible-node-labels.Y.capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.accessible-node-labels.Y.maximum-capacity</name>
    <value>100</value>
  </property>

<!-- configuration of queue root.default
-->
  <property>
    <name>yarn.scheduler.capacity.root.default.capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.maximum-capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.state</name>
    <value>RUNNING</value>
    <description>
      The state of the default queue. State can be one of RUNNING or STOPPED.
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.acl_submit_applications</name>
    <value>*</value>
    <description>
      The ACL of who can submit jobs to the default queue.
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.acl_administer_queue</name>
    <value>*</value>
    <description>
      The ACL of who can administer jobs on the default queue.
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.accessible-node-labels</name>
    <value>X,Y</value>
  </property>
  
  <property>
    <name>yarn.scheduler.capacity.root.default.accessible-node-labels.X.capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.accessible-node-labels.X.maximum-capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.accessible-node-labels.Y.capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.accessible-node-labels.Y.maximum-capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.user-limit-factor</name>
    <value>1</value>
    <description>
      Default queue user limit a percentage from 0.0 to 1.0.
    </description>
  </property>

</configuration>

EOF

cat > /usr/local/hadoop-3.2.0/etc/hadoop/mapred-queues.xml <<EOF
<?xml version="1.0"?>
<allocations>
  <queue name="root">
    <aclSubmitApps>*</aclSubmitApps>
    <aclAdministerApps>*</aclAdministerApps>
    <label>mapper</label>
    <queue name="mapr">
    <minResources>20000 mb,1 vcores</minResources>
    <maxResources>30000 mb,1000 vcores</maxResources>
    <maxRunningApps>10</maxRunningApps>
    <weight>1.0</weight>
    <label>mapper</label>
    <schedulingPolicy>fair</schedulingPolicy>
    <aclSubmitApps>*</aclSubmitApps>
    </queue>
  </queue>
</allocations>
EOF

cat >> /usr/local/hadoop-3.2.0/etc/hadoop/hadoop-env.sh <<EOF
export HADOOP_HOME=/usr/local/hadoop-3.2.0/
EOF

cat > /usr/local/hadoop-3.2.0/etc/hadoop/mapred-site.xml <<EOF
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
    <name>mapreduce.map.memory.mb</name>
    <value>2048</value>
  </property>
  <property>
    <name>mapreduce.reduce.cpu.vcores</name>
    <value>4</value>
  </property>
  <property>
    <name>mapreduce.reduce.memory.mb</name>
    <value>4096</value>
  </property>
  <property>
    <name>mapreduce.cluster.local.dir</name>
    <value>/mnt/data</value>
  </property>
  <property>
    <name>mapreduce.jobhistory.bind-host</name>
    <value>0.0.0.0</value>
  </property>
<property>
  <name>yarn.app.mapreduce.am.env</name>
  <value>HADOOP_MAPRED_HOME=\${HADOOP_HOME}</value>
</property>
<property>
  <name>mapreduce.map.env</name>
  <value>HADOOP_MAPRED_HOME=\${HADOOP_HOME}</value>
</property>
<property>
  <name>mapreduce.reduce.env</name>
  <value>HADOOP_MAPRED_HOME=\${HADOOP_HOME}</value>
</property>
</configuration>
EOF

cp -pr /proj/scheduler-PG0/aakash/dr-elephant-2.1.7.zip /users/aakashsh/
cd /users/aakashsh/
unzip /users/aakashsh/dr-elephant-2.1.7.zip

if hostname | grep -q namenode; then
	cat >> /usr/local/hadoop-3.2.0/etc/hadoop/yarn-site.xml <<EOF
</configuration>
EOF
	sudo -H -u aakashsh bash -c 'mkdir -p /mnt/hadoop/nameNode/'
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hdfs namenode -format'
    	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hdfs --daemon start namenode'
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
        sudo -H -u aakashsh bash -c 'mkdir -p /users/aakashsh/node-labels'
	sudo chmod 777 /users/aakashsh/node-labels
	sudo PATH=/usr/local/hadoop-3.2.0/bin:$PATH /users/aakashsh/dr-elephant-2.1.7/bin/start.sh /users/aakashsh/dr-elephant-2.1.7/app-conf/
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/yarn --daemon start resourcemanager'
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/sbin/mr-jobhistory-daemon.sh start historyserver'
else
	cat >> /usr/local/hadoop-3.2.0/etc/hadoop/yarn-site.xml <<EOF
</configuration>
EOF
	sudo -H -u aakashsh bash -c 'mkdir -p /mnt/hadoop/dataNode'
	sudo chown -R aakashsh:scheduler-PG0 /mnt/hadoop
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/sbin/yarn-daemon.sh start nodemanager'
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-3.2.0/bin/hdfs --daemon start datanode'
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

