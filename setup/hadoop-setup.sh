#!/bin/sh

if test -b /dev/sdb && ! grep -q /dev/sdb /etc/fstab; then
    mke2fs -F -j /dev/sdb
    mount /dev/sdb /mnt
    chmod 755 /mnt
    echo "/dev/sdb	/mnt	ext3	defaults	0	0" >> /etc/fstab
fi

#mkdir /mnt/hadoop
chmod 1777 /mnt/hadoop

cat > /usr/local/hadoop-2.7.3/etc/hadoop/capacity-scheduler.xml <<EOF
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
    <value>0.1</value>
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

  <property>
    <name>yarn.scheduler.capacity.root.queues</name>
    <value>default</value>
    <description>
      The queues at the this level (root is the root queue).
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.capacity</name>
    <value>100</value>
    <description>Default queue target capacity.</description>
  </property>
  <property>
    <name>yarn.scheduler.capacity.root.default.user-limit-factor</name>
    <value>1</value>
    <description>
      Default queue user limit a percentage from 0.0 to 1.0.
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.maximum-capacity</name>
    <value>100</value>
    <description>
      The maximum capacity of the default queue.
    </description>
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
    <name>yarn.scheduler.capacity.node-locality-delay</name>
    <value>40</value>
    <description>
      Number of missed scheduling opportunities after which the CapacityScheduler
      attempts to schedule rack-local containers.
      Typically this should be set to number of nodes in the cluster, By default is setting
      approximately number of nodes in one rack which is 40.
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.queue-mappings</name>
    <value></value>
    <description>
      A list of mappings that will be used to assign jobs to queues
      The syntax for this list is [u|g]:[name]:[queue_name][,next mapping]*
      Typically this list will be used to map users to queues,
      for example, u:%user:%user maps all users to queues with the same name
      as the user.
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.queue-mappings-override.enable</name>
    <value>false</value>
    <description>
      If a queue mapping is present, will it override the value specified
      by the user? This can be used by administrators to place jobs in queues
      that are different than the one specified by the user.
      The default is false.
    </description>
  </property>

</configuration>
EOF

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

cat > /usr/local/hadoop-2.7.3/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
  <property> 
    <name>dfs.replication</name> 
    <value>1</value> 
  </property>
</configuration>
EOF

#if ! grep -q yarn.resourcemanager.hostname /usr/local/hadoop-2.7.3/etc/hadoop/yarn-site.xml; then
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
  <property>
    <name>yarn.scheduler.minimum-allocation-mb</name>
    <value>2048</value>
  </property>
  <property>
    <name>yarn.scheduler.minimum-allocation-vcores</name>
    <value>2</value>
  </property>
</configuration>
EOF
#fi

#if ! grep -q mapreduce.framework.name /usr/local/hadoop-2.7.3/etc/hadoop/mapred-site.xml; then
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
  <property>
    <name>mapreduce.cluster.local.dir</name>
    <value>/mnt/data</value>
  </property>
</configuration>
EOF
#fi

sed -i orig -e 's@^export JAVA_HOME.*@export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64@' -e 's@^export HADOOP_CONF_DIR.*@export HADOOP_CONF_DIR=/usr/local/hadoop-2.7.3/etc/hadoop@' /usr/local/hadoop-2.7.3/etc/hadoop/hadoop-env.sh

if hostname | grep -q namenode; then
#    if ! test -d /mnt/hadoop/current; then
	/usr/local/hadoop-2.7.3/bin/hadoop namenode -format
 #   fi
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
