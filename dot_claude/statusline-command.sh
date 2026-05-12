#!/usr/bin/env bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Truncate directory: show last 3 components, prefixed with .../ if truncated
truncate_dir() {
  local dir="$1"
  # Replace $HOME with ~
  dir="${dir/#$HOME/\~}"
  IFS='/' read -ra parts <<< "$dir"
  local count=${#parts[@]}
  if [ "$count" -le 3 ]; then
    echo "$dir"
  else
    echo ".../${parts[$((count-3))]}/${parts[$((count-2))]}/${parts[$((count-1))]}"
  fi
}

short_dir=$(truncate_dir "$cwd")

# Git branch and status (skip locks to avoid blocking)
git_info=""
if git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null); then
  git_status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  dirty=""
  if [ -n "$git_status" ]; then
    dirty="*"
  fi
  git_info=" on  ${git_branch}${dirty}"
fi

# Context usage
context_info=""
if [ -n "$used_pct" ]; then
  printf -v used_int "%.0f" "$used_pct"
  context_info=" | ctx ${used_int}%"
fi

printf "\033[1;34m%s\033[0m%s | %s%s\n" \
  "$short_dir" \
  "$git_info" \
  "$model" \
  "$context_info"
