#!/bin/bash
set -euo pipefail

CLEANUP_INTERVAL_DAYS=90
OLD_THRESHOLD_DAYS=90
TRANSCRIPT_DIR="$HOME/.kiro/transcripts"
LAST_CLEANUP_FILE="$TRANSCRIPT_DIR/.last-cleanup-check"
TODAY=$(date +%Y-%m-%d)

# Seed if missing and exit
if [ ! -f "$LAST_CLEANUP_FILE" ]; then
  echo "$TODAY" > "$LAST_CLEANUP_FILE"
  exit 0
fi

LAST_CLEANUP=$(cat "$LAST_CLEANUP_FILE")
LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_CLEANUP" +%s 2>/dev/null)
TODAY_EPOCH=$(date -j -f "%Y-%m-%d" "$TODAY" +%s 2>/dev/null)
DAYS_SINCE=$(( (TODAY_EPOCH - LAST_EPOCH) / 86400 ))

[ "$DAYS_SINCE" -lt "$CLEANUP_INTERVAL_DAYS" ] && exit 0

CUTOFF=$(date -v-${OLD_THRESHOLD_DAYS}d +%Y-%m-%d)

REVIEWED_OLD=()
UNREVIEWED_OLD=()
for f in "$TRANSCRIPT_DIR"/????-??-??.md; do
  [ -f "$f" ] || continue
  FDATE=$(basename "$f" .md)
  [[ "$FDATE" < "$CUTOFF" ]] || continue
  if [ -f "$TRANSCRIPT_DIR/.reviewed-$FDATE" ]; then
    SIZE=$(wc -c < "$f" | tr -d ' ')
    REVIEWED_OLD+=("$FDATE|$SIZE")
  else
    UNREVIEWED_OLD+=("$FDATE")
  fi
done

# No reviewed old files — reset timer and exit
if [ ${#REVIEWED_OLD[@]} -eq 0 ]; then
  echo "$TODAY" > "$LAST_CLEANUP_FILE"
  exit 0
fi

FILE_LIST=""
for entry in "${REVIEWED_OLD[@]}"; do
  FDATE="${entry%%|*}"
  SIZE="${entry##*|}"
  FILE_LIST="$FILE_LIST
  - $FDATE ($SIZE bytes)"
done

UNREVIEWED_NOTE=""
if [ ${#UNREVIEWED_OLD[@]} -gt 0 ]; then
  UNREVIEWED_NOTE="
Note: ${#UNREVIEWED_OLD[@]} old transcript(s) are excluded because they haven't been reviewed yet. Consider running a transcript review first to process them."
fi

cat <<PROMPT
[Kiro Evolve — Transcript Cleanup Available]

There are ${#REVIEWED_OLD[@]} old reviewed transcript(s) (older than $OLD_THRESHOLD_DAYS days) that could be cleaned up:
$FILE_LIST

Ask the user if they want to review old transcripts for cleanup. When they agree:

1. List each transcript with its date and size. Let the user pick individually — NEVER suggest deleting all.
2. Require explicit per-file confirmation before deleting.
3. When deleting a transcript, also delete its corresponding .reviewed marker: rm ~/.kiro/transcripts/.reviewed-YYYY-MM-DD
4. Update .last-cleanup-check with today's date whether user accepts or declines: echo "$TODAY" > $LAST_CLEANUP_FILE
${UNREVIEWED_NOTE}
PROMPT
