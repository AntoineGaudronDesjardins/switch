FROM alpine:latest AS build

# Install the necessary components
RUN apk update && \
    apk add --no-cache wget file g++ make openssl-dev perl-dev net-snmp-tools net-snmp-libs

# Get the source code and extract it
RUN wget https://github.com/net-snmp/net-snmp/archive/v5.9.tar.gz && tar -xzvf v5.9.tar.gz && \
    mkdir -p /netsnmp/5.9/linux-gcc3 && mv v5.9.tar.gz /netsnmp/5.9/v5.9.tar.gz && \
    cd /netsnmp/5.9 && \
    tar -xzvf v5.9.tar.gz && cd net-snmp-5.9

RUN  cd /netsnmp/5.9/net-snmp-5.9 && \
        ./configure  --prefix="/usr" \
            --with-mib-modules="disman/event-mib" \
            --with-mibs="SNMPv2-MIB:DISMAN-EVENT-MIB:IF-MIB:IP-MIB:IP-FORWARD-MIB:TCP-MIB:UDP-MIB:HOST-RESOURCES-MIB:IPV6-MIB:NOTIFICATION-LOG-MIB" \
            --enable-mibs \
            --with-transports="UDP TCP" \
            --with-security-modules="usm tsm" \
            --disable-embedded-perl \
            --enable-mini-agent \
            --with-default-snmp-version="3" \
            --with-sys-contact="antgau@alum.us.es" \
            --with-sys-location="Mi casa" \
            --with-persistent-directory="/var/snmp" \
            --with-logfile="/var/log/snmpd.log" \
            --without-perl-modules \
            --without-python-modules \
            --disable-shared \
            --enable-static \
            --with-pic \
            --with-cc="gcc" CC="gcc" CFLAGS="-m64" \
            --enable-blumenthal-aes && \
        make 2>&1 | tee make.log && \
        make 


# FROM alpine:latest
# COPY --from=build /usr /usr
# RUN apk blabla ..  net-snmp
RUN apk add --no-cache nano openvswitch tcpdump lldpd
RUN mkdir -p /run/openvswitch && mkdir -p /var/log/openvswitch
COPY snmp/snmpd.conf /etc/snmp/snmpd.conf
COPY lldpd.conf /etc/lldpd.d/lldpd.conf
COPY rstp /bin/rstp
RUN chmod a+x /bin/rstp
COPY boot.sh /bin/boot.sh
RUN chmod a+x /bin/boot.sh

VOLUME /etc/openvswitch/
VOLUME /etc/lldpd.d/

CMD ["/bin/boot.sh"]
