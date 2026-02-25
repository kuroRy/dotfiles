local wezterm = require("wezterm")
local module = {}

local appearance = {
  color_scheme = "Solarized Dark Higher Contrast",

  -- タイトルバーを非表示
  window_decorations = "RESIZE",
  window_close_confirmation = "NeverPrompt",

  -- 非アクティブPaneを暗くして視認性を向上
  inactive_pane_hsb = {
    hue = 0.9,
    saturation = 0.9,
    brightness = 1.0,
  },

  -- Tab
  show_tabs_in_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  tab_bar_at_bottom = true,
  show_new_tab_button_in_tab_bar = false,
  tab_max_width = 30,
  use_fancy_tab_bar = true,

  -- fancy tab bar のフォントとタイトルバー背景
  window_frame = {
    font = wezterm.font({ family = "HackGen Console NF", weight = "Bold" }),
    font_size = 16.0,
    active_titlebar_bg = "#1a1a2e",
    inactive_titlebar_bg = "#1a1a2e",
  },

  colors = {
    -- 青みがかった背景色
    background = "#1a1a2e",
    tab_bar = {
      background = "#1a1a2e",
      inactive_tab_edge = "none",
    },
    -- カーソル色
    cursor_bg = "#80EBDF",
    cursor_fg = "#000000",
    cursor_border = "#80EBDF",
    -- 選択色
    selection_bg = "#ffdd00",
    selection_fg = "#000000",
    -- ベル
    visual_bell = "#202020",
  },
}

function module.apply_to_config(config)
  for k, v in pairs(appearance) do
    config[k] = v
  end
end

return module
