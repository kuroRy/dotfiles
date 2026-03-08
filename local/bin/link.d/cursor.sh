#!/bin/bash
# Cursor configuration (macOS対応)

[[ -f "$DOTFILES_DIR/config/cursor/settings.json" ]] || return 0

if isRunningOnMac; then
    CURSOR_DIR="$HOME/Library/Application Support/Cursor/User"
else
    CURSOR_DIR="$XDG_CONFIG_HOME/Cursor/User"
fi
link_file "$DOTFILES_DIR/config/cursor/settings.json" "$CURSOR_DIR/settings.json"
