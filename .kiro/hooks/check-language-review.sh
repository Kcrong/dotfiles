#!/bin/bash
set -euo pipefail

REVIEW_INTERVAL_DAYS=7
TRANSCRIPT_DIR="$HOME/.kiro/transcripts/language"
EVOLVED_DIR="$HOME/.kiro/knowledge/evolved-language"
LAST_REVIEW_FILE="$TRANSCRIPT_DIR/.last-review"
TODAY=$(date +%Y-%m-%d)

mkdir -p "$TRANSCRIPT_DIR" "$EVOLVED_DIR"

if [ ! -f "$LAST_REVIEW_FILE" ]; then
  date -v-${REVIEW_INTERVAL_DAYS}d +%Y-%m-%d > "$LAST_REVIEW_FILE"
fi

LAST_REVIEW=$(cat "$LAST_REVIEW_FILE")
LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_REVIEW" +%s 2>/dev/null)
TODAY_EPOCH=$(date -j -f "%Y-%m-%d" "$TODAY" +%s 2>/dev/null)
DAYS_SINCE=$(( (TODAY_EPOCH - LAST_EPOCH) / 86400 ))

[ "$DAYS_SINCE" -lt "$REVIEW_INTERVAL_DAYS" ] && exit 0

NEW_TRANSCRIPTS=()
for f in "$TRANSCRIPT_DIR"/????-??-??.md; do
  [ -f "$f" ] || continue
  FDATE=$(basename "$f" .md)
  if [[ "$FDATE" > "$LAST_REVIEW" ]]; then
    NEW_TRANSCRIPTS+=("$f")
  fi
done

[ ${#NEW_TRANSCRIPTS[@]} -eq 0 ] && exit 0

FILE_LIST=""
for f in "${NEW_TRANSCRIPTS[@]}"; do
  FILE_LIST="$FILE_LIST
  - $f"
done

cat <<PROMPT
[Language Study — Periodic Review]

There are ${#NEW_TRANSCRIPTS[@]} new transcript(s) since the last review ($LAST_REVIEW):
$FILE_LIST

At a natural point in the conversation, suggest a language review to the user. When they agree:

1. Read each transcript listed above.
2. Analyze only the user's input (exclude assistant responses).
3. Identify which languages the user used and analyze ALL of them. For each language found, check for:
   - Recurring grammar mistakes (tense, articles, prepositions, particles, conjugation, etc.)
   - Vocabulary patterns (overused words, better alternatives)
   - Sentence structure issues (L1 interference, incomplete sentences, unnatural phrasing)
   - Formality/tone consistency
   - Improvements compared to previous reviews
4. A single feedback file should cover all languages found. Organize by language sections.
5. Write feedback in Korean, but keep original language examples as-is.
6. Save as a new markdown file: $EVOLVED_DIR/feedback-$TODAY.md
   - Never modify existing files. Always create a new file.
   - Save directly without approval.
7. After review: echo "$TODAY" > $LAST_REVIEW_FILE
8. Mark each transcript reviewed: touch $TRANSCRIPT_DIR/.reviewed-YYYY-MM-DD (matching each transcript's date)
PROMPT
