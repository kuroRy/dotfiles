-- where: config/wezterm/wezterm.lua
-- what: wezterm terminal configuration
-- why: enforce preferred fonts and appearance for consistent UX
local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- =============================================================================
-- 基本設定
-- =============================================================================

-- 設定ファイルの変更を自動で読み込む
config.automatically_reload_config = true

-- 設定ファイルが変更されたら通知する
wezterm.on("window-config-reloaded", function(window, _)
  wezterm.toast_notification("wezterm", "configuration reloaded!", nil, 4000)
end)

-- scroll backline
config.scrollback_lines = 1000000

-- IMEを有効にする
config.use_ime = true

-- macSKK向け: Control-jで改行されないようにする設定
---@diagnostic disable-next-line: assign-type-mismatch
config.macos_forward_to_ime_modifier_mask = "SHIFT|CTRL"

-- =============================================================================
-- フォント
-- =============================================================================

-- HackGen 系フォントの実ファミリー名差異に備えてフォールバックを列挙する
config.font = wezterm.font_with_fallback({
  "HackGen Console NF",
  "HackGenNerd",
  "JetBrains Mono",
})
config.font_size = 20

-- =============================================================================
-- 背景
-- =============================================================================

-- 背景の透過度とぼかし
config.window_background_opacity = 0.7
config.macos_window_background_blur = 20

-- =============================================================================
-- ベル設定
-- =============================================================================

config.audible_bell = "SystemBeep"
config.notification_handling = "AlwaysShow"
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 150,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 150,
}

-- =============================================================================
-- キーバインド
-- =============================================================================

config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }

config.keys = {
  -- ¥ではなく、バックスラッシュを入力する
  { key = "¥", action = wezterm.action.SendKey({ key = "\\" }) },
  -- Altを押した場合はバックスラッシュではなく¥を入力する
  { key = "¥", mods = "ALT", action = wezterm.action.SendKey({ key = "¥" }) },

  -- 直前のコマンドと出力をコピー
  {
    key = "z",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.ActivateCopyMode, pane)
      window:perform_action(act.CopyMode({ MoveBackwardZoneOfType = "Input" }), pane)
      window:perform_action(act.CopyMode({ SetSelectionMode = "Cell" }), pane)
      window:perform_action(act.CopyMode({ MoveForwardZoneOfType = "Prompt" }), pane)
      window:perform_action(act.CopyMode("MoveUp"), pane)
      window:perform_action(act.CopyMode("MoveToEndOfLineContent"), pane)
      window:perform_action(
        act.Multiple({
          { CopyTo = "ClipboardAndPrimarySelection" },
          { Multiple = { "ScrollToBottom", { CopyMode = "Close" } } },
        }),
        pane
      )
      window:set_right_status("📋 Copied!")
      wezterm.time.call_after(3, function()
        window:set_right_status("")
      end)
    end),
  },

  -- フルスクリーンモードに切り替える
  { key = "f", mods = "CTRL|CMD", action = wezterm.action.ToggleFullScreen },

  -- タブ操作
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "SHIFT|CTRL", action = act.ActivateTabRelative(-1) },
  { key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = true }) },
  { key = "1", mods = "SUPER", action = act.ActivateTab(0) },
  { key = "2", mods = "SUPER", action = act.ActivateTab(1) },
  { key = "3", mods = "SUPER", action = act.ActivateTab(2) },
  { key = "4", mods = "SUPER", action = act.ActivateTab(3) },
  { key = "5", mods = "SUPER", action = act.ActivateTab(4) },
  { key = "6", mods = "SUPER", action = act.ActivateTab(5) },
  { key = "7", mods = "SUPER", action = act.ActivateTab(6) },
  { key = "8", mods = "SUPER", action = act.ActivateTab(7) },
  { key = "9", mods = "SUPER", action = act.ActivateTab(-1) },

  -- Pane操作
  { key = "r", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "h", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Down") },

  -- ズーム切替（ペインが2つ以上の場合のみ）
  {
    key = "Z",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, pane)
      local tab = pane:tab()
      if #tab:panes() > 1 then
        window:perform_action(act.TogglePaneZoomState, pane)
      end
    end),
  },

  -- フォントサイズ変更
  { key = "+", mods = "SUPER", action = act.IncreaseFontSize },
  { key = "-", mods = "SUPER", action = act.DecreaseFontSize },
  { key = "0", mods = "SUPER", action = act.ResetFontSize },

  -- コピー・ペースト
  { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },

  -- デバッグ・再読み込み
  { key = "l", mods = "SUPER", action = act.ShowDebugOverlay },
  { key = "R", mods = "CTRL", action = act.ReloadConfiguration },

  -- コマンドパレット
  { key = "P", mods = "CTRL", action = act.ActivateCommandPalette },

  -- 文字選択パレット
  {
    key = "U",
    mods = "CTRL",
    action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }),
  },

  -- QuickSelect
  { key = " ", mods = "SUPER", action = act.QuickSelect },

  -- スクロール
  { key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
  { key = "p", mods = "ALT|CTRL", action = act.ScrollByPage(-0.5) },
  { key = "n", mods = "ALT|CTRL", action = act.ScrollByPage(0.5) },

  -- ScrollToPrompt
  { key = "[", mods = "ALT", action = act.ScrollToPrompt(-1) },
  { key = "]", mods = "ALT", action = act.ScrollToPrompt(1) },

  -- 検索モード
  {
    key = "f",
    mods = "SUPER",
    action = act.Multiple({
      act.Search("CurrentSelectionOrEmptyString"),
      act.CopyMode("ClearPattern"),
      act.CopyMode("ClearSelectionMode"),
    }),
  },
  {
    key = "X",
    mods = "CTRL",
    action = act.Multiple({
      act.ActivateCopyMode,
      act.CopyMode("ClearPattern"),
      act.CopyMode("ClearSelectionMode"),
      act.CopyMode("MoveToViewportMiddle"),
    }),
  },

  -- Claude Codeで改行できるようにする
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },

  -- セッティングモード
  { key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "setting_mode", one_shot = false }) },
}

