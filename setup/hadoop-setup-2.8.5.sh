#!/bin/sh

if test -b /dev/sdb && ! grep -q /dev/sdb /etc/fstab; then
    mke2fs -F -j /dev/sdb
    mount /dev/sdb /mnt
    chmod 755 /mnt
    echo "/dev/sdb	/mnt	ext3	defaults	0	0" >> /etc/fstab
fi

mkdir /usr/local/hadoop-2.8.5/work
chown -R aakashsh:scheduler-PG0 /usr/local/hadoop-2.8.5/
chown -R aakashsh:scheduler-PG0 /mnt/hadoop
chown -R aakashsh:scheduler-PG0 /mnt/data

hostname=`hostname | cut -d "." -f 1`
hostname $hostname

cat >> /users/aakashsh/.bashrc <<EOF
export HADOOP_HOME=/usr/local/hadoop-2.8.5/
export HADOOP_CONF_DIR=/usr/local/hadoop-2.8.5/etc/hadoop
export PATH=/usr/local/hadoop-2.8.5/bin:$PATH
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
alias cds="cd /proj/scheduler-PG0/hadoop_scripts"
EOF

grep -o -E 'slave[0-9]+$' /etc/hosts > /usr/local/hadoop-2.8.5/etc/hadoop/slaves

cat > /usr/local/hadoop-2.8.5/etc/hadoop/yarn-site.xml <<EOF
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
    <name>yarn.nodemanager.vmem-pmem-ratio</name>
    <value>5</value>
  </property>
  
  <property>
    <name>yarn.scheduler.increment-allocation-mb</name>
    <value>32</value>
  </property>

  <property>
    <name>yarn.resourcemanager.nodemanagers.heartbeat-interval-ms</name>
    <value>250</value>
  </property>

  <property>
    <name>yarn.resourcemanager.client.thread-count</name>
    <value>64</value>
  </property>

  <property>
    <name>yarn.nodemanager.resource.cpu-vcores</name>
    <value>8</value>
  </property>

  <property>
    <name>yarn.resourcemanager.resource-tracker.client.thread-count</name>
    <value>64</value>
  </property>

  <property>
    <name>yarn.nodemanager.container-manager.thread-count</name>
    <value>64</value>
  </property>

  <property>
    <name>yarn.resourcemanager.scheduler.client.thread-count</name>
    <value>64</value>
  </property>

  <property>
    <name>yarn.scheduler.maximum-allocation-mb</name>
    <value>24576</value>
  </property>

  <property>
    <name>yarn.nodemanager.localizer.client.thread-count</name>
    <value>20</value>
  </property>

  <property>
    <name>yarn.nodemanager.localizer.fetch.thread-count</name>
    <value>20</value>
  </property>

  <property>
    <name>yarn.nodemanager.resource.memory-mb</name>
    <value>24576</value>
  </property>

  <property>
    <name>yarn.scheduler.maximum-allocation-vcores</name>
    <value>128</value>
  </property>

  <property>
    <name>yarn.nodemanager.resource.percentage-physical-cpu-limit</name>
    <value>90</value>
  </property>

  <property>
    <name>yarn.scheduler.minimum-allocation-mb</name>
    <value>32</value>
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
    <name>yarn.timeline-service.enabled</name>
    <value>true</value>
  </property>

EOF

cat > /usr/local/hadoop-2.8.5/etc/hadoop/capacity-scheduler.xml <<EOF
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
    <value>0.5</value>
    <description>
      Maximum percent of resources in the cluster which can be used to run
      application masters i.e. controls number of concurrent running
      applications.
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.resource-calculator</name>
    <value>org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator</value>
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

  <property>
    <name>yarn.scheduler.capacity.per-node-heartbeat.maximum-offswitch-assignments</name>
    <value>2</value>
    <description>
      Controls the number of OFF_SWITCH assignments allowed
      during a node's heartbeat. Increasing this value can improve
      scheduling rate for OFF_SWITCH containers. Lower values reduce
      "clumping" of applications on particular nodes. The default is 1.
      Legal values are 1-MAX_INT. This config is refreshable.
    </description>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.accessible-node-labels</name>
    <value>*</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.accessible-node-labels.CORE.capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.accessible-node-labels</name>
    <value>*</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.accessible-node-labels.CORE.capacity</name>
    <value>100</value>
  </property>

</configuration>
EOF


cat > /usr/local/hadoop-2.8.5/etc/hadoop/mapred-queues.xml <<EOF
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

cat >> /usr/local/hadoop-2.8.5/etc/hadoop/hadoop-env.sh <<EOF
export HADOOP_NAMENODE_HEAPSIZE=3481
export HADOOP_DATANODE_HEAPSIZE=1105
export HADOOP_JOB_HISTORYSERVER_HEAPSIZE=2744
EOF

cat >> /usr/local/hadoop-2.8.5/etc/hadoop/hadoop-env.sh <<EOF
export YARN_NODEMANAGER_HEAPSIZE=2048
export YARN_RESOURCEMANAGER_HEAPSIZE=2744
EOF

cat > /usr/local/hadoop-2.8.5/etc/hadoop/mapred-site.xml <<EOF
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
    <name>mapreduce.cluster.local.dir</name>
    <value>/mnt/data</value>
  </property>
  
  <property>
    <name>mapreduce.jobhistory.bind-host</name>
    <value>0.0.0.0</value>
  </property>

