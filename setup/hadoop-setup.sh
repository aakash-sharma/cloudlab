#!/bin/sh

if test -b /dev/sdb && ! grep -q /dev/sdb /etc/fstab; then
    mke2fs -F -j /dev/sdb
    mount /dev/sdb /mnt
    chmod 755 /mnt
    echo "/dev/sdb	/mnt	ext3	defaults	0	0" >> /etc/fstab
fi

#apt-get install autopoint
cd /users/aakashsh
cp -pr /proj/scheduler-PG0/procps .
#git clone https://gitlab.com/procps-ng/procps.git
cd /users/aakashsh/procps
/users/aakashsh/procps/autogen.sh
/users/aakashsh/procps/configure
make
mv /bin/kill /bin/kill.bak
cp /users/aakashsh/procps/kill /bin/kill

#gcc /proj/scheduler-PG0/aakash.clemson/debug.c -o /users/aakashsh/debug

#/users/aakashsh/debug > /users/aakashsh/out &

#apt-get install --assume-yes auditd audispd-plugins

#cat >> /etc/audit/audit.rules <<EOF
#-a entry,always -F arch=b64 -S kill -k test_kill
#-a exit,always -F arch=b64 -F euid=0 -S execve
#-a exit,always -F arch=b32 -F euid=0 -S execve
#EOF

#service auditd restart

#nohup /users/aakashsh/debug  &

#sed -i -e 's@^GRUB_CMDLINE_LINUX_DEFAULT=\"\"@GRUB_CMDLINE_LINUX_DEFAULT=\"audit=1\"@' /etc/default/grub

#cd /users/aakashsh
#git clone https://github.com/brendangregg/perf-tools.git
#nohup /users/aakashsh/perf-tools/execsnoop > /users/aakashsh/execsnoop.out &

#sudo ps -aux > /users/aakashsh/ps.out

#init 6
#mkdir /mnt/hadoop
chmod 1777 /mnt/hadoop
chmod 1777 /mnt/data
chown -R aakashsh /usr/local/hadoop-2.7.3/

cat >> /users/aakashsh/.bashrc <<EOF
export HADOOP_HOME=/usr/local/hadoop-2.7.3/
export HADOOP_CONF_DIR=/usr/local/hadoop-2.7.3/etc/hadoop
export PATH=/usr/local/hadoop-2.7.3/bin:$PATH
EOF

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
    <value>/mnt/data</value>
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
    <value>2</value> 
  </property>
  <property> 
    <name>dfs.datanode.dns.interface</name> 
    <value>eth1</value> 
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
    <value>2</value>
  </property>
  <property>
    <name>mapreduce.reduce.cpu.vcores</name>
    <value>2</value>
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
</configuration>
EOF
#fi

cat >> /usr/local/hadoop-2.7.3/etc/hadoop/hadoop-env.sh <<EOF
#export HADOOP_ROOT_LOGGER=DEBUG,console
export HADOOP_HEAPSIZE=4000
EOF

sed -i orig -e 's@^export JAVA_HOME.*@export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64@' -e 's@^export HADOOP_CONF_DIR.*@export HADOOP_CONF_DIR=/usr/local/hadoop-2.7.3/etc/hadoop@' /usr/local/hadoop-2.7.3/etc/hadoop/hadoop-env.sh

if hostname | grep -q namenode; then
#    if ! test -d /mnt/hadoop/current; then
	sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/bin/hadoop namenode -format'
 #   fi
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/sbin/hadoop-daemon.sh --script hdfs start namenode'

elif hostname | grep -q resourcemanager; then
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/sbin/yarn-daemon.sh start resourcemanager'
	cp -pr /proj/scheduler-PG0/aakash/dr-elephant-2.1.7.zip /users/aakashsh/
	cd /users/aakashsh/
	unzip /users/aakashsh/dr-elephant-2.1.7.zip
	cat > /users/aakashsh/dr-elephant-2.1.7/app-conf/FetcherConf.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<fetchers>
  <fetcher>
    <applicationtype>mapreduce</applicationtype>
    <classname>com.linkedin.drelephant.mapreduce.fetchers.MapReduceFetcherHadoop2</classname>
    <params>
      <sampling_enabled>false</sampling_enabled>
    </params>
  </fetcher>
</fetchers>
EOF
	debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
	debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
	apt-get update
	apt-get -y install mysql-server
	mysql -u root -proot < "/proj/scheduler-PG0/aakash/create_db.sql"
	sudo PATH=/usr/local/hadoop-2.7.3/bin:$PATH /users/aakashsh/dr-elephant-2.1.7/bin/start.sh /users/aakashsh/dr-elephant-2.1.7/app-conf/

else
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/sbin/yarn-daemon.sh start nodemanager'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/sbin/hadoop-daemon.sh --script hdfs start datanode'
	#apt install zabbix-agent
	sed -i -e 's@^Server=127.0.0.1@Server=10.10.1.2@' -e 's@^ServerActive=127.0.0.1@ServerActive=10.10.1.2@' /etc/zabbix/zabbix_agentd.conf
	service zabbix-agent restart
fi

if hostname | grep -q namenode; then
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/bin/hdfs dfs -mkdir /user'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/bin/hdfs dfs -mkdir /tmp'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/bin/hdfs dfs -mkdir /tmp/hadoop-yarn'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/bin/hdfs dfs -mkdir /tmp/hadoop-yarn/staging'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/bin/hdfs dfs -chmod 1777 /tmp'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/bin/hdfs dfs -chmod 1777 /tmp/hadoop-yarn'
    sudo -H -u aakashsh bash -c '/usr/local/hadoop-2.7.3/bin/hdfs dfs -chmod 1777 /tmp/hadoop-yarn/staging'
fi

