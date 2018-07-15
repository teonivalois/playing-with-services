FROM haproxy:1.7
COPY ./config/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg