#!/bin/bash
# WezTermのタブ色をClaude Codeのステータスに応じて変更する
# 引数: working | waiting | done
#
# OSC/terminalSequence等はすべてClaude Codeが制御しているためPTYに直接書けない。
# WezTermとの通信にはファイルを使い、WezTerm側がio.open()で定期的に読む。
echo "$1" > "/tmp/claude-wezterm-status-${WEZTERM_PANE:-0}"
