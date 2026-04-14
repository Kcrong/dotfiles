#!/bin/bash
set -euo pipefail

REVIEW_INTERVAL_DAYS=7
TRANSCRIPT_DIR="$HOME/.kiro/transcripts"
LAST_REVIEW_FILE="$TRANSCRIPT_DIR/.last-review"
FIRST_REVIEW_MARKER="$TRANSCRIPT_DIR/.first-review-done"
TODAY=$(date +%Y-%m-%d)

# Seed if missing
if [ ! -f "$LAST_REVIEW_FILE" ]; then
  date -v-${REVIEW_INTERVAL_DAYS}d +%Y-%m-%d > "$LAST_REVIEW_FILE"
fi

LAST_REVIEW=$(cat "$LAST_REVIEW_FILE")
LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_REVIEW" +%s 2>/dev/null)
TODAY_EPOCH=$(date -j -f "%Y-%m-%d" "$TODAY" +%s 2>/dev/null)
DAYS_SINCE=$(( (TODAY_EPOCH - LAST_EPOCH) / 86400 ))

[ "$DAYS_SINCE" -lt "$REVIEW_INTERVAL_DAYS" ] && exit 0

# Find transcripts with filenames dated after last review
NEW_TRANSCRIPTS=()
for f in "$TRANSCRIPT_DIR"/????-??-??.md; do
  [ -f "$f" ] || continue
  FDATE=$(basename "$f" .md)
  if [[ "$FDATE" > "$LAST_REVIEW" ]]; then
    NEW_TRANSCRIPTS+=("$f")
  fi
done

[ ${#NEW_TRANSCRIPTS[@]} -eq 0 ] && exit 0

FIRST_REVIEW_NOTE=""
if [ ! -f "$FIRST_REVIEW_MARKER" ]; then
  FIRST_REVIEW_NOTE="

FIRST REVIEW NOTE: If the user completes this review and approves at least one file, congratulate them on their first Kiro Evolve review. Then mention: 'If you found this useful, consider sharing what Kiro learned about you in #kiro-evolve-interest on Slack. People who share their experience earn a phonetool icon. Totally optional — just a way to help others see what Kiro Evolve can do.' Then create the marker file: touch $FIRST_REVIEW_MARKER"
fi

FILE_LIST=""
for f in "${NEW_TRANSCRIPTS[@]}"; do
  FILE_LIST="$FILE_LIST
  - $f"
done

cat <<PROMPT
[Kiro Evolve — Transcript Review Available]

There are ${#NEW_TRANSCRIPTS[@]} new transcript(s) since the last review ($LAST_REVIEW):
$FILE_LIST

At a natural point in the conversation, suggest a transcript review to the user. When they agree:

1. First read ALL existing files in ~/.kiro/knowledge/evolved/ AND ~/.kiro/steering/ to understand what's already captured.
2. Then read each transcript listed above.
3. Apply a filter gate before proposing anything: "Would this change how the assistant interacts with the user in a future session?" If no, skip it.
   - Evolve IS for: preferences, business context, stakeholder dynamics, calibration patterns, reusable frameworks, tone/voice refinements.
   - Evolve is NOT for: debugging sessions, tool configuration, one-off scripts, prompt engineering fixes, task execution artifacts.
4. Analyze across all transcripts looking for:
   - Learning preferences (format, length, tone patterns)
   - What worked vs. didn't (first-try accepts vs. revision patterns)
   - Business data points worth remembering (metrics, thresholds, benchmarks)
   - Calibration (over/under-explaining, wrong assumptions)
   - Patterns to adjust for (recurring workflows, stakeholder-specific preferences)
   - Reusable frameworks or templates
5. When graduating knowledge, convert ALL relative time references to absolute dates. "This week" → "week of $(date +%Y-%m-%d)". "Recently" → "as of $(date +%B\ %Y)". "Last quarter" → compute the actual quarter.
6. For each candidate, check whether it belongs as an update to an existing knowledge or steering file rather than a new file. Prefer updating existing files over creating new ones. Only update existing files if the new insight would change the first draft of a future output.
7. Show FULL FILE CONTENT for each proposal (not descriptions). For updates, show the complete updated file and note what changed.
8. Present proposals ONE AT A TIME. Ask "Approve, edit, or reject?" and WAIT for user response before the next. Maximum 5 proposals per review.
9. Write approved files to ~/.kiro/knowledge/evolved/
10. May also propose edits to existing steering docs in ~/.kiro/steering/
11. After review: mark each transcript reviewed via touch ~/.kiro/transcripts/.reviewed-YYYY-MM-DD (matching each transcript's date)
12. Update .last-review with today's date: echo "$TODAY" > $LAST_REVIEW_FILE
${FIRST_REVIEW_NOTE}
PROMPT
