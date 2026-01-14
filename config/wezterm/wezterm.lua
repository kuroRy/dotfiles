-- where: config/wezterm/wezterm.lua
-- what: wezterm terminal configuration
-- why: enforce preferred fonts and appearance for consistent UX
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()


-- 設定ファイルが変更されたら自動で再読み込みする
config.automatically_reload_config = true

-- scroll backline
config.scrollback_lines = 3500

-- IMEを有効にする
config.use_ime = true

-- フォント
-- HackGen 系フォントの実ファミリー名差異に備えてフォールバックを列挙する。
config.font = wezterm.font_with_fallback {
  'HackGen Console NF',
  'HackGenNerd',
  'JetBrains Mono',
}

-- 背景の非透過率（1なら完全に透過させない）
config.window_background_opacity = 0.75

-- タイトルバーの削除
config.window_decorations = "RESIZE"

-- タブバーを背景と同じ色にする
config.window_background_gradient = {
  colors = { "#000000" },
}

-- アクティブタブに色をつける
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"

  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end

  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
  }
end)

-- 背景のぼかし
config.macos_window_background_blur = 20

-- タイトルバーの非表示
config.hide_tab_bar_if_only_one_tab = true

-- キーバインド
config.keys = {
  -- ¥ではなく、バックスラッシュを入力する。
  {
      key = "¥",
      action = wezterm.action.SendKey { key = '\\' }
  },
  -- Altを押した場合はバックスラッシュではなく¥を入力する。
  {
      key = "¥",
      mods = "ALT",
      action = wezterm.action.SendKey { key = '¥' }
  },
}

-- or, changing the font size and color scheme.
config.font_size = 14
config.color_scheme = 'AdventureTime'

-- Finally, return the configuration to wezterm:
return config
