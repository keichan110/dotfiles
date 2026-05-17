#!/bin/sh
# Claude Code Status Line Script

input=$(cat)

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# $1 = percentage (0-100), $2 = number of segments
make_bar() {
  pct_val="$1"
  segments="$2"
  filled=$(( (pct_val * segments + 99) / 100 ))
  if [ "$filled" -gt "$segments" ]; then filled=$segments; fi
  empty=$(( segments - filled ))
  b=""
  i=0
  while [ "$i" -lt "$filled" ]; do b="${b}▰"; i=$(( i + 1 )); done
  i=0
  while [ "$i" -lt "$empty" ]; do b="${b}▱"; i=$(( i + 1 )); done
  printf '%s' "$b"
}

# --- Context window (10 segments) ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  ctx_bar=$(make_bar "$used_int" 20)
  ctx_display="${ctx_bar} ${used_int}%"
else
  ctx_display="▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱ --%"
fi

# --- Git branch ---
branch=$(git -C "$(echo "$input" | jq -r '.workspace.current_dir // "."')" \
  --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# --- Line 1 ---
if [ -n "$branch" ]; then
  line1="[${model}] ${ctx_display} | ${branch}"
else
  line1="[${model}] ${ctx_display}"
fi

# --- Rate limits (5 segments each) ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

line2=""

if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  five_bar=$(make_bar "$five_int" 10)
  if [ -n "$five_reset" ]; then
    five_time=$(date -r "$five_reset" "+%H:%M" 2>/dev/null || date -d "@${five_reset}" "+%H:%M" 2>/dev/null || echo "")
    five_str="5h: ${five_bar} ${five_int}% (~${five_time})"
  else
    five_str="5h: ${five_bar} ${five_int}%"
  fi
  line2="${five_str}"
fi

if [ -n "$seven_pct" ]; then
  seven_int=$(printf '%.0f' "$seven_pct")
  seven_bar=$(make_bar "$seven_int" 10)
  if [ -n "$seven_reset" ]; then
    seven_time=$(date -r "$seven_reset" "+%-m/%-d %H:%M" 2>/dev/null || date -d "@${seven_reset}" "+%-m/%-d %H:%M" 2>/dev/null || echo "")
    seven_str="7d: ${seven_bar} ${seven_int}% (~${seven_time})"
  else
    seven_str="7d: ${seven_bar} ${seven_int}%"
  fi
  if [ -n "$line2" ]; then
    line2="${line2} | ${seven_str}"
  else
    line2="${seven_str}"
  fi
fi

# --- Output ---
if [ -n "$line2" ]; then
  printf '%s\n%s' "$line1" "$line2"
else
  printf '%s' "$line1"
fi
