#!/bin/bash
set -euo pipefail

EVENT=$(cat)
HOOK_EVENT=$(echo "$EVENT" | jq -r '.hook_event_name')
TODAY=$(date +%Y-%m-%d)
TRANSCRIPT_DIR="$HOME/.kiro/transcripts"
FILE="$TRANSCRIPT_DIR/$TODAY.md"
TIMESTAMP=$(date +%H:%M:%S)

[ ! -f "$FILE" ] && echo "# Transcript — $TODAY" > "$FILE"

case "$HOOK_EVENT" in
  userPromptSubmit)
    PROMPT=$(echo "$EVENT" | jq -r '.prompt // empty')
    [ -n "$PROMPT" ] && printf '\n## User — %s\n\n%s\n' "$TIMESTAMP" "$PROMPT" >> "$FILE"
    ;;
  stop)
    RESPONSE=$(echo "$EVENT" | jq -r '.assistant_response // empty')
    [ -n "$RESPONSE" ] && printf '\n## Assistant — %s\n\n%s\n' "$TIMESTAMP" "$RESPONSE" >> "$FILE"
    ;;
esac
