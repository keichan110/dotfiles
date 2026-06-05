local wezterm = require 'wezterm'
local keybind = require 'keybindings'
local mux = wezterm.mux
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.automatically_reload_config = true

-- Color
config.color_scheme = 'nord'
config.window_background_gradient = {
  orientation = 'Vertical',
  colors = {
    -- '#4C566A',
    '#434C5E',
    '#3B4253',
    '#2E3440',
    '#2E3440',
  },
}
config.colors = {
  tab_bar = {
    background = '#2E3440',
    active_tab = {
      bg_color = '#81A1C1',
      fg_color = '#D8DEE0',
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = '#2E3440',
      fg_color = '#D8DEE9',
      intensity = "Normal",
    },
    inactive_tab_hover = {
      bg_color = '#3B4245',
      fg_color = '#D8DEE0',
      intensity = 'Normal',
    },
    new_tab = {
      bg_color = '#2E3440',
      fg_color = '#D8DEE0',
    },
    new_tab_hover = {
      bg_color = '#3B4245',
      fg_color = '#D8DEE0',
    }
  },
  cursor_bg = '#D8DEE9',
  split = '#4C566A',
}

-- Tabbar
config.use_fancy_tab_bar = false
config.tab_max_width = 100
config.tab_bar_at_bottom = true
config.window_decorations = "RESIZE"

-- Font
config.font = wezterm.font_with_fallback {
  { family = 'PlemolJP Console', weight = 'Regular', style = 'Normal' },
  { family = 'HackGen Console', weight = 'Regular', style = 'Normal' },
  { family = 'Cica', weight = 'Regular', style='Normal' },
  { family = 'JetBrains Mono', weight = 'Regular', style = 'Normal' }
}
config.font_size = 15

-- Cursor
config.default_cursor_style = 'BlinkingBlock'

-- Window
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
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
config.keys = keybind.keys
config.key_tables = keybind.key_tables


-- Functions
-- 起動時に最大で起動する
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  -- window:gui_window():toggle_fullscreen()
    window:gui_window():maximize()
end)

-- 透明-不透明の切り替え
wezterm.on("toggle-opacity", function(window)
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
-- Claude Code hooks がファイルにステータスを書き、WezTerm が io.open() で読む

local CLAUDE_STATUS_DIR = '/tmp/claude-wezterm-status-'

local CLAUDE_STATUS_COLORS = {
  working = '#5E81AC', -- Nord blue
  waiting = '#EBCB8B', -- Nord yellow
  done    = '#A3BE8C', -- Nord green
}

local function read_claude_status(pane_id)
  local f = io.open(CLAUDE_STATUS_DIR .. pane_id, 'r')
  if not f then return nil end
  local s = f:read('*l')
  f:close()
  return (s and s ~= '') and s or nil
end

local function clear_claude_status(pane_id)
  local f = io.open(CLAUDE_STATUS_DIR .. pane_id, 'w')
  if f then f:close() end
end

-- update-status は毎秒発火し、set_right_status が format-tab-title の再評価をトリガーする
wezterm.on('update-status', function(window, pane)
  window:set_right_status(wezterm.format({
    { Foreground = { Color = '#616E88' } },
    { Text = wezterm.strftime(' %H:%M:%S ') },
  }))
end)

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local pane_id = tab.active_pane.pane_id
  local status = read_claude_status(pane_id)

  if not status then return nil end

  -- フォーカスが戻ったタブの完了状態をクリアしてデフォルト色に戻す
  if status == 'done' and tab.is_active then
    clear_claude_status(pane_id)
    return nil
  end

  local bg = CLAUDE_STATUS_COLORS[status]
  if not bg then return nil end

  local title = tab.tab_title
  if not title or title == '' then
    title = tab.active_pane.title
  end

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = '#2E3440' } },
    { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
    { Text = ' ' .. title .. ' ' },
  }
end)

return config