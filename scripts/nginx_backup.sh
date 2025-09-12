#!/usr/bin/env bash
set -euo pipefail
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

DATE="$(date +%F)"
DEST="/backups"
ARCHIVE="$DEST/nginx_backup_${DATE}.tar.gz"
VERIFY="$DEST/nginx_verify_${DATE}.log"

mkdir -p "$DEST"

# Candidate source dirs (only include existing ones)
CANDIDATES=(/etc/nginx /usr/share/nginx/html /var/www /var/log/nginx)
SOURCES=()
for d in "${CANDIDATES[@]}"; do [[ -e "$d" ]] && SOURCES+=("$d"); done

{
  echo "== Nginx backup on $(date -Is) =="
  echo "Sources considered: ${CANDIDATES[*]}"
  echo "Sources included: ${SOURCES[*]:-<none>}"
} >"$VERIFY"

if ((${#SOURCES[@]}==0)); then
  echo "No Nginx sources found; nothing to back up." | tee -a "$VERIFY"
  exit 0
fi

tar -czf "$ARCHIVE" --ignore-failed-read --warning=no-file-changed "${SOURCES[@]}"
echo "Archive created: $ARCHIVE" | tee -a "$VERIFY"

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
