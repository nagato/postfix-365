#!/bin/bash -eu

ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

if [ ! -e /ssl_certs/cert.pem ] || [ ! -e /ssl_certs/key.pem ]; then
  openssl genrsa -out "/ssl_certs/key.pem" 2048 &>/dev/null
  openssl req -new -key "/ssl_certs/key.pem" -subj "/CN=${HOSTNAME}" -out "/ssl_certs/csr.pem"
  openssl x509 -req -days 36500 -in "/ssl_certs/csr.pem" -signkey "/ssl_certs/key.pem" -out "/ssl_certs/cert.pem" &>/dev/null
fi

chmod +x /scripts/*.sh
. /scripts/postfix.sh
. /scripts/sasl_passwd.sh
. /scripts/sasl-xoauth2.conf.sh
/scripts/build_sasldb.sh
/scripts/logrotate.sh

exec "$@"
