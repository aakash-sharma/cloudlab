import geni.portal as portal
import geni.rspec.pg as RSpec
import geni.rspec.igext

pc = portal.Context()

pc.defineParameter( "n", "Number of slave nodes",
		    portal.ParameterType.INTEGER, 3 )

pc.defineParameter( "mem", "Memory per VM",
            portal.ParameterType.INTEGER, 8192 )
            
#pc.defineParameter( "core", "Core per VM",
 #           portal.ParameterType.INTEGER, 2 )
            
pc.defineParameter( "raw", "Use physical nodes",
                    portal.ParameterType.BOOLEAN, False )


params = pc.bindParameters()

# Create a Request object to start building the RSpec.
request = portal.context.makeRequestRSpec()

IMAGE = "urn:publicid:IDN+emulab.net+image+emulab-ops//hadoop-273"
SETUP = "https://github.com/aakash-sharma/cloudlab/raw/master/hadoop-2.7.3-setup.tar.gz"

def Node( name, public ):
    if params.raw:
        return RSpec.RawPC( name )
    else:
        vm = request.XenVM( name )
        vm.ram = params.mem
  #      vm.cores = params.core
        if public:
            vm.routable_control_ip = True
        return vm

rspec = RSpec.Request()

lan = RSpec.LAN()
rspec.addResource( lan )

node = Node( "namenode", True )
node.cores = 2
node.disk_image = IMAGE
node.addService( RSpec.Install( SETUP, "/tmp" ) )
node.addService( RSpec.Execute( "sh", "sudo /tmp/setup/hadoop-setup.sh" ) )
iface = node.addInterface( "if0" )
lan.addInterface( iface )
rspec.addResource( node )

node = request.XenVM( "resourcemanager" )
node.ram = 8192
node.routable_control_ip = True
#node.disk_image = IMAGE
node.disk_image = " urn:publicid:IDN+apt.emulab.net+image+scheduler-PG0:HadoopWithZabbixServer:2"
node.cores = 4
#bs = node.Blockstore("bs", "/var")
#bs.size = "100GB"
bs_hadoop = node.Blockstore("bs_hadoop", "/mnt/hadoop")
bs_hadoop.size = "1100GB"
node.addService( RSpec.Install( SETUP, "/tmp" ) )
node.addService( RSpec.Execute( "sh", "sudo /tmp/setup/hadoop-setup.sh" ) )
iface = node.addInterface( "if0" )
lan.addInterface( iface )
rspec.addResource( node )

bs = []
for i in range( params.n ):
    node = Node( "slave" + str( i ), True )
    node.disk_image = IMAGE
    node.cores = 2
    #node = rspec.RawPC("node")
    bs.append(node.Blockstore("bs" + str( i ), "/mnt/hadoop"))
    bs[i].size = "30GB"
    node.addService( RSpec.Install( SETUP, "/tmp" ) )
    node.addService( RSpec.Execute( "sh", "sudo /tmp/setup/hadoop-setup.sh" ) )
    iface = node.addInterface( "if0" )
    lan.addInterface( iface )
    rspec.addResource( node )

from lxml import etree as ET

tour = geni.rspec.igext.Tour()
tour.Description( geni.rspec.igext.Tour.TEXT, "A cluster running Hadoop 2.7.3. It includes a name node, a resource manager, and as many slaves as you choose." )
tour.Instructions( geni.rspec.igext.Tour.MARKDOWN, "After your instance boots (approx. 5-10 minutes), you can log into the resource manager node and submit jobs.  [The HDFS web UI](http://{host-namenode}:50070/) and [the resource manager UI](http://{host-resourcemanager}:8088/) will also become available." )
rspec.addTour( tour )

pc.printRequestRSpec( rspec )

