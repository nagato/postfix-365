#!/bin/bash
set -euo pipefail

PASSFILE="${INCOMING_SASL_PASSFILE:-/etc/postfix/sasl_users}"
DB_PATH="/etc/sasl2/sasldb2"   # default Cyrus path on Alma/RHEL
DEFAULT_REALM="${DEFAULT_SASL_REALM:-${DOMAIN_NAME:-$(hostname)}}"

# Skip if missing/empty (don't kill entrypoint)
if [[ ! -s "$PASSFILE" ]]; then
  echo "build_sasldb: $PASSFILE missing or empty; skipping."
  exit 0
fi

umask 077
mkdir -p "$(dirname "$DB_PATH")"

# Build into a temp DB, then move into place atomically
TMP_DB="$(mktemp /tmp/sasldb2.XXXXXX)"

# Format: one "username:password" per line; lines starting with # are ignored
while IFS=: read -r user pass; do
  # trim whitespace/CRLF
  user="$(printf %s "$user" | tr -d '[:space:]')"
  pass="$(printf %s "$pass" | tr -d '\r\n')"
  [[ -z "$user" ]] && continue
  [[ "$user" =~ ^# ]] && continue

  # 1) bare username (what clients will use)
  printf %s "$pass" | saslpasswd2 -f "$TMP_DB" -p -c "$user"

  # 2) realm-qualified entry so Cyrus' default realm also matches
  printf %s "$pass" | saslpasswd2 -f "$TMP_DB" -p -c -u "$DEFAULT_REALM" "$user"
done < "$PASSFILE"

# Install DB and set perms so smtpd (user 'postfix') can read it
mv -f "$TMP_DB" "$DB_PATH"
chown root:root "$DB_PATH"
chgrp postfix "$DB_PATH" 2>/dev/null || true
chmod 640 "$DB_PATH"

# Optional: list users for debugging
sasldblistusers2 -f "$DB_PATH" || true
