
# Switch configuration - image Open vSwitch with SNMP (gns3) #

# 1 - IP configuration of the switch

```
# Static config for eth0
auto eth0
iface eth0 inet static
	address 10.10.10.1
	netmask 255.255.255.0
	gateway 10.10.10.0
	up echo nameserver 8.8.8.8 > /etc/resolv.conf
```


# 2 - IP configuration of the SNMP gestor


```
# Static config for eth0
auto eth0
iface eth0 inet static
	address 10.10.10.2
	netmask 255.255.255.0
	gateway 10.10.10.0
	up echo nameserver 8.8.8.8 > /etc/resolv.conf
```

# 3 - SNMP configuration of the agent

/etc/snmp/snmpd.conf
```
# snmpd.conf
# minimal config allowing v1/v2c public read access
# for SNMPv2-MIB::system and LLDP

# agent properties
sysLocation "Planta 2C - Mi casa"
sysContact "Antoine"

# listen on all IPs, default port
agentAddress udp:161

# mib-2
view publicview included .1.3.6.1.2.1

# system
view publicview included .1.3.6.1.2.1.1

# interfaces
view publicview included .1.3.6.1.2.1.2

# dot1dBridge
view publicview included .1.3.6.1.2.1.17

# LLDP
view publicview included .1.0.8802.1.1.2

rocommunity public default -V publicview
rwcommunity public default -V publicview

master agentx
```

# 4 - MIBS implemented by the SNMP agent

Result of snmpwalk : see snmpwalk file.

The resulting list of MIBs is :
- SNMPv2-MIB
- DISMAN-EVENT-MIB
- IF-MIB
- IP-MIB
- IP-FORWARD-MIB
- TCP-MIB
- UDP-MIB
- HOST-RESOURCES-MIB
- IPV6-MIB
- NOTIFICATION-LOG-MIB

Interesting object for security managment :
+ SNMPv2-MIB
  * snmpMIBOpbjects
    - sysName
    - sysDescr
    - sysContact
    - sysLocation
    - sysUpTime (could identify reboots)
    - sysORTable (map implemented objects with human readable desc)
    - sysORLastChange (could check unauthorized change)
  * snmp
    - snmpInPkts (can be use to check increase in request)
    - snmpInBadVersions (bad snmp version)
    - snmpInBadCommunityNames
    - snmpInBadCommunityUses
    - snmpInASNParseErrs
    - snmpEnableAuthenTraps (enable traps on auth failure)
    - snmpSilentDrops
    - snmpProxyDrops
    - snmpIn(Out)...(by type of request/err/trap)
  * snmpTraps
    - coldStart
    - warmStart
    - authenticationFailure
  * snmpMIBGroups
    - snmpGroup
    - snmpCommuityGroup1
    - snmpSetGroup
    - systemGroup
    - snmpBasicNotificationsGroup
    - snmpWarmStartNotificationGroup
    - snmpNotificationGroup
+ DISMAN-EVENT-MIB
  => configure Traps
+ IF-MIB
  * interfaces
    -- ifTable
    - ifOperStatus
    - ifLastChange
    - ifInOctets (Discards/Errors/Unknown) ...
    -- ifXTable
    - ifLinkUpDownTrapEnable
    - linkDown
    - linkUp
    -- ifTestTable
+ IP-MIB
  * ipTrafficStats
+ IP-FORWARD-MIB
+ TCP-MIB
  - tcpActiveOpens
  - tcpPassiveOpens
  - tcpAttemptFails
  - tcpCurrEstab
+ UDP-MIB
  - udpInDatagrams
+ HOST-RESOURCES-MIB
  - hrSystemNumUsers
  - hrSystemProcesses
  - 
+ IPV6-MIB
+ NOTIFICATION-LOG-MIB
  => configure Traps logs

# 5 - Configure basic SNMP-Trap :

## Agent configuration :

/etc/snmp/snmpd.conf
```
[...]
trapsink 10.10.10.2 public
```

## Listener configration

/etc/snmp/snmptradp.conf
```
authCommunity   log,execute,net public
```

Launch test trap listener : `snmptrapd`

=> Trap received on cold start

# 6 - SNMP request with pySNMP

Import docker image python:latest
`apt-get update && apt-get install -y net-tools iproute2`

Interface configuration :
```
# Static config for eth0
auto eth0
iface eth0 inet static
	address 10.10.10.3
	netmask 255.255.255.0
	gateway 10.10.10.0
	up echo nameserver 8.8.8.8 > /etc/resolv.conf
```

Edit switch configuration:
```
[...]
# Static config for eth1
auto eth1
iface eth1 inet static
	address 10.10.10.10
	netmask 255.255.255.0
	gateway 10.10.10.0
	up echo nameserver 8.8.8.8 > /etc/resolv.conf
```

# 7 - Configure agent for traps with DisMan

/etc/snmp/snmpd.conf
```
[...]
# NOTIFICATIONS

createUser antoine SHA password AES
rouser antoine
iquerySecName antoine

trap2sink 192.168.31.1 public
```

test user : `snmpget -u antoine -l authPriv -a SHA -x AES -A password -X password 192.168.31.10 1.3.6.1.2.1.1.1.0`

edit : `rouser antoine noauth` => `snmpget -u antoine -a SHA -x AES -A password -X password 192.168.31.10 1.3.6.1.2.1.1.1.0`

snmpd debug : (/bin/boot.sh)`[ "$SNMP" == "1" ] && /usr/sbin/snmpd -Ddisman -Dhelper:debug`
`-D all`

# 8 - Installation of packages