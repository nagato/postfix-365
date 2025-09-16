#!/bin/sh
set -e

# Create logrotate rule if missing
if [ ! -f /etc/logrotate.d/postfix ]; then
  cat > /etc/logrotate.d/postfix <<'EOF'
/var/log/postfix/maillog {
    daily
    rotate 14
    size 50M
    missingok
    notifempty
    compress
    delaycompress
    dateext
    dateformat -%Y%m%d
    create 0640 postfix postfix
    sharedscripts
    postrotate
        /usr/bin/pkill -HUP rsyslogd 2>/dev/null || true
    endscript
}
EOF
fi
