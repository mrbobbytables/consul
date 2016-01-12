FROM mrbobbytables/ubuntu-base:1.1.0

ENV VERSION_CONSUL=0.6.1

RUN  mkdir -p /etc/consul/conf.d  \
 && mkdir -p /var/consul/data     \
 && mkdir -p /var/consul/web      \
 && wget -O /tmp/consul.zip       \
    https://releases.hashicorp.com/consul/${VERSION_CONSUL}/consul_${VERSION_CONSUL}_linux_amd64.zip  \
 && wget -O /tmp/consul-web.zip   \
    https://releases.hashicorp.com/consul/${VERSION_CONSUL}/consul_${VERSION_CONSUL}_web_ui.zip  \
 && unzip /tmp/consul.zip -d /usr/local/bin       \
 && unzip /tmp/consul-web.zip -d /var/consul/web  \
 && rm -rf /tmp/*

COPY ./skel /

RUN chmod +x init.sh              \
 && chmod 640 /etc/logrotate.d/*  \
 && chown -R logstash-forwarder:logstash-forwarder /opt/logstash-forwarder


 CMD ["./init.sh"]
