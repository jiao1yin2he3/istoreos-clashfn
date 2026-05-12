#!/bin/sh
set -eu

LIST_FILE="${1:-/tmp/candidate-remove-list.txt}"
BACKUP_DIR="/root/minimal-backup"
LOG_FILE="$BACKUP_DIR/prune.log"
PKG_SNAPSHOT="$BACKUP_DIR/installed-packages-before.txt"
REMOVE_OK="$BACKUP_DIR/removed-packages.txt"
REMOVE_FAIL="$BACKUP_DIR/failed-packages.txt"

mkdir -p "$BACKUP_DIR"
: > "$LOG_FILE"
: > "$REMOVE_OK"
: > "$REMOVE_FAIL"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

if ! command -v opkg >/dev/null 2>&1; then
  log "ERROR: opkg not found; aborting."
  exit 1
fi

if [ ! -f "$LIST_FILE" ]; then
  log "ERROR: candidate list not found: $LIST_FILE"
  exit 1
fi

log "Saving installed package snapshot to $PKG_SNAPSHOT"
opkg list-installed | sort > "$PKG_SNAPSHOT"

log "Starting first-pass prune using $LIST_FILE"
while IFS= read -r pkg || [ -n "$pkg" ]; do
  case "$pkg" in
    ''|'#'*)
      continue
      ;;
  esac

  if opkg list-installed "$pkg" | grep -q "^$pkg "; then
    log "Trying to remove: $pkg"
    if opkg remove "$pkg" >>"$LOG_FILE" 2>&1; then
      echo "$pkg" >> "$REMOVE_OK"
      log "Removed: $pkg"
    else
      echo "$pkg" >> "$REMOVE_FAIL"
      log "FAILED to remove: $pkg"
    fi
  else
    log "Skip not-installed package: $pkg"
  fi
done < "$LIST_FILE"

log "Prune finished. Removed=$(wc -l < "$REMOVE_OK"), Failed=$(wc -l < "$REMOVE_FAIL")"
log "Review $LOG_FILE and smoke-test the image before further pruning."
