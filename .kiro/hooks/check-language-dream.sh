#!/bin/bash
set -euo pipefail

DREAM_INTERVAL_DAYS=14
MIN_EVOLVED_FILES=5
TRANSCRIPT_DIR="$HOME/.kiro/transcripts/language"
EVOLVED_DIR="$HOME/.kiro/knowledge/evolved-language"
LAST_DREAM_FILE="$TRANSCRIPT_DIR/.last-dream"
TODAY=$(date +%Y-%m-%d)

mkdir -p "$TRANSCRIPT_DIR" "$EVOLVED_DIR"

if [ ! -f "$LAST_DREAM_FILE" ]; then
  echo "$TODAY" > "$LAST_DREAM_FILE"
  exit 0
fi

LAST_DREAM=$(cat "$LAST_DREAM_FILE")
LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_DREAM" +%s 2>/dev/null)
TODAY_EPOCH=$(date -j -f "%Y-%m-%d" "$TODAY" +%s 2>/dev/null)
DAYS_SINCE=$(( (TODAY_EPOCH - LAST_EPOCH) / 86400 ))
[ "$DAYS_SINCE" -lt "$DREAM_INTERVAL_DAYS" ] && exit 0

EVOLVED_COUNT=$(find "$EVOLVED_DIR" -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
[ "$EVOLVED_COUNT" -lt "$MIN_EVOLVED_FILES" ] && exit 0

cat <<PROMPT
[Language Study — Knowledge Consolidation (Dream)]

There are $EVOLVED_COUNT language feedback files and it has been $DAYS_SINCE days since the last consolidation. Time for a consolidation cycle.

Suggest a language feedback consolidation to the user. When they agree:

1. Read ALL files in ~/.kiro/knowledge/evolved-language/
2. Analyze feedback files for:
   - Staleness: grammar issues already improved, no longer relevant feedback
   - Overlap: multiple files covering the same language issues
   - Contradictions: conflicting advice between files
3. For each proposal, show full file content. For merges, note which files are replaced.
4. Present proposals one at a time, maximum 5. Ask "Approve, edit, or reject?" and wait.
5. After consolidation: echo "$TODAY" > $LAST_DREAM_FILE

IMPORTANT: This is a CONSOLIDATION pass only. Do NOT analyze transcripts or propose new feedback.
PROMPT
