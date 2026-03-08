#!/bin/bash
# VSCode configuration (macOS対応)

[[ -d "$DOTFILES_DIR/config/vscode" ]] || return 0

if isRunningOnMac; then
    VSCODE_DIR="$HOME/Library/Application Support/Code/User"
else
    VSCODE_DIR="$HOME/.vscode"
fi
link_dir_contents "$DOTFILES_DIR/config/vscode" "$VSCODE_DIR" "file" "*.json"
