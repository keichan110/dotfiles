#!/bin/bash
# WezTermのタブ色をClaude Codeのステータスに応じて変更する
# 引数: working | waiting | done
#
# OSC/terminalSequence等はすべてClaude Codeが制御しているためPTYに直接書けない。
# WezTermとの通信にはファイルを使い、WezTerm側がio.open()で定期的に読む。
STATUS="$1"
FILE="/tmp/claude-wezterm-status-${WEZTERM_PANE:-0}"

# done（緑）の直後に idle_prompt Notification が上書きするのを防ぐ
if [ "$STATUS" = "waiting" ]; then
  current=$(cat "$FILE" 2>/dev/null || echo "")
  [ "$current" = "done" ] && exit 0
fi

echo "$STATUS" > "$FILE"
