#!/usr/bin/env bash
set -euo pipefail
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

DATE="$(date +%F)"
DEST="/backups"
ARCHIVE="$DEST/apache_backup_${DATE}.tar.gz"
VERIFY="$DEST/apache_verify_${DATE}.log"

mkdir -p "$DEST"

# Candidate source dirs (only include existing ones)
CANDIDATES=(/etc/httpd /var/www /var/log/httpd /usr/share/httpd)
SOURCES=()
for d in "${CANDIDATES[@]}"; do [[ -e "$d" ]] && SOURCES+=("$d"); done

{
  echo "== Apache backup on $(date -Is) =="
  echo "Sources considered: ${CANDIDATES[*]}"
  echo "Sources included: ${SOURCES[*]:-<none>}"
} >"$VERIFY"

if ((${#SOURCES[@]}==0)); then
  echo "No Apache sources found; nothing to back up." | tee -a "$VERIFY"
  exit 0
fi

# Create archive (ignore files that disappear during read)
tar -czf "$ARCHIVE" --ignore-failed-read --warning=no-file-changed "${SOURCES[@]}"
echo "Archive created: $ARCHIVE" | tee -a "$VERIFY"

# Verify: list a few entries, size and checksum
{
  echo
  echo "First 20 entries in archive:"
  tar -tzf "$ARCHIVE" | head -n 20
  echo
  echo "Archive size:"
  ls -lh "$ARCHIVE"
  echo
  echo "SHA256:"
  sha256sum "$ARCHIVE"
  echo "Status: OK"
} >>"$VERIFY"
