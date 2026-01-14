#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# dotfilesディレクトリを動的に取得
DOTFILES_DIR="$(getDotfilesDir)"

info "linking dotfiles with XDG Base Directory Specification"

# XDG Base Directoryの環境変数を設定
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# XDGディレクトリを作成
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_STATE_HOME"
mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$HOME/.local/bin"

# XDG Config Home のシンボリックリンク作成
info "linking XDG configuration files"

# Zsh configuration
mkdir -p "$XDG_CONFIG_HOME/zsh"

# .zshenv (環境変数設定 - $HOMEに配置してZDOTDIRを設定)
if [[ -f "$DOTFILES_DIR/config/zsh/.zshenv" ]]; then
    ln -fnsv "$DOTFILES_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
fi

# .zshrc (メイン設定ファイル)
if [[ -f "$DOTFILES_DIR/config/zsh/.zshrc" ]]; then
    ln -fnsv "$DOTFILES_DIR/config/zsh/.zshrc" "$XDG_CONFIG_HOME/zsh/.zshrc"
fi

# conf.d (モジュール化された設定ファイル)
if [[ -d "$DOTFILES_DIR/config/zsh/conf.d" ]]; then
    ln -fnsv "$DOTFILES_DIR/config/zsh/conf.d" "$XDG_CONFIG_HOME/zsh/conf.d"
fi

# p10k
if [[ -f "$DOTFILES_DIR/config/zsh/.p10k.zsh" ]]; then
    ln -fnsv "$DOTFILES_DIR/config/zsh/.p10k.zsh" "$XDG_CONFIG_HOME/zsh/.p10k.zsh"
fi

# Git configuration
if [[ -f "$DOTFILES_DIR/config/git/config" ]]; then
    mkdir -p "$XDG_CONFIG_HOME/git"
    ln -fnsv "$DOTFILES_DIR/config/git/config" "$XDG_CONFIG_HOME/git/config"
fi

