#!/bin/bash
# Claude Code のステータスを OSC 1337 user var で WezTerm に直接通知する
# 引数: working | waiting | done | clear
#
# 値フォーマット: base64(STATUS:EPOCH_SEC)
# clear の場合は空文字列をセットして表示をリセットする
STATUS="$1"

# WezTerm 環境チェック
[ -z "${WEZTERM_PANE:-}" ] && exit 0
command -v wezterm >/dev/null 2>&1 || exit 0
command -v jq      >/dev/null 2>&1 || exit 0

# waiting: Notification hook のstdin JSONでpermission要求のみ通過させる
if [ "$STATUS" = "waiting" ]; then
  msg=$(cat | jq -r '.message // ""' 2>/dev/null)
  echo "$msg" | grep -qiE "permission|allow|proceed|approve" || exit 0
fi

# 値を組み立て
if [ "$STATUS" = "clear" ]; then
  VALUE=""
else
  EPOCH=$(date +%s)
  VALUE=$(printf '%s:%s' "$STATUS" "$EPOCH" | base64 | tr -d '\n')
fi

# 自ペインのttyを解決
TTY=$(wezterm cli list --format json 2>/dev/null \
  | jq -r --argjson id "$WEZTERM_PANE" \
      '.[] | select(.pane_id == $id) | .tty_name' 2>/dev/null)
[ -z "$TTY" ] && exit 0

# OSC 1337 でuser varを直接ttyに書き込む
printf '\033]1337;SetUserVar=claude_state=%s\a' "$VALUE" > "$TTY"
