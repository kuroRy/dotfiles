-- where: config/wezterm/wezterm.lua
-- what: wezterm terminal configuration
-- why: enforce preferred fonts and appearance for consistent UX
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()


-- 設定ファイルが変更されたら自動で再読み込みする
config.automatically_reload_config = true

-- 設定ファイルが変更されたら通知する
wezterm.on('window-config-reloaded', function(window, pane)
  wezterm.toast_notification('wezterm', 'configuration reloaded!', nil, 4000)
end)

-- scroll backline
config.scrollback_lines = 1000000

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
leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }

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

  {
    key = "z",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      -- コピーモードに入る
      window:perform_action(act.ActivateCopyMode, pane)

      -- 直前のInputゾーン（最後のコマンド）に移動
      window:perform_action(act.CopyMode({ MoveBackwardZoneOfType = "Input" }), pane)

      -- セル選択モードを開始
      window:perform_action(act.CopyMode({ SetSelectionMode = "Cell" }), pane)

      -- 次のPromptゾーンまで選択（コマンドと出力を含む）
      window:perform_action(act.CopyMode({ MoveForwardZoneOfType = "Prompt" }), pane)

      -- 1行上に移動して行末へ（現在のプロンプト行を除外）
      window:perform_action(act.CopyMode("MoveUp"), pane)
      window:perform_action(act.CopyMode("MoveToEndOfLineContent"), pane)

      -- クリップボードにコピー
      window:perform_action(
        act.Multiple({
          { CopyTo = "ClipboardAndPrimarySelection" },
          { Multiple = { "ScrollToBottom", { CopyMode = "Close" } } },
        }),
        pane
      )

      -- ステータスバーに一時的なステータスを表示
      window:set_right_status("📋 Copied!")
      -- 3秒後にクリア
      wezterm.time.call_after(3, function()
        window:set_right_status("")
      end)
    end),
  },
  -- フルスクリーンモードに切り替える
  {
		key = "f",
		mods = "CTRL|CMD",
		action = wezterm.action.ToggleFullScreen 
	}
}

-- or, changing the font size and color scheme.
config.font_size = 16
config.color_scheme = 'Solarized Darcula'

-- ベル設定
config.audible_bell = "SystemBeep"

-- エスケープシーケンス通知の設定（フォーカス外のペインから通知を受け取る）
config.notification_handling = "AlwaysShow"
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 150,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 150,
}
config.colors = {
  visual_bell = "#202020",
}

-- Claude Codeのタスク完了時にOS通知を送る
wezterm.on('bell', function(window, pane)
  window:toast_notification('Claude Code', 'Task completed', nil, 4000)

  if wezterm.target_triple:find("darwin") then
    wezterm.background_child_process({ "afplay", "/System/Library/Sounds/Submarine.aiff" })
  end
end)

-- Finally, return the configuration to wezterm:
return config
