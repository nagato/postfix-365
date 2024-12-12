#!/bin/bash -eu
set -e

if [ -e /etc/postfix/sasl_passwd ]; then
 rm -f /etc/postfix/sasl_passwd
fi

{
echo "[${RELAY_HOST}]:${RELAY_HOST_PORT} ${AUTH_USER}:/etc/tokens/${AUTH_USER}"
} >> /etc/postfix/sasl_passwd

cd /etc/postfix
postmap /etc/postfix/sasl_passwd

