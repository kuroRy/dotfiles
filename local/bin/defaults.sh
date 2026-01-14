#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

if isRunningOnMac; then
  info "Edit defaults"
else
  info "Skip defaults"
  exit 0
fi

# Dock
## Dockを自動的に非表示
defaults write com.apple.dock autohide -bool true
## Dockのサイズ
defaults write com.apple.dock "tilesize" -int "36"
## 最近起動したアプリを非表示
defaults write com.apple.dock "show-recents" -bool "false"
## アプリをしまうときのアニメーション
defaults write com.apple.dock "mineffect" -string "scale"
## 使用状況に基づいてデスクトップの順番を入れ替え
defaults write com.apple.dock "mru-spaces" -bool "false"
## Dockの表示速度を速くする
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Screenshot
## 画像の影を無効化
defaults write com.apple.screencapture "disable-shadow" -bool "true"
## 保存場所
if [[ ! -d "$HOME/Pictures/Screenshots" ]]; then
    mkdir -p "$HOME/Pictures/Screenshots"
fi
defaults write com.apple.screencapture "location" -string "$HOME/Pictures/Screenshots"
## 撮影時のサムネイル表示
defaults write com.apple.screencapture "show-thumbnail" -bool "false"
## 保存形式
defaults write com.apple.screencapture "type" -string "jpg"

# Finder
## 拡張子まで表示
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
## 隠しファイルを表示
defaults write com.apple.Finder "AppleShowAllFiles" -bool "true"
## パスバーを表示
defaults write com.apple.finder ShowPathbar -bool "true"
## 未確認ファイルを開くときの警告無効化
defaults write com.apple.LaunchServices LSQuarantine -bool "false"
## ゴミ箱を空にするときの警告無効化
defaults write com.apple.finder WarnOnEmptyTrash -bool "false"

# .DS_Store
## .DS_Storeが作成されないようにする
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool "true"

# Feedback
## フィードバックを送信しない
defaults write com.apple.appleseed.FeedbackAssistant "Autogather" -bool "false"
## クラッシュレポート無効化
defaults write com.apple.CrashReporter DialogType -string "none"

## キーのリピートを速くする
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 2

## バッテリー残量を％表示
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

## マウス,トラックパットの速度を速くする
defaults write -g com.apple.mouse.scaling -float 11
defaults write -g com.apple.trackpad.scaling -float 3

## このアプリケーションを開いてもよろしいですか？のダイアログを無効化
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Dockアイコンのスクロールジェスチャーを有効にする
defaults write com.apple.dock scroll-to-open -bool true

# 数字を常に半角にする
defaults write com.apple.inputmethod.Kotoeri JIMPrefFullWidthNumeralCharactersKey -int 0

## 自動で頭文字を大文字にしない
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool "false"
## スペルの訂正を無効にする
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool "false"

for app in "Dock" \
  "Finder" \
  "SystemUIServer"; do
  killall "$app" &> /dev/null || true
done

success "Success to edit defaults"
