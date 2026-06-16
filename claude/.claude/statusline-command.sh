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
C_CYAN=$(printf '\033[36m')
C_BLUE=$(printf '\033[34m')
C_RESET=$(printf '\033[0m')

# モデルランク別の色（Claudeブランドカラー#D97757をOpusに合わせた濃淡、truecolor）
C_MODEL_HAIKU=$(printf '\033[38;2;238;194;179m')
C_MODEL_SONNET=$(printf '\033[38;2;227;153;129m')
C_MODEL_OPUS=$(printf '\033[38;2;217;119;87m')
C_MODEL_FABLE=$(printf '\033[38;2;130;71;52m')

# effortレベル別の色（Claudeブランドカラー#D97757をhighに合わせた濃淡、truecolor）
C_EFFORT_LOW=$(printf '\033[38;2;242;207;196m')
C_EFFORT_MEDIUM=$(printf '\033[38;2;229;163;141m')
C_EFFORT_HIGH=$(printf '\033[38;2;217;119;87m')
C_EFFORT_XHIGH=$(printf '\033[38;2;169;93;68m')
C_EFFORT_MAX=$(printf '\033[38;2;119;65;48m')

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

# $1=actual_pct(int), $2=resets_at(unix ts), $3=window_sec, $4=half_segs, $5=min_elapsed_sec
# Centered pace bar based on projected total usage (actual/elapsed*window)
# Left=under 100%(cool), right=over 100%(warm), │=center(on track to use exactly 100%)
# Threshold-based segments:
#   Right: 100-110 / 110-125 / 125-150 / 150-200 / 200+%
#   Left:  100-90  / 90-75   / 75-50   / 50-25   / 25-0%
pace_bar() {
  actual="$1"
  resets_ts="$2"
  window_sec="$3"
  half="${4:-5}"
  min_elapsed="${5:-0}"

  now=$(date +%s)
  remaining=$(( resets_ts - now ))
  if [ "$remaining" -lt 0 ]; then remaining=0; fi
  if [ "$remaining" -gt "$window_sec" ]; then remaining=$window_sec; fi
  elapsed=$(( window_sec - remaining ))

  # Early window: not enough data yet, show neutral
  if [ "$elapsed" -lt "$min_elapsed" ]; then
    b=""; i=0; while [ "$i" -lt "$half" ]; do b="${b}▱"; i=$(( i + 1 )); done
    printf '%s│%s' "$b" "$b"
    return
  fi

  # Projected total usage if current pace continues
  if [ "$elapsed" -gt 0 ]; then
    projected=$(( actual * window_sec / elapsed ))
  else
    projected=100
  fi

  # Threshold-based segment count (neutral zone: projected 95-105%)
  # Right: 105-120 / 120-133 / 133-150 / 150-175 / 175-225 / 225-300 / 300+%
  # Left:  95-80   / 80-68   / 68-55   / 55-40   / 40-25   / 25-10   / 10-0%
  left_filled=0
  right_filled=0
  if [ "$projected" -ge 105 ]; then
    if   [ "$projected" -ge 300 ]; then right_filled=7
    elif [ "$projected" -ge 225 ]; then right_filled=6
    elif [ "$projected" -ge 175 ]; then right_filled=5
    elif [ "$projected" -ge 150 ]; then right_filled=4
    elif [ "$projected" -ge 133 ]; then right_filled=3
    elif [ "$projected" -ge 120 ]; then right_filled=2
    else                                 right_filled=1
    fi
  elif [ "$projected" -le 95 ]; then
    if   [ "$projected" -le 10 ]; then left_filled=7
    elif [ "$projected" -le 25 ]; then left_filled=6
    elif [ "$projected" -le 40 ]; then left_filled=5
    elif [ "$projected" -le 55 ]; then left_filled=4
    elif [ "$projected" -le 68 ]; then left_filled=3
    elif [ "$projected" -le 80 ]; then left_filled=2
    else                               left_filled=1
    fi
  fi

  # Determine single color for all filled segments (1 seg = no color, 2+ = colored)
  if [ "$right_filled" -gt 0 ]; then
    if   [ "$right_filled" -ge 6 ]; then clr="$C_RED"
    elif [ "$right_filled" -ge 4 ]; then clr="$C_ORANGE"
    elif [ "$right_filled" -ge 2 ]; then clr="$C_YELLOW"
    else                                  clr=""
    fi
  elif [ "$left_filled" -gt 0 ]; then
    if   [ "$left_filled" -ge 6 ]; then clr="$C_BLUE"
    elif [ "$left_filled" -ge 4 ]; then clr="$C_CYAN"
    elif [ "$left_filled" -ge 2 ]; then clr="$C_GREEN"
    else                                 clr=""
    fi
  else
    clr=""
  fi

  # Build left side: filled at right end (closest to center)
  left=""
  i=0
  while [ "$i" -lt "$half" ]; do
    if [ "$i" -ge $(( half - left_filled )) ]; then
      left="${left}${clr}▰${C_RESET}"
    else
      left="${left}▱"
    fi
    i=$(( i + 1 ))
  done

  # Build right side: filled at left end (closest to center)
  right=""
  i=0
  while [ "$i" -lt "$half" ]; do
    if [ "$i" -lt "$right_filled" ]; then
      right="${right}${clr}▰${C_RESET}"
    else
      right="${right}▱"
    fi
    i=$(( i + 1 ))
  done

  printf '%s│%s' "$left" "$right"
}

