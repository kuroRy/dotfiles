-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.
config.font = wezterm.font('HackGenNerd')

-- 背景の非透過率（1なら完全に透過させない）
config.window_background_opacity = 0.80

-- 背景のぼかし
config.macos_window_background_blur = 20

-- タイトルバーの非表示
config.hide_tab_bar_if_only_one_tab = true

-- or, changing the font size and color scheme.
config.font_size = 10
config.color_scheme = 'AdventureTime'

-- Finally, return the configuration to wezterm:
return config