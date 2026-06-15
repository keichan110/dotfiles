#!/bin/bash
# Claude Code のステータスを OSC 1337 user var で WezTerm に直接通知する
# 引数: working | waiting | done | clear
#
# 値フォーマット: base64(STATUS:EPOCH_SEC)
# clear の場合は空文字列をセットして表示をリセットする
set -u

STATUS="${1:-}"

# 引数バリデーション: 既知のステータス以外は何もしない
case "$STATUS" in
  working|waiting|done|clear) ;;
  *) exit 0 ;;
esac

# WezTerm 環境チェック
[ -z "${WEZTERM_PANE:-}" ] && exit 0
command -v wezterm >/dev/null 2>&1 || exit 0
command -v jq      >/dev/null 2>&1 || exit 0

# waiting: Notification hook のstdin JSONでpermission要求のみ通過させる
if [ "$STATUS" = "waiting" ]; then
  msg=$(cat | jq -r '.message // ""' 2>/dev/null)
  case "$msg" in
    *permission*) ;;
    *) exit 0 ;;
  esac
fi

# 値を組み立て
if [ "$STATUS" = "clear" ]; then
  VALUE=""
else
  EPOCH=$(date +%s)
  VALUE=$(printf '%s:%s' "$STATUS" "$EPOCH" | base64 | tr -d '\n')
fi

# 自ペインのttyを解決
# WEZTERM_PANE→tty はセッション中不変なのでキャッシュし、毎回の wezterm cli 起動を避ける
# （PostToolUse は全ツール実行後に発火するため呼び出し頻度が高い）
cache_file="${TMPDIR:-/tmp}/wezterm-tty-${WEZTERM_PANE}"
tty_name=""
[ -r "$cache_file" ] && IFS= read -r tty_name < "$cache_file"

if [ ! -w "$tty_name" ]; then
  tty_name=$(wezterm cli list --format json 2>/dev/null \
    | jq -r --argjson id "$WEZTERM_PANE" \
        '.[] | select(.pane_id == $id) | .tty_name' 2>/dev/null)
  [ -w "$tty_name" ] || exit 0
  printf '%s' "$tty_name" > "$cache_file" 2>/dev/null || true
fi

# OSC 1337 でuser varを直接ttyに書き込む
printf '\033]1337;SetUserVar=claude_state=%s\007' "$VALUE" > "$tty_name"