# $1 = bar string, $2 = color string
color_bar() {
  if [ -n "$2" ]; then
    printf '%s' "${2}${1}${C_RESET}"
  else
    printf '%s' "$1"
  fi
}

# $1 = model display name: モデルランクに応じた色を返す（該当なしは無色）
model_color() {
  case "$1" in
    *Fable*) printf '%s' "$C_MODEL_FABLE" ;;
    *Opus*) printf '%s' "$C_MODEL_OPUS" ;;
    *Sonnet*) printf '%s' "$C_MODEL_SONNET" ;;
    *Haiku*) printf '%s' "$C_MODEL_HAIKU" ;;
  esac
}

# $1 = effort level: effortランクに応じた色を返す（該当なしは無色）
effort_color() {
  case "$1" in
    max) printf '%s' "$C_EFFORT_MAX" ;;
    xhigh) printf '%s' "$C_EFFORT_XHIGH" ;;
    high) printf '%s' "$C_EFFORT_HIGH" ;;
    medium) printf '%s' "$C_EFFORT_MEDIUM" ;;
    low) printf '%s' "$C_EFFORT_LOW" ;;
  esac
}

# $1 = percentage: キャッシュヒット率用の色を返す (0-64%: 色なし, 65-84%: 緑, 85-94%: シアン, 95%+: 青)
cache_color() {
  if [ "$1" -ge 95 ]; then printf '%s' "$C_BLUE"
  elif [ "$1" -ge 85 ]; then printf '%s' "$C_CYAN"
  elif [ "$1" -ge 65 ]; then printf '%s' "$C_GREEN"
  fi
}

# --- Context window ---
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  ctx_bar=$(make_bar "$used_int" 20)
  if [ "$used_int" -ge 85 ]; then
    bar_color="$C_RED"
  elif [ "$used_int" -ge 70 ]; then
    bar_color="$C_ORANGE"
  elif [ "$used_int" -ge 50 ]; then
    bar_color="$C_YELLOW"
  else
    bar_color=""
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
model_clr=$(model_color "$model")
if [ -n "$model_clr" ]; then
  model_display="${model_clr}${model}${C_RESET}"
else
  model_display="${model}"
fi
if [ -n "$effort" ]; then
  effort_clr=$(effort_color "$effort")
  if [ -n "$effort_clr" ]; then
    effort_display="${effort_clr}${effort}${C_RESET}"
  else
    effort_display="${effort}"
  fi
  model_str="${model_display} (${effort_display})"
else
  model_str="${model_display}"
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
  cache_clr=$(cache_color "$cache_pct")
  cache_pct_str="${cache_clr:+${cache_clr}}${cache_pct}%${cache_clr:+${C_RESET}}"
  line1="${line1} | cache: ${cache_pct_str}"
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
  five_clr=$(rate_color "$five_int")
  five_pct_str="${five_clr:+${five_clr}}${five_int}%${five_clr:+${C_RESET}}"
  if [ -n "$five_reset" ]; then
    five_bar=$(pace_bar "$five_int" "$five_reset" 18000 7 600)
    five_time=$(date -r "$five_reset" "+%H:%M" 2>/dev/null || date -d "@${five_reset}" "+%H:%M" 2>/dev/null || echo "")
    five_str="5h: ${five_bar} ${five_pct_str} (~${five_time})"
  else
    five_bar=$(color_bar "$(make_bar "$five_int" 10)" "$(rate_color "$five_int")")
    five_str="5h: ${five_bar} ${five_pct_str}"
  fi
  line2="${five_str}"
fi

if [ -n "$seven_pct" ]; then
  seven_int=$(printf '%.0f' "$seven_pct")
  seven_clr=$(rate_color "$seven_int")
  seven_pct_str="${seven_clr:+${seven_clr}}${seven_int}%${seven_clr:+${C_RESET}}"
  if [ -n "$seven_reset" ]; then
    seven_bar=$(pace_bar "$seven_int" "$seven_reset" 604800 7 3600)
    seven_time=$(date -r "$seven_reset" "+%-m/%-d %H:%M" 2>/dev/null || date -d "@${seven_reset}" "+%-m/%-d %H:%M" 2>/dev/null || echo "")
    seven_str="7d: ${seven_bar} ${seven_pct_str} (~${seven_time})"
  else
    seven_bar=$(color_bar "$(make_bar "$seven_int" 10)" "$(rate_color "$seven_int")")
    seven_str="7d: ${seven_bar} ${seven_pct_str}"
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
