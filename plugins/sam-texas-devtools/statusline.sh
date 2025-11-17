#!/bin/bash
# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Show git branch
if [ -d ".git" ]; then
  GIT_BRANCH=$(git branch --show-current 2>/dev/null)
  echo "[$MODEL_DISPLAY] 📁 ${CURRENT_DIR##*/} | 🌿 $GIT_BRANCH"
else
  echo "[$MODEL_DISPLAY] 📁 ${CURRENT_DIR##*/}"
fi
