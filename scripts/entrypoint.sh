#!/bin/bash
set -euo pipefail

# Timezone (fallback to UTC if invalid/missing)
TZFILE="/usr/share/zoneinfo/${TIMEZONE:-UTC}"
if [ -f "$TZFILE" ]; then
  ln -fs "$TZFILE" /etc/localtime
else
  ln -fs /usr/share/zoneinfo/UTC /etc/localtime
fi

# Ensure script perms (or move this to Dockerfile)
find /scripts -maxdepth 1 -type f -name '*.sh' -exec chmod +x {} +

# Self-signed certs if none provided
mkdir -p /ssl_certs
umask 077
if [ ! -e /ssl_certs/cert.pem ] || [ ! -e /ssl_certs/key.pem ]; then
  # one-liner: key + long-lived self-signed cert
  openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout /ssl_certs/key.pem -out /ssl_certs/cert.pem \
    -days 36500 -subj "/CN=${HOSTNAME}"
fi
chown root:root /ssl_certs/key.pem /ssl_certs/cert.pem
chmod 600 /ssl_certs/key.pem
chmod 644 /ssl_certs/cert.pem

# Configure services
/scripts/postfix.sh
/scripts/sasl_passwd.sh
/scripts/sasl-xoauth2.conf.sh
/scripts/build_sasldb.sh
/scripts/logrotate.sh

# Hand over to supervisord (or your CMD)
exec "$@"