# Claude configuration (XDG_CONFIG_HOME supported since v1.0.28)
if [[ -d "$DOTFILES_DIR/config/claude" ]]; then
    CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
    mkdir -p "$CLAUDE_CONFIG_DIR"

    # Link non-skills items directly
    for claude_file in "$DOTFILES_DIR/config/claude"/*; do
        [[ -e "$claude_file" ]] || continue
        local_name=$(basename "$claude_file")

        # Skip skills directory (handled separately)
        if [[ "$local_name" == "skills" ]]; then
            continue
        fi

        ln -fnsv "$claude_file" "$CLAUDE_CONFIG_DIR/"
    done

    # Link skills individually (allows coexistence with local skills)
    if [[ -d "$DOTFILES_DIR/config/claude/skills" ]]; then
        mkdir -p "$CLAUDE_CONFIG_DIR/skills"
        for skill_dir in "$DOTFILES_DIR/config/claude/skills"/*; do
            [[ -d "$skill_dir" ]] || continue
            skill_name=$(basename "$skill_dir")
            ln -fnsv "$skill_dir" "$CLAUDE_CONFIG_DIR/skills/"
            info "Linked skill: $skill_name"
        done
    fi
fi

# iTerm2 configuration
if [[ -f "$DOTFILES_DIR/config/iterm2/com.googlecode.iterm2.plist" ]]; then
    mkdir -p "$XDG_CONFIG_HOME/iterm2"
    # 下記を設定した後、iterm上で設定が必要
    ln -fnsv "$DOTFILES_DIR/config/iterm2/com.googlecode.iterm2.plist" "$XDG_CONFIG_HOME/iterm2/com.googlecode.iterm2.plist"
fi

# tmux configuration
if [[ -f "$DOTFILES_DIR/config/tmux/tmux.conf" ]]; then
    mkdir -p "$XDG_CONFIG_HOME/tmux"
    ln -fnsv "$DOTFILES_DIR/config/tmux/tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"
fi

# act configuration
if [[ -f "$DOTFILES_DIR/config/act/actrc" ]]; then
    mkdir -p "$XDG_CONFIG_HOME/act"
    ln -fnsv "$DOTFILES_DIR/config/act/actrc" "$XDG_CONFIG_HOME/act/actrc"
fi

# VSCode configuration (macOS対応)
if [[ -d "$DOTFILES_DIR/config/vscode" ]]; then
    if isRunningOnMac; then
        VSCODE_DIR="$HOME/Library/Application Support/Code/User"
    else
        VSCODE_DIR="$HOME/.vscode"
    fi
    mkdir -p "$VSCODE_DIR"
    for vscode_file in "$DOTFILES_DIR/config/vscode"/*.json; do
        [[ -f "$vscode_file" ]] || continue
        ln -fnsv "$vscode_file" "$VSCODE_DIR/"
    done
fi

if [[ -f "$DOTFILES_DIR/config/wezterm/wezterm.lua" ]]; then
    mkdir -p "$XDG_CONFIG_HOME/wezterm"
    ln -fnsv "$DOTFILES_DIR/config/wezterm/wezterm.lua" "$XDG_CONFIG_HOME/wezterm/wezterm.lua"
fi

# Cursor configuration (macOS対応)
if [[ -f "$DOTFILES_DIR/config/cursor/settings.json" ]]; then
    if isRunningOnMac; then
        CURSOR_DIR="$HOME/Library/Application Support/Cursor/User"
    else
        CURSOR_DIR="$XDG_CONFIG_HOME/Cursor/User"
    fi
    mkdir -p "$CURSOR_DIR"
    ln -fnsv "$DOTFILES_DIR/config/cursor/settings.json" "$CURSOR_DIR/settings.json"
fi

success "XDG configuration files linked"

info "linking XDG data files"

# Brewfiles
if [[ -d "$DOTFILES_DIR/local/share/dotfiles/brewfiles" ]]; then
    mkdir -p "$XDG_DATA_HOME/dotfiles/brewfiles"
    for brewfile in "$DOTFILES_DIR/local/share/dotfiles/brewfiles"/*; do
        if [[ -f "$brewfile" ]]; then
            ln -fnsv "$brewfile" "$XDG_DATA_HOME/dotfiles/brewfiles/"
        fi
    done
fi

# Package files
if [[ -d "$DOTFILES_DIR/local/share/dotfiles/packages" ]]; then
    mkdir -p "$XDG_DATA_HOME/dotfiles/packages"
    for package_file in "$DOTFILES_DIR/local/share/dotfiles/packages"/*; do
        if [[ -f "$package_file" ]]; then
            ln -fnsv "$package_file" "$XDG_DATA_HOME/dotfiles/packages/"
        fi
    done
fi

success "XDG data files linked"

# XDG State Home のシンボリックリンク作成
info "linking XDG state files"

# Backup files
if [[ -d "$DOTFILES_DIR/local/state/dotfiles" ]]; then
    mkdir -p "$XDG_STATE_HOME/dotfiles"
    for state_item in "$DOTFILES_DIR/local/state/dotfiles"/*; do
        if [[ -e "$state_item" ]]; then
            ln -fnsv "$state_item" "$XDG_STATE_HOME/dotfiles/"
        fi
    done
fi

success "XDG state files linked"

# Executable scripts
info "linking executable scripts"

if [[ -d "$DOTFILES_DIR/local/bin" ]]; then
    for script in "$DOTFILES_DIR/local/bin"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            ln -fnsv "$script" "$HOME/.local/bin/"
        fi
    done
fi

success "executable scripts linked"

# テンプレートからローカル設定ファイルを作成（存在しない場合）
info "setting up local configuration files"

# .zshrc.localのセットアップ
if [[ ! -f "$XDG_CONFIG_HOME/zsh/.zshrc.local" ]] && [[ -f "$DOTFILES_DIR/config/zsh/.zshrc.local.template" ]]; then
    cp "$DOTFILES_DIR/config/zsh/.zshrc.local.template" "$XDG_CONFIG_HOME/zsh/.zshrc.local"
    info "Created ~/.config/zsh/.zshrc.local from template"
    warning "Please edit ~/.config/zsh/.zshrc.local to customize your personal settings"
else
    # shellcheck disable=SC2088
    debug "~/.config/zsh/.zshrc.local already exists or template not found"
fi

# .gitconfig.localのセットアップ
if [[ ! -f "$XDG_CONFIG_HOME/git/config.local" ]] && [[ -f "$DOTFILES_DIR/config/git/config.local.template" ]]; then
    cp "$DOTFILES_DIR/config/git/config.local.template" "$XDG_CONFIG_HOME/git/config.local"
    info "Created ~/.config/git/config.local from template"
    warning "Please edit ~/.config/git/config.local with your Git user information"
else
    # shellcheck disable=SC2088
    debug "~/.config/git/config.local already exists or template not found"
fi

success "local configuration setup complete"

# XDG環境変数の設定を確認
info "XDG Base Directory environment variables:"
info "  XDG_CONFIG_HOME: $XDG_CONFIG_HOME"
info "  XDG_DATA_HOME: $XDG_DATA_HOME"
info "  XDG_STATE_HOME: $XDG_STATE_HOME"
info "  XDG_CACHE_HOME: $XDG_CACHE_HOME"

success "XDG-compliant dotfiles linking complete"

# 後続の作業についてのメッセージ
info "Next steps:"
info "1. Restart your shell to apply XDG environment variables"
info "2. Configure applications to use XDG Base Directory Specification"
info "3. All configuration files are now XDG-compliant"

# Brewfile のリンク（macOS想定だがクロスプラットフォームでも無害）
BREWFILES_DIR="$(getDotfilesDir)/local/share/dotfiles/brewfiles"
if [[ -f "$BREWFILES_DIR/.Brewfile" ]]; then
    ln -fnsv "$BREWFILES_DIR/.Brewfile" "$HOME/.Brewfile"
    # shellcheck disable=SC2088
    success "~/.Brewfile symlinked to $BREWFILES_DIR/.Brewfile"
else
    info "Brewfile not found at $BREWFILES_DIR/.Brewfile (will be generated on demand)"
fi
