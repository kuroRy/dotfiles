-- where: config/wezterm/wezterm.lua
-- what: wezterm terminal configuration
-- why: enforce preferred fonts and appearance for consistent UX
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- フォント
-- HackGen 系フォントの実ファミリー名差異に備えてフォールバックを列挙する。
config.font = wezterm.font_with_fallback {
  'HackGenNerd Console',
  'HackGen Console NF',
  'HackGenNerd',
  'JetBrains Mono',
}

-- 背景の非透過率（1なら完全に透過させない）
config.window_background_opacity = 0.80

-- 背景のぼかし
config.macos_window_background_blur = 20

-- タイトルバーの非表示
config.hide_tab_bar_if_only_one_tab = true

-- 最初からフルスクリーンで起動
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():toggle_fullscreen()
end)

-- タブのフォントサイズ

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
config.font_size = 12
config.color_scheme = 'AdventureTime'

-- Finally, return the configuration to wezterm:
return config