-- =============================================================================
-- キーテーブル
-- =============================================================================

config.key_tables = {
  copy_mode = {
    -- モードの終了
    { key = "c", mods = "CTRL", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
    { key = "q", mods = "NONE", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
    { key = "Escape", mods = "NONE", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },

    -- Vim風のキーバインド
    { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = ",", mods = "NONE", action = act.CopyMode("JumpReverse") },
    { key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
    { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
    { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
    { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
    { key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
    { key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
    { key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
    { key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
    { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
    { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
    { key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
    { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
    { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
    { key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
    { key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
    { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
    { key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    {
      key = "y",
      mods = "NONE",
      action = act.Multiple({
        { CopyTo = "ClipboardAndPrimarySelection" },
      }),
    },

    { key = "p", mods = "ALT|CTRL", action = act.CopyMode("PageUp") },
    { key = "n", mods = "ALT|CTRL", action = act.CopyMode("PageDown") },

    -- 検索結果へジャンプ
    { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
    -- 検索モードへ
    { key = "/", mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
    -- ScrollToPrompt
    { key = "[", mods = "ALT", action = act.ScrollToPrompt(-1) },
    { key = "]", mods = "ALT", action = act.ScrollToPrompt(1) },
    -- セマンティックゾーン移動
    { key = "]", mods = "NONE", action = act.CopyMode({ MoveForwardZoneOfType = "Input" }) },
    { key = "[", mods = "NONE", action = act.CopyMode({ MoveBackwardZoneOfType = "Input" }) },
    -- セマンティックゾーン選択モード
    { key = "z", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "SemanticZone" }) },
  },

  search_mode = {
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    {
      key = "n",
      mods = "CTRL",
      action = act.Multiple({ act.CopyMode("NextMatch"), act.ActivateCopyMode }),
    },
    {
      key = "p",
      mods = "CTRL",
      action = act.Multiple({ act.CopyMode("PriorMatch"), act.ActivateCopyMode }),
    },
    { key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
    { key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
    { key = "X", mods = "CTRL", action = act.ActivateCopyMode },
  },

  setting_mode = {
    -- Paneサイズの調整
    { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
    -- モードから抜ける
    { key = "Escape", action = "PopKeyTable" },
    { key = "q", action = "PopKeyTable" },
    { key = "c", mods = "CTRL", action = "PopKeyTable" },
  },
}

-- =============================================================================
-- モジュール読み込み
-- =============================================================================

require("appearance").apply_to_config(config)
require("tab").apply_to_config(config)
require("statusbar").apply_to_config(config)

return config
