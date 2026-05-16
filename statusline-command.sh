#!/usr/bin/env bash
# Claude Code status line
# Format: ~/my-project | main | Opus 4.6 | Context: [████░░░░░░] 35% • high /effort
input=$(cat)

# --- Working directory (short ~/... style) ---
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
[ -z "$dir" ] && dir=$(pwd)
home="$HOME"
if [[ "$dir" == "$home"* ]]; then
  dir_display="~${dir#$home}"
else
  dir_display="$dir"
fi

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // empty')

# --- Context window usage ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Git branch + dirty file count ---
git_str=""
if git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$dirty" -gt 0 ]; then
      git_str="${branch}(+${dirty})"
    else
      git_str="${branch}"
    fi
  fi
fi

# --- Effort ---
effort=$(echo "$input" | jq -r '.effort.level // empty')

# --- ANSI colors ---
BOLD=$'\033[1m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
ORANGE=$'\033[38;5;208m'
RED=$'\033[31m'
GRAY=$'\033[38;5;236m'
MAGENTA=$'\033[35m'
RESET=$'\033[0m'

# --- Assemble ---
out=""

# Directory
out+=$(printf "${BOLD}${CYAN}%s${RESET}" "$dir_display")

# Git branch
if [ -n "$git_str" ]; then
  out+=$(printf " | ${GREEN}%s${RESET}" "$git_str")
fi

# Model
if [ -n "$model" ]; then
  out+=$(printf " | ${BOLD}%s${RESET}" "$model")
fi

# Context bar with dynamic color
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct")
  filled=$(( pct_int * 15 / 100 ))
  empty=$(( 15 - filled ))

  if [ "$pct_int" -ge 90 ]; then
    BAR_COLOR="$RED"
  elif [ "$pct_int" -ge 50 ]; then
    BAR_COLOR="$ORANGE"
  else
    BAR_COLOR="$GREEN"
  fi

  bar_filled=""
  bar_empty=""
  for i in $(seq 1 $filled); do bar_filled="${bar_filled}${BAR_COLOR}█"; done
  for i in $(seq 1 $empty);  do bar_empty="${bar_empty}${GRAY}█"; done

  out+=$(printf " | Context: %s%s%s %s%d%%%s" "$bar_filled" "$bar_empty" "$RESET" "$BAR_COLOR" "$pct_int" "$RESET")
fi

# Effort
if [ -n "$effort" ]; then
  out+=$(printf " • ${MAGENTA}%s /effort${RESET}" "$effort")
fi

printf "%s" "$out"
