FROM almalinux:9.5
MAINTAINER "nagato"

# utility
RUN dnf -y install nmap net-tools; \
    dnf clean all;

# openssl
RUN mkdir /ssl_certs; \
    dnf -y install openssl; \
    dnf clean all;

# postfix
RUN dnf -y install postfix cyrus-sasl cyrus-sasl-plain cyrus-sasl-md5; \
    dnf clean all;

# epel repository
RUN dnf -y install epel-release; \
    dnf -y install 'dnf-command(config-manager)'; \
    dnf config-manager --set-enabled crb; \
    dnf clean all;

# sasl-xoauth2
RUN dnf -y install sasl-xoauth2; \
    dnf clean all;

# logrotate + cron
RUN dnf -y install logrotate cronie && dnf clean all

# rsyslog
RUN dnf -y install rsyslog; \
    sed -i 's/\(SysSock\.Use\)="off"/\1="on"/' /etc/rsyslog.conf; \
    sed -i 's/\(^module.*load.*imjournal.*\)/#\1/' /etc/rsyslog.conf; \
    sed -i 's/\(.*StateFile.*imjournal.*\)/#\1/' /etc/rsyslog.conf; \
    dnf clean all;

# supervisor
RUN dnf -y install supervisor; \
    sed -i 's/^\(nodaemon\)=false/\1=true/' /etc/supervisord.conf; \
    sed -i 's/^;\(user\)=chrism/\1=root/' /etc/supervisord.conf; \
    sed -i 's/^\(\[unix_http_server\]\)/;\1/' /etc/supervisord.conf; \
    sed -i 's/^\(file=\/run\/supervisor\/.*\)/;\1/' /etc/supervisord.conf; \
    { \
    echo '[program:postfix]'; \
    echo 'command=/usr/sbin/postfix -c /etc/postfix start'; \
    echo 'priority=4'; \
    echo 'startsecs=0'; \
    } > /etc/supervisord.d/postfix.ini; \
    { \
    echo '[program:rsyslog]'; \
    echo 'command=/usr/sbin/rsyslogd -n'; \
    echo 'priority=2'; \
    } > /etc/supervisord.d/rsyslog.ini; \
    { \
    echo '[program:crond]'; \
    echo 'command=/usr/sbin/crond -n'; \
    echo 'priority=1'; \
    } > /etc/supervisord.d/crond.ini; \
    { \
    echo '[program:tail]'; \
    echo 'command=/usr/bin/tail -F /var/log/maillog'; \
    echo 'priority=1'; \
    echo 'stdout_logfile=/dev/fd/1'; \
    echo 'stdout_logfile_maxbytes=0'; \
    } > /etc/supervisord.d/tail.ini; \
    dnf clean all;

# Copy Scripts
COPY       scripts/                    /scripts/

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

