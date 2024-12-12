#!/bin/bash -eu
set -e

if [ -e /etc/sasl-xoauth2.conf ]; then
 rm -f /etc/sasl-xoauth2.conf
fi

{
echo "{"
echo "  \"client_id\": \"${CLIENT_ID}\","
echo "  \"client_secret\": \"${CLIENT_SECRET}\","
echo "  \"token_endpoint\": \"https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/token\","
echo "  \"log_full_trace_on_failure\": \"yes\","
echo "  \"always_log_to_syslog\": \"yes\""
echo "}"
} >> /etc/sasl-xoauth2.conf


