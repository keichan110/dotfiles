#!/bin/sh
# Claude Code Status Line Script

input=$(cat)

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
effort=$(echo "$input" | jq -r '.effort.level // empty')

# ANSI colors (printf で実際のESC文字を生成)
C_GREEN=$(printf '\033[32m')
C_YELLOW=$(printf '\033[93m')
C_ORANGE=$(printf '\033[33m')
C_RED=$(printf '\033[31m')
C_RESET=$(printf '\033[0m')

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

# $1 = bar string, $2 = color string
color_bar() {
  if [ -n "$2" ]; then
    printf '%s' "${2}${1}${C_RESET}"
  else
    printf '%s' "$1"
  fi
}

# --- Context window ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  ctx_bar=$(make_bar "$used_int" 20)
  if [ "$used_int" -lt 30 ]; then
    bar_color=""
  elif [ "$used_int" -ge 85 ]; then
    bar_color="$C_RED"
  elif [ "$used_int" -ge 70 ]; then
    bar_color="$C_ORANGE"
  elif [ "$used_int" -ge 50 ]; then
    bar_color="$C_YELLOW"
  else
    bar_color="$C_GREEN"
  fi
  if [ -n "$bar_color" ]; then
    ctx_display="${bar_color}${ctx_bar}${C_RESET} ${used_int}%"
  else
    ctx_display="${ctx_bar} ${used_int}%"
  fi
  if [ "$exceeds_200k" = "true" ]; then
    ctx_display="${ctx_display} ${C_RED}!!${C_RESET}"
  fi
else
  ctx_display="▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱ --%"
fi

# --- Cache hit rate ---
cache_pct=$(echo "$input" | jq -r '
  .context_window.current_usage as $u |
  if $u == null then empty
  else
    ($u.cache_read_input_tokens // 0) as $r |
    (($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + $r) as $t |
    if $t > 0 then ($r * 100 / $t | round | tostring) else empty end
  end
')

# --- Cost ---
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

# --- Git branch ---
branch=$(git -C "$(echo "$input" | jq -r '.workspace.current_dir // "."')" \
  --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# --- PR ---
pr_number=$(echo "$input" | jq -r '.pr.number // empty')
pr_state=$(echo "$input" | jq -r '.pr.review_state // empty')

# --- Line 1: [Model (effort)] ctx | cache | $cost | branch(#PR|state) ---
if [ -n "$effort" ]; then
  model_str="${model} (${effort})"
else
  model_str="${model}"
fi

branch_display="$branch"
if [ -n "$branch" ] && [ -n "$pr_number" ]; then
  if [ -n "$pr_state" ]; then
    branch_display="${branch}(#${pr_number}|${pr_state})"
  else
    branch_display="${branch}(#${pr_number})"
  fi
fi

line1="[${model_str}] ${ctx_display}"

if [ -n "$cache_pct" ]; then
  line1="${line1} | cache: ${cache_pct}%"
fi
if [ -n "$cost_usd" ]; then
  cost_str=$(printf '$%.2f' "$cost_usd")
  line1="${line1} | ${cost_str}"
fi
if [ -n "$branch_display" ]; then
  line1="${line1} | ${branch_display}"
fi

# $1 = percentage: レート制限用の色を返す (0-59%: 色なし, 60-74%: 黄, 75-89%: オレンジ, 90%+: 赤)
rate_color() {
  if [ "$1" -ge 90 ]; then printf '%s' "$C_RED"
  elif [ "$1" -ge 75 ]; then printf '%s' "$C_ORANGE"
  elif [ "$1" -ge 60 ]; then printf '%s' "$C_YELLOW"
  fi
}

# --- Line 2: rate limits ---
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

line2=""

if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  five_bar=$(color_bar "$(make_bar "$five_int" 10)" "$(rate_color "$five_int")")
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
  seven_bar=$(color_bar "$(make_bar "$seven_int" 10)" "$(rate_color "$seven_int")")
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
