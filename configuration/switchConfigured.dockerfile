FROM gns3/ovs-snmp:latest

RUN apk update && \
    apk add stress-ng net-snmp-tools
COPY snmp/snmpd.conf /etc/snmp/snmpd.conf
COPY boot.sh /bin/boot.sh
RUN chmod a+x /bin/boot.sh

WORKDIR /home 
COPY test/* .
RUN chmod -R a+x .

CMD ["/bin/boot.sh"]