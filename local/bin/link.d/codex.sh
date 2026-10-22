#!/bin/bash
# Codex CLI configuration
#
# AGENTS.md のみをリンクする。config.toml はリンクしない:
#   Codex 自身が config.toml へ [projects."<絶対パス>"] trust_level や
#   通知の既読状態を書き戻すため、リンクすると業務リポジトリのパスが
#   dotfiles (public) に混入する。config.toml は各マシンのローカル管理とし、
#   雛形が必要なら config/codex/config.toml を手で参照する。

[[ -d "$DOTFILES_DIR/config/codex" ]] || return 0

CODEX_DIR="$HOME/.codex"
mkdir -p "$CODEX_DIR"

link_file "$DOTFILES_DIR/config/codex/AGENTS.md" "$CODEX_DIR/AGENTS.md"
