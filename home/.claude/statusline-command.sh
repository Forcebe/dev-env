#!/bin/sh
# Claude Code status line - inspired by Starship config

input=$(cat)

user=$(whoami)
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
short_dir=$(echo "$dir" | sed "s|$HOME|~|")

# Git branch and status (skip optional locks)
git_branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
git_status=""
if [ -n "$git_branch" ]; then
  if ! git -C "$dir" --no-optional-locks diff --quiet 2>/dev/null || \
     ! git -C "$dir" --no-optional-locks diff --cached --quiet 2>/dev/null; then
    git_status="*"
  fi
  git_info=" | ${git_branch}${git_status}"
fi

time_str=$(date +%H:%M)
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_info=""
if [ -n "$used" ]; then
  ctx_info=" | ctx: ${used}%"
fi

printf "%s  %s%s | %s%s | %s" \
  "$user" \
  "$short_dir" \
  "$git_info" \
  "$model" \
  "$ctx_info" \
  "$time_str"
