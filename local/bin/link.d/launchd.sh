#!/bin/bash
# launchd のユーザーエージェント (config/launchd/*.plist)
#
# 1. plist を ~/Library/LaunchAgents にコピー (ログイン時の自動読み込みでシンボリックリンクを避けるため)
# 2. 内容が変わったものだけ読み込み直す

isRunningOnMac || return 0
[[ -d "$DOTFILES_DIR/config/launchd" ]] || return 0

LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
mkdir -p "$LAUNCH_AGENTS_DIR"

for plist in "$DOTFILES_DIR/config/launchd"/*.plist; do
    [[ -f "$plist" ]] || continue
    dest="$LAUNCH_AGENTS_DIR/$(basename "$plist")"
    label="$(basename "$plist" .plist)"

    if cmp -s "$plist" "$dest" && launchctl print "gui/$(id -u)/$label" >/dev/null 2>&1; then
        debug "launchd agent up to date: $label"
        continue
    fi

    cp "$plist" "$dest"
    # 未読み込みなら bootout は失敗するので無視する
    launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
    if launchctl bootstrap "gui/$(id -u)" "$dest"; then
        info "launchd agent loaded: $label"
    else
        warning "Failed to load launchd agent: $label"
    fi
done
