#!/bin/bash
set -euo pipefail

# --- prep ---
chown postfix:postfix /etc/tokens -R 2>/dev/null || true

LOG_BASE="/var/log/postfix"
LOG_FILE="${LOG_BASE}/maillog"
mkdir -p "$LOG_BASE"
chown -R postfix:postfix "$LOG_BASE"

# Realm for clients that omit one (aligns with build_sasldb.sh)
DEFAULT_REALM="${DEFAULT_SASL_REALM:-${DOMAIN_NAME:-${HOSTNAME}}}"

# --- main.cf (single pass, no trailing comments on value lines) ---
cat > /etc/postfix/main.cf <<EOF
############################################
# Postfix main.cf (generated at container start)
############################################

# ---------- [base] ----------
myhostname = ${HOSTNAME}
mydomain = ${DOMAIN_NAME}
inet_interfaces = all
inet_protocols = ipv4
myorigin = \$mydomain
mydestination = \$myhostname
mynetworks = 127.0.0.0/8, ${MY_NETWORK}
home_mailbox = Maildir/
disable_vrfy_command = yes
smtpd_helo_required = yes
alias_database = hash:/etc/aliases
alias_maps = hash:/etc/aliases
smtpd_banner = \$myhostname ESMTP
message_size_limit = ${MESSAGE_SIZE_LIMIT}

# ---------- [smtp] (outbound relay to 365) ----------
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options =
smtp_sasl_mechanism_filter = xoauth2
smtp_tls_security_level = encrypt
smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.trust.crt
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache
relayhost = [${RELAY_HOST}]:${RELAY_HOST_PORT}

# ---------- [smtpd] (inbound) ----------
smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
smtpd_sasl_auth_enable = yes
smtpd_sasl_type = cyrus
smtpd_sasl_security_options = noanonymous
smtpd_sasl_local_domain = ${DEFAULT_REALM}
broken_sasl_auth_clients = yes

# ---------- [smtpd/tls] ----------
smtpd_tls_security_level = may
smtpd_tls_auth_only = yes
smtpd_tls_cert_file = /ssl_certs/cert.pem
smtpd_tls_key_file  = /ssl_certs/key.pem
smtpd_tls_protocols = !SSLv2 !SSLv3 !TLSv1 !TLSv1.1
smtpd_tls_loglevel = 1

# ---------- [logging] ----------
maillog_file = ${LOG_FILE}
EOF

# Symlinks for tools that expect classic paths
ln -sf "${LOG_FILE}" /var/log/maillog
ln -sf "${LOG_FILE}" /var/log/mail.log

# --- Cyrus SASL server config for smtpd ---
mkdir -p /etc/sasl2
cat > /etc/sasl2/smtpd.conf <<'EOF'
pwcheck_method: auxprop
auxprop_plugin: sasldb
mech_list: PLAIN LOGIN
sasldb_path: /etc/sasl2/sasldb2
log_level: 7
EOF
chmod 644 /etc/sasl2/smtpd.conf

# Build aliases db
newaliases
