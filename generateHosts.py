def main():
	f = open("zbx_import_hosts.xml", "w")
	f.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + 
"<zabbix_export>\n" +
"    <version>3.4</version>\n" +
"    <date>2018-06-01T02:55:13Z</date>\n" +
"    <groups>\n" +
"        <group>\n" +
"            <name>Virtual machines</name>\n" +
"        </group>\n" +
"        <group>\n" +
"            <name>Zabbix servers</name>\n" +
"        </group>\n" +
"    </groups>\n" +
"    <hosts>\n")

	for i in range(10):
		j = i + 3
		f.write("        <host>\n" +
"            <host>slave" + str(i) + "</host>\n" +
"            <name>slave" + str(i) + "</name>\n" +
"            <description/>\n" +
"            <proxy/>\n" +
"            <status>0</status>\n" +
"            <ipmi_authtype>-1</ipmi_authtype>\n" +
"            <ipmi_privilege>2</ipmi_privilege>\n" +
"            <ipmi_username/>\n" +
"            <ipmi_password/>\n" +
"            <tls_connect>1</tls_connect>\n" +
"            <tls_accept>1</tls_accept>\n" +
"            <tls_issuer/>\n" +
"            <tls_subject/>\n" +
"            <tls_psk_identity/>\n" +
"            <tls_psk/>\n" +
"            <templates>\n" +
"                <template>\n" +
"                    <name>Template OS Linux</name>\n" +
"                </template>\n" +
"            </templates>\n" +
"            <groups>\n" +
"                <group>\n" +
"                    <name>Virtual machines</name>\n" +
"                </group>\n" +
"            </groups>\n" +
"            <interfaces>\n" +
"                <interface>\n" +
"                    <default>1</default>\n" +
"                    <type>1</type>\n" +
"                    <useip>1</useip>\n" +
"                    <ip>10.10.1." + str(j) + "</ip>\n" +
"                    <dns/>\n" +
"                    <port>10050</port>\n" +
"                    <bulk>1</bulk>\n" +
"                    <interface_ref>if1</interface_ref>\n" +
"                </interface>\n" +
"            </interfaces>\n" +
"            <applications/>\n" +
"            <items>\n" +
"                <item>\n" +
"                    <name>net _in</name>\n" +
"                    <type>0</type>\n" +
"                    <snmp_community/>\n" +
"                    <snmp_oid/>\n" +
"                    <key>net.if.in[eth1]</key>\n" +
"                    <delay>30s</delay>\n" +
"                    <history>90d</history>\n" +
"                    <trends>365d</trends>\n" +
"                    <status>0</status>\n" +
"                    <value_type>3</value_type>\n" +
"                    <allowed_hosts/>\n" +
"                    <units/>\n" +
"                    <snmpv3_contextname/>\n" +
"                    <snmpv3_securityname/>\n" +
"                    <snmpv3_securitylevel>0</snmpv3_securitylevel>\n" +
"                    <snmpv3_authprotocol>0</snmpv3_authprotocol>\n" +
"                    <snmpv3_authpassphrase/>\n" +
"                    <snmpv3_privprotocol>0</snmpv3_privprotocol>\n" +
"                    <snmpv3_privpassphrase/>\n" +
"                    <params/>\n" +
"                    <ipmi_sensor/>\n" +
"                    <authtype>0</authtype>\n" +
"                    <username/>\n" +
"                    <password/>\n" +
"                    <publickey/>\n" +
"                    <privatekey/>\n" +
"                    <port/>\n" +
"                    <description/>\n" +
"                    <inventory_link>0</inventory_link>\n" +
"                    <applications/>\n" +
"                    <valuemap/>\n" +
"                    <logtimefmt/>\n" +
"                    <preprocessing/>\n" +
"                    <jmx_endpoint/>\n" +
"                    <master_item/>\n" +
"                    <interface_ref>if1</interface_ref>\n" +
"                </item>\n" +
"                <item>\n" +
"                    <name>net_out</name>\n" +
"                    <type>0</type>\n" +
"                    <snmp_community/>\n" +
"                    <snmp_oid/>\n" +
"                    <key>net.if.out[eth1]</key>\n" +
"                    <delay>30s</delay>\n" +
"                    <history>90d</history>\n" +
"                    <trends>365d</trends>\n" +
"                    <status>0</status>\n" +
"                    <value_type>3</value_type>\n" +
"                    <allowed_hosts/>\n" +
"                    <units/>\n" +
"                    <snmpv3_contextname/>\n" +
"                    <snmpv3_securityname/>\n" +
"                    <snmpv3_securitylevel>0</snmpv3_securitylevel>\n" +
"                    <snmpv3_authprotocol>0</snmpv3_authprotocol>\n" +
"                    <snmpv3_authpassphrase/>\n" +
"                    <snmpv3_privprotocol>0</snmpv3_privprotocol>\n" +
"                    <snmpv3_privpassphrase/>\n" +
"                    <params/>\n" +
"                    <ipmi_sensor/>\n" +
"                    <authtype>0</authtype>\n" +
"                    <username/>\n" +
"                    <password/>\n" +
"                    <publickey/>\n" +
"                    <privatekey/>\n" +
"                    <port/>\n" +
"                    <description/>\n" +
"                    <inventory_link>0</inventory_link>\n" +
"                    <applications/>\n" +
"                    <valuemap/>\n" +
"                    <logtimefmt/>\n" +
"                    <preprocessing/>\n" +
"                    <jmx_endpoint/>\n" +
"                    <master_item/>\n" +
"                    <interface_ref>if1</interface_ref>\n" +
"                </item>\n" +
"            </items>\n" +
"            <discovery_rules/>\n" +
"            <httptests/>\n" +
"            <macros/>\n" +
"            <inventory/>\n" +
"        </host>\n")

	f.write("        <host>\n" +
"            <host>Zabbix server</host>\n" +
"            <name>Zabbix server</name>\n" +
"            <description/>\n" +
"            <proxy/>\n" +
"            <status>0</status>\n" +
"            <ipmi_authtype>-1</ipmi_authtype>\n" +
"            <ipmi_privilege>2</ipmi_privilege>\n" +
"            <ipmi_username/>\n" +
"            <ipmi_password/>\n" +
"            <tls_connect>1</tls_connect>\n" +
"            <tls_accept>1</tls_accept>\n" +
"            <tls_issuer/>\n" +
"            <tls_subject/>\n" +
"            <tls_psk_identity/>\n" +
"            <tls_psk/>\n" +
"            <templates>\n" +
"                <template>\n" +
"                    <name>Template App Zabbix Server</name>\n" +
"                </template>\n" +
"                <template>\n" +
"                    <name>Template OS Linux</name>\n" +
"                </template>\n" +
"            </templates>\n" +
"            <groups>\n" +
"                <group>\n" +
"                    <name>Zabbix servers</name>\n" +
"                </group>\n" +
"            </groups>\n" +
"            <interfaces>\n" +
"                <interface>\n" +
"                    <default>1</default>\n" +
"                    <type>1</type>\n" +
"                    <useip>1</useip>\n" +
"                    <ip>127.0.0.1</ip>\n" +
"                    <dns/>\n" +
"                    <port>10050</port>\n" +
"                    <bulk>1</bulk>\n" +
"                    <interface_ref>if1</interface_ref>\n" +
"                </interface>\n" +
"            </interfaces>\n" +
"            <applications/>\n" +
"            <items/>\n" +
"            <discovery_rules/>\n" +
"            <httptests/>\n" +
"            <macros/>\n" +
"            <inventory/>\n" +
"        </host>\n" +
"    </hosts>\n" +
"</zabbix_export>\n")

if __name__== "__main__":
  main()
