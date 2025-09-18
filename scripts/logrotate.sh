#!/bin/sh
set -eu

# Ensure required dirs
mkdir -p /etc/logrotate.d /etc/cron.daily /var/lib/logrotate

# 1) Postfix logrotate rule (idempotent)
if [ ! -f /etc/logrotate.d/postfix ]; then
  cat > /etc/logrotate.d/postfix <<'EOF'
/var/log/postfix/maillog {
    size 50M
    rotate 14
    missingok
    notifempty
    compress
    delaycompress
    dateext
    dateformat -%Y%m%d
    create 0640 postfix postfix
    sharedscripts
    postrotate
        /usr/sbin/postfix reload >/dev/null 2>&1 || true
    endscript
}
EOF
fi

# 2) Cron hook to run logrotate daily
if [ ! -x /etc/cron.daily/logrotate ]; then
  cat > /etc/cron.daily/logrotate <<'EOF'
#!/bin/sh
/usr/sbin/logrotate -s /var/lib/logrotate/logrotate.status /etc/logrotate.conf
EOF
  chmod +x /etc/cron.daily/logrotate
fi
