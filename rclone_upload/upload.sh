#!/usr/bin/env bash
# Usage: ./upload.sh [--dry-run] [--only SUBSTRING] [mapping.tsv]
# Reads type<TAB>source<TAB>dest rows and uploads each with rclone.
set -u
REMOTE="bossdbwong:upload-bossdb-3gqks4kjnacpujok"
DRY=""; [[ "${1:-}" == "--dry-run" ]] && { DRY="--dry-run"; shift; }
ONLY=""; [[ "${1:-}" == "--only" ]] && { ONLY="$2"; shift 2; }
MAP="${1:-$(dirname "$0")/mapping.tsv}"
LOG="$(dirname "$0")/upload_$(date +%Y%m%d_%H%M%S).log"
while IFS=$'\t' read -r type src dest; do
  [[ -z "$type" || "$type" == \#* ]] && continue
  [[ -n "$ONLY" && "$dest" != *"$ONLY"* ]] && continue
  if [[ ! -e "$src" ]]; then echo "MISSING: $src" | tee -a "$LOG"; continue; fi
  echo ">> $type: $src -> $dest" | tee -a "$LOG"
  case "$type" in
    dirtif) rclone copy "$src" "$REMOTE/$dest" --include "*.tif" --include "*.TIF" \
              --s3-no-check-bucket --transfers 8 --s3-chunk-size 64M --stats 30s --stats-one-line $DRY --log-file "$LOG" --log-level INFO ;;
    file)   rclone copyto "$src" "$REMOTE/$dest" --s3-no-check-bucket --stats 30s --stats-one-line $DRY --log-file "$LOG" --log-level INFO ;;
    *)      echo "BAD TYPE: $type" | tee -a "$LOG" ;;
  esac || echo "FAILED: $src" | tee -a "$LOG"
done < "$MAP"