<!-- Memory settings -->

  <property>
    <name>mapreduce.map.java.opts</name>
    <value>-Xmx2458m</value>
  </property>

  <property>
    <name>mapreduce.reduce.java.opts</name>
    <value>-Xmx4916m</value>
  </property>

  <property>
    <name>mapreduce.task.io.sort.mb</name>
    <value>200</value>
  </property>

  <property>
    <name>mapreduce.task.io.sort.factor</name>
    <value>48</value>
  </property>

  <property>
    <name>mapreduce.tasktracker.http.threads</name>
    <value>60</value>
  </property>

  <property>
    <name>mapreduce.output.fileoutputformat.compress.type</name>
    <value>BLOCK</value>
    <description>If the job outputs are to compressed as
    SequenceFiles, how should they be compressed? Should be one of
    NONE, RECORD or BLOCK.</description>
  </property>

  <property>
    <name>mapreduce.map.output.compress.codec</name>
    <value>org.apache.hadoop.io.compress.SnappyCodec</value>
  </property>

  <property>
    <name>mapreduce.job.maps</name>
    <value>160</value>
  </property>

  <property>
    <name>mapreduce.job.jvm.numtasks</name>
    <value>20</value>
  </property>

  <property>
    <name>mapreduce.map.output.compress</name>
    <value>true</value>
  </property>

  <property>
    <name>mapreduce.map.memory.mb</name>
    <value>3072</value>
  </property>

  <property>
    <name>mapred.output.committer.class</name>
    <value>org.apache.hadoop.mapred.DirectFileOutputCommitter</value>
  </property>

  <property>
    <name>mapreduce.job.reduces</name>
    <value>60</value>
  </property>

  <property>
    <name>yarn.app.mapreduce.am.command-opts</name>
    <value>-Xmx4915m</value>
  </property>

  <property>
    <name>mapreduce.reduce.memory.mb</name>
    <value>6144</value>
  </property>

  <property>
    <name>yarn.app.mapreduce.am.job.task.listener.thread-count</name>
    <value>60</value>
  </property>

  <property>
    <name>yarn.app.mapreduce.am.resource.mb</name>
    <value>6144</value>
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

  <property>
    <name>mapreduce.application.classpath</name>
    <value>
      \${HADOOP_MAPRED_HOME}/share/hadoop/mapreduce/*,
      \${HADOOP_MAPRED_HOME}/share/hadoop/mapreduce/lib/*
    </value>
  </property>

  <property>
    <name>mapred.local.dir</name>
    <value>/mnt/data</value>
  </property>

</configuration>
EOF


if hostname | grep -q namenode; then
	cat >> /usr/local/hadoop-2.8.5/etc/hadoop/yarn-site.xml <<EOF
</configuration>
EOF
	sudo -H -u aakashsh bash -c 'mkdir -p /mnt/hadoop/nameNode/'
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/bin/hdfs namenode -format'
    	sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/sbin/hadoop-daemon.sh start namenode'
elif hostname | grep -q resourcemanager; then
	cat >> /usr/local/hadoop-2.8.5/etc/hadoop/yarn-site.xml <<EOF
  <property>
    <name>yarn.node-labels.enabled</name>
    <value>true</value>
  </property>

  <property>
    <name>yarn.node-labels.fs-store.root-dir</name>
    <value>file:///users/aakashsh/node-labels</value>
  </property>

  <property>
    <name>yarn.node-labels.am.default-node-label-expression</name>
    <value>CORE</value>
  </property>

  <property>
    <name>yarn.node-labels.configuration-type</name>
    <value>distributed</value>
  </property>

 <property>
    <name>yarn.nodemanager.node-labels.provider</name>
    <value>config</value>
  </property>

  <property>
    <name>yarn.nodemanager.node-labels.provider.configured-node-partition</name>
    <value>CORE</value>
  </property>

</configuration>
EOF
        sudo -H -u aakashsh bash -c 'mkdir -p /users/aakashsh/node-labels'
	sudo chmod 777 /users/aakashsh/node-labels
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/sbin/yarn-daemon.sh start resourcemanager'
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/sbin/mr-jobhistory-daemon.sh start historyserver'
	sudo -H -u aakashsh bash -c 'cp -pr /proj/scheduler-PG0/aakash/dr-elephant-2.1.7.zip /users/aakashsh/'
	cd /users/aakashsh/
	sudo -H -u aakashsh bash -c 'unzip /users/aakashsh/dr-elephant-2.1.7.zip'
	sudo PATH=/usr/local/hadoop-2.8.5/bin:$PATH /users/aakashsh/dr-elephant-2.1.7/bin/start.sh /users/aakashsh/dr-elephant-2.1.7/app-conf/
	#sudo -H -u aakashsh bash -c 'PATH=/usr/local/hadoop-2.8.5/bin:$PATH /users/aakashsh/dr-elephant-2.1.7/bin/start.sh /users/aakashsh/dr-elephant-2.1.7/app-conf/'
else
	cat >> /usr/local/hadoop-2.8.5/etc/hadoop/yarn-site.xml <<EOF
</configuration>
EOF
	sudo -H -u aakashsh bash -c 'mkdir -p /mnt/hadoop/dataNode'
	sudo chown -R aakashsh:scheduler-PG0 /mnt/hadoop
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/sbin/yarn-daemon.sh start nodemanager'
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/sbin/hadoop-daemon.sh start datanode'
	service zabbix-agent start
fi

if hostname | grep -q namenode; then
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/bin/hdfs dfs -mkdir /user'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/bin/hdfs dfs -mkdir /tmp'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/bin/hdfs dfs -mkdir /tmp/hadoop-yarn'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/bin/hdfs dfs -mkdir /tmp/hadoop-yarn/staging'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/bin/hdfs dfs -chmod 1777 /tmp'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/bin/hdfs dfs -chmod 1777 /tmp/hadoop-yarn'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.8.5/bin/hdfs dfs -chmod 1777 /tmp/hadoop-yarn/staging'
fi

