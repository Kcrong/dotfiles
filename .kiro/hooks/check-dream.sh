#!/bin/bash
set -euo pipefail

DREAM_INTERVAL_DAYS=14
MIN_EVOLVED_FILES=5
TRANSCRIPT_DIR="$HOME/.kiro/transcripts"
EVOLVED_DIR="$HOME/.kiro/knowledge/evolved"
LAST_DREAM_FILE="$TRANSCRIPT_DIR/.last-dream"
TODAY=$(date +%Y-%m-%d)

# Seed if missing and exit
if [ ! -f "$LAST_DREAM_FILE" ]; then
  echo "$TODAY" > "$LAST_DREAM_FILE"
  exit 0
fi

# Gate 1: interval check
LAST_DREAM=$(cat "$LAST_DREAM_FILE")
LAST_EPOCH=$(date -j -f "%Y-%m-%d" "$LAST_DREAM" +%s 2>/dev/null)
TODAY_EPOCH=$(date -j -f "%Y-%m-%d" "$TODAY" +%s 2>/dev/null)
DAYS_SINCE=$(( (TODAY_EPOCH - LAST_EPOCH) / 86400 ))
[ "$DAYS_SINCE" -lt "$DREAM_INTERVAL_DAYS" ] && exit 0

# Gate 2: minimum evolved files
EVOLVED_COUNT=$(find "$EVOLVED_DIR" -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
[ "$EVOLVED_COUNT" -lt "$MIN_EVOLVED_FILES" ] && exit 0

cat <<PROMPT
[Kiro Evolve — Knowledge Consolidation (Dream)]

There are $EVOLVED_COUNT evolved knowledge files and it's been $DAYS_SINCE days since the last consolidation. Time for a dream cycle.

Suggest a knowledge consolidation to the user. When they agree:

1. Read ALL files in ~/.kiro/knowledge/evolved/ and ~/.kiro/steering/
2. Analyze evolved files for:
   - Staleness: relative dates, outdated references
   - Contradictions: between files or against steering docs
   - Overlap and bloat: files covering the same topic, files over ~50 lines
   - Accuracy: evolved content that duplicates or conflicts with steering
3. For each issue, propose a specific change with FULL FILE CONTENT shown. For merges, show the consolidated file and note which files it replaces. For deletions, explain why.
4. Present proposals ONE AT A TIME, maximum 5. Ask "Approve, edit, or reject?" and WAIT.
5. After consolidation, update the dream tracker: echo "$TODAY" > $LAST_DREAM_FILE

IMPORTANT: This is a CONSOLIDATION pass, not a review. Do NOT analyze transcripts or propose new knowledge. Focus only on improving what's already graduated.
PROMPT
