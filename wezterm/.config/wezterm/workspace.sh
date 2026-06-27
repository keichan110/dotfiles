#!/bin/zsh

readonly fixed_left=130  # 左ペイン（Claude Code）の列数

if [[ -z "$WEZTERM_PANE" ]]; then
  echo "Error: WezTerm の外から実行されています" >&2
  exit 1
fi

pane_info=$(wezterm cli list --format json)

current_tab=$(echo "$pane_info" | jq --argjson id "$WEZTERM_PANE" '.[] | select(.pane_id == $id) | .tab_id')
pane_count=$(echo "$pane_info" | jq --argjson tab "$current_tab" '[.[] | select(.tab_id == $tab)] | length')

if [[ $pane_count -gt 1 ]]; then
  echo "Error: すでにペインが分割されています" >&2
  exit 1
fi

total_cols=$(echo "$pane_info" | jq --argjson id "$WEZTERM_PANE" '.[] | select(.pane_id == $id) | .size.cols')

if [[ $total_cols -ge $(( fixed_left * 2 )) ]]; then
  right_cells=$(( total_cols - fixed_left ))
else
  right_cells=$(( total_cols / 2 ))
fi

wezterm cli set-tab-title --pane-id "$WEZTERM_PANE" "$(basename "$PWD")"

right_pane=$(wezterm cli split-pane --right --cells "$right_cells" --pane-id "$WEZTERM_PANE" --cwd "$PWD")

printf 'nvim .\n' | wezterm cli send-text --pane-id "$right_pane" --no-paste
printf 'claude\n' | wezterm cli send-text --pane-id "$WEZTERM_PANE" --no-paste
wezterm cli activate-pane --pane-id "$WEZTERM_PANE"
