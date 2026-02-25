local wezterm = require("wezterm")
local module = {}

-- =============================================================================
-- 定数
-- =============================================================================

local WORKSPACE_COLORS = {
  default = "#80EBDF",
  copy_mode = "#ffd700",
  setting_mode = "#39FF14",
}

local LEADER_COLOR = "#ff79c6"

-- Leader キー押下時に表示するヒント
local LEADER_HINTS = {
  { key = "z", desc = "copy last cmd" },
  { key = "r", desc = "split horiz" },
  { key = "d", desc = "split vert" },
  { key = "x", desc = "close pane" },
  { key = "s", desc = "setting mode" },
}

-- セッティングモード時に表示するヒント
local SETTING_HINTS = {
  { key = "h/j/k/l", desc = "resize pane" },
  { key = "q/Esc", desc = "exit" },
}

-- 前回の色を記録（不要な更新を避けるため）
local last_color = nil

-- =============================================================================
-- ヘルパー関数
-- =============================================================================

local function build_hint_elements(hints, key_color, sep_color, desc_color)
  local elements = {}
  for i, hint in ipairs(hints) do
    if i > 1 then
      table.insert(elements, { Foreground = { Color = sep_color } })
      table.insert(elements, { Text = "  " })
    end
    table.insert(elements, { Foreground = { Color = key_color } })
    table.insert(elements, { Attribute = { Intensity = "Bold" } })
    table.insert(elements, { Text = hint.key })
    table.insert(elements, { Attribute = { Intensity = "Normal" } })
    table.insert(elements, { Foreground = { Color = desc_color } })
    table.insert(elements, { Text = " " .. hint.desc })
  end
  return elements
end

-- =============================================================================
-- メイン処理
-- =============================================================================

function module.apply_to_config(_)
  wezterm.on("update-status", function(window, pane)
    local workspace = window:active_workspace()
    local key_table = window:active_key_table()
    local is_leader = window:leader_is_active()

    -- 左ステータス: ワークスペース名 + モード表示
    local left_color
    local mode_label = ""
    if is_leader then
      left_color = LEADER_COLOR
      mode_label = "  LEADER"
    elseif key_table == "setting_mode" then
      left_color = WORKSPACE_COLORS.setting_mode
      mode_label = "  SETTING"
    elseif key_table == "copy_mode" then
      left_color = WORKSPACE_COLORS.copy_mode
      mode_label = "  COPY"
    else
      left_color = WORKSPACE_COLORS.default
    end

    window:set_left_status(wezterm.format({
      { Background = { Color = "transparent" } },
      { Foreground = { Color = left_color } },
      { Text = "  " .. workspace .. mode_label .. "  " },
    }))

    -- 右ステータス: キーバインドヒント
    if is_leader then
      local elements = { { Background = { Color = "transparent" } } }
      local hint_elements = build_hint_elements(LEADER_HINTS, LEADER_COLOR, "#585858", "#a0a9cb")
      for _, el in ipairs(hint_elements) do
        table.insert(elements, el)
      end
      table.insert(elements, { Text = "  " })
      window:set_right_status(wezterm.format(elements))
    elseif key_table == "setting_mode" then
      local elements = { { Background = { Color = "transparent" } } }
      local hint_elements = build_hint_elements(SETTING_HINTS, WORKSPACE_COLORS.setting_mode, "#585858", "#a0a9cb")
      for _, el in ipairs(hint_elements) do
        table.insert(elements, el)
      end
      table.insert(elements, { Text = "  " })
      window:set_right_status(wezterm.format(elements))
    else
      window:set_right_status("")
    end

    -- カーソル色変更（OSCエスケープシーケンスを使用）
    local cursor_color = WORKSPACE_COLORS[key_table] or WORKSPACE_COLORS.default
    if is_leader then
      cursor_color = LEADER_COLOR
    end
    if last_color ~= cursor_color then
      last_color = cursor_color
      pane:inject_output("\x1b]12;" .. cursor_color .. "\x1b\\")
    end
  end)
end

return module
