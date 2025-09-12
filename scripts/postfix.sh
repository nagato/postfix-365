#!/bin/bash -eu
set -e

chown postfix:postfix /etc/tokens -R

if [ -e /etc/postfix/main.cf ]; then
 rm -f /etc/postfix/main.cf
fi

echo "# BEGIN SMTP SETTINGS" > /etc/postfix/main.cf

if [ ${DISABLE_SMTP_AUTH_ON_PORT_25,,} = "true" ]; then
  echo "smtpd_sasl_auth_enable = no" >> /etc/postfix/main.cf
else
  echo "smtpd_sasl_auth_enable = yes" >> /etc/postfix/main.cf
fi

{
echo ""
echo "myhostname = ${HOSTNAME}"
echo "mydomain = ${DOMAIN_NAME}"
echo "inet_interfaces = all"
echo "inet_protocols = ipv4"
echo 'myorigin = $mydomain'
echo 'mydestination = $myhostname'
echo "mynetworks = 127.0.0.0/8, ${MY_NETWORK}"
echo "home_mailbox = Maildir/"
echo "disable_vrfy_command = yes"
echo "smtpd_helo_required = yes"
echo "alias_database = hash:/etc/aliases"
echo "alias_maps = hash:/etc/aliases"
echo "smtpd_banner = \$myhostname ESMTP"
echo "message_size_limit = ${MESSAGE_SIZE_LIMIT}"
echo ""
echo "smtp_sasl_auth_enable = yes"
echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
echo "smtp_sasl_security_options ="
echo "smtp_sasl_mechanism_filter = xoauth2"
echo ""
echo "smtp_tls_security_level = encrypt"
echo "smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.trust.crt"
echo 'smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache'
echo ""
echo "relayhost = [${RELAY_HOST}]:${RELAY_HOST_PORT}"
echo "smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination"
echo ""
echo "# END SMTP SETTINGS"
} >> /etc/postfix/main.cf

# --- fixed logfile location under /var/log (persistent-friendly) ---
LOG_BASE="/var/log/postfix"
LOG_FILE="${LOG_BASE}/maillog"

mkdir -p "$LOG_BASE"
touch "$LOG_FILE"
chown -R postfix:postfix "$LOG_BASE"

# Tell Postfix to write here (under default-allowed prefix /var/log)
echo "maillog_file = ${LOG_FILE}" >> /etc/postfix/main.cf

# Optional: keep classic paths working for tools that expect them
ln -sf "${LOG_FILE}" /var/log/maillog
ln -sf "${LOG_FILE}" /var/log/mail.log
# --- end logfile setup ---

cd /etc
newaliases

