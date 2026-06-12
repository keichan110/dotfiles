local wezterm = require 'wezterm'
local keybind = require 'keybindings'
local mux = wezterm.mux
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.automatically_reload_config = true

-- Nord カラーパレット（共通定数）
local C = {
  bg          = '#2E3440', -- Nord 0
  bg_light    = '#3B4252', -- Nord 1
  bg_lighter  = '#434C5E', -- Nord 2
  border      = '#4C566A', -- Nord 3
  fg_dim      = '#D8DEE9', -- Nord 4
  fg          = '#D8DEE0', -- Nord 6 (近似)
  status_line = '#616E88', -- Nord 3.5
  active_tab  = '#81A1C1', -- Nord 9
  claude_work = '#5E81AC', -- Nord 10
  claude_done = '#A3BE8C', -- Nord 14
  claude_wait = '#EBCB8B', -- Nord 13
}

-- Color
config.color_scheme = 'nord'
config.window_background_gradient = {
  orientation = 'Vertical',
  colors = {
    C.bg_lighter,
    C.bg_light,
    C.bg,
    C.bg,
  },
}
config.colors = {
  tab_bar = {
    background = C.bg,
    active_tab = {
      bg_color  = C.active_tab,
      fg_color  = C.fg,
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color  = C.bg,
      fg_color  = C.fg_dim,
      intensity = 'Normal',
    },
    inactive_tab_hover = {
      bg_color  = '#3B4245',
      fg_color  = C.fg,
      intensity = 'Normal',
    },
    new_tab = {
      bg_color = C.bg,
      fg_color = C.fg,
    },
    new_tab_hover = {
      bg_color = '#3B4245',
      fg_color = C.fg,
    },
  },
  cursor_bg = C.fg_dim,
  split     = C.border,
}

-- Tabbar
config.use_fancy_tab_bar       = false
config.tab_max_width            = 100
config.tab_bar_at_bottom        = true
config.window_decorations       = 'RESIZE'

-- Font
config.font = wezterm.font_with_fallback {
  { family = 'PlemolJP Console', weight = 'Regular', style = 'Normal' },
  { family = 'HackGen Console',  weight = 'Regular', style = 'Normal' },
  { family = 'Cica',             weight = 'Regular', style = 'Normal' },
  { family = 'JetBrains Mono',   weight = 'Regular', style = 'Normal' },
}
config.font_size = 15

-- Cursor
config.default_cursor_style = 'BlinkingBlock'

-- Window
config.window_padding = {
  left   = 10,
  right  = 10,
  top    = 10,
  bottom = 20,
}
config.window_close_confirmation = 'NeverPrompt'

-- Pane
config.inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.4,
}

-- Keybindings
config.disable_default_key_bindings = true
config.keys        = keybind.keys
config.key_tables  = keybind.key_tables


-- Functions
-- 起動時に最大化
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

-- 透明・不透明の切り替え
wezterm.on('toggle-opacity', function(window)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 1.0
  end
  if overrides.window_background_opacity >= 1.0 then
    overrides.window_background_opacity = 0.6
  else
    overrides.window_background_opacity = 1.0
  end
  window:set_config_overrides(overrides)
end)

-- Claude Code のステータスに応じてタブ背景色を変更する
-- Claude Code hooks が OSC 1337 user var で通知し、user-var-changed イベントで受け取る

local CLAUDE_STATUS_COLORS = {
  working = C.claude_work,
  waiting = C.claude_wait,
  done    = C.claude_done,
}
local TAB_WIDTH = 24

-- ペインIDごとの状態 { status = "working"|"waiting"|"done", epoch = number }
local claude_states = {}

-- user-var-changed: OSC 1337 SetUserVar=claude_state=... を受け取る
wezterm.on('user-var-changed', function(window, pane, name, value)
  if name ~= 'claude_state' then return end
  local pane_id = pane:pane_id()
  if value == '' then
    claude_states[pane_id] = nil
  else
    local ok, decoded = pcall(wezterm.base64_decode, value)
    if ok and decoded then
      local status, epoch = decoded:match('^(.+):(%d+)$')
      if status then
        claude_states[pane_id] = { status = status, epoch = tonumber(epoch) }
      end
    end
  end
end)

-- update-status は毎秒発火し、format-tab-title の再評価をトリガーする
wezterm.on('update-status', function(window, pane)
  window:set_right_status(wezterm.format({
    { Foreground = { Color = C.status_line } },
    { Text = wezterm.strftime(' %H:%M:%S ') },
  }))
end)

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local pane_id = tab.active_pane.pane_id
  local state = claude_states[pane_id]
  local status = state and state.status

  -- フォーカスが戻ったタブの完了・待機状態をクリアしてデフォルト色に戻す
  if status and (status == 'done' or status == 'waiting') and tab.is_active then
    claude_states[pane_id] = nil
    status = nil
  end

  local title = tab.tab_title
  if not title or title == '' then
    title = tab.active_pane.title
  end

  -- タブ番号を付けて固定幅にトリム＆パディング
  title = (tab.tab_index + 1) .. ': ' .. title
  title = wezterm.truncate_right(title, TAB_WIDTH - 2)
  local padded = wezterm.pad_right(' ' .. title, TAB_WIDTH)

  local bg, fg, intensity
  if status and CLAUDE_STATUS_COLORS[status] then
    bg        = CLAUDE_STATUS_COLORS[status]
    fg        = C.bg
    intensity = tab.is_active and 'Bold' or 'Normal'
  elseif tab.is_active then
    bg        = C.active_tab
    fg        = C.fg
    intensity = 'Bold'
  else
    bg        = C.bg
    fg        = C.fg_dim
    intensity = 'Normal'
  end

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute  = { Intensity = intensity } },
    { Text       = padded },
    { Background = { Color = C.bg } },
    { Foreground = { Color = C.border } },
    { Text       = '│' },
  }
end)

return config
