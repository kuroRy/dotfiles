#!/bin/bash
# Ghostty configuration

link_config "ghostty/config"

# macOS: Application Supportの設定ファイルを削除してシンボリックリンクに置き換え
# (Raycast等から起動時にApplication Supportが優先されるため)
if isRunningOnMac; then
    GHOSTTY_APP_SUPPORT="$HOME/Library/Application Support/com.mitchellh.ghostty"
    if [[ -d "$GHOSTTY_APP_SUPPORT" ]]; then
        GHOSTTY_CONFIG="$GHOSTTY_APP_SUPPORT/config"
        # 実ファイル（シンボリックリンクでない）が存在する場合は削除
        if [[ -f "$GHOSTTY_CONFIG" && ! -L "$GHOSTTY_CONFIG" ]]; then
            rm "$GHOSTTY_CONFIG"
            info "Removed existing Ghostty config in Application Support"
        fi
        link_file "$DOTFILES_DIR/config/ghostty/config" "$GHOSTTY_CONFIG"
    fi
fi
