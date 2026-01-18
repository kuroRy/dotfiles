#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# ヘルパー関数
# =============================================================================

# 単一ファイル/ディレクトリのシンボリックリンクを作成
# Usage: link_file <source> <destination>
link_file() {
    local src="$1"
    local dest="$2"

    [[ -e "$src" ]] || return 0
    mkdir -p "$(dirname "$dest")"
    ln -fnsv "$src" "$dest"
}

# XDG_CONFIG_HOME への設定ファイルリンク（便利関数）
# Usage: link_config <relative_path> [dest_relative_path]
# Example: link_config "git/config"
#          link_config "git/config" "git/config"
link_config() {
    local relative_path="$1"
    local dest_path="${2:-$relative_path}"
    local src="${DOTFILES_DIR}/config/${relative_path}"
    local dest="${XDG_CONFIG_HOME}/${dest_path}"

    link_file "$src" "$dest"
}

# ディレクトリ内のファイル/ディレクトリをリンク
# Usage: link_dir_contents <src_dir> <dest_dir> [filter] [pattern]
# filter: file (default), dir, all, exec
# pattern: glob pattern (default: *)
link_dir_contents() {
    local src_dir="$1"
    local dest_dir="$2"
    local filter="${3:-file}"
    local pattern="${4:-*}"

    [[ -d "$src_dir" ]] || return 0
    mkdir -p "$dest_dir"

    for item in "$src_dir"/$pattern; do
        [[ -e "$item" ]] || continue
        case "$filter" in
            file) [[ -f "$item" ]] || continue ;;
            dir)  [[ -d "$item" ]] || continue ;;
            exec) [[ -f "$item" && -x "$item" ]] || continue ;;
            all)  ;;  # no filter
        esac
        ln -fnsv "$item" "$dest_dir/"
    done
}

# テンプレートからローカル設定ファイルを作成（存在しない場合のみ）
# Usage: setup_from_template <template> <target> <display_path>
setup_from_template() {
    local template="$1"
    local target="$2"
    local display_path="$3"

    [[ -f "$template" ]] || return 0
    if [[ -f "$target" ]]; then
        debug "$display_path already exists"
        return 0
    fi

    mkdir -p "$(dirname "$target")"
    cp "$template" "$target"
    info "Created $display_path from template"
    warning "Please edit $display_path to customize your personal settings"
}

# =============================================================================
# メイン処理
# =============================================================================

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

# =============================================================================
# XDG Config Home のシンボリックリンク作成
# =============================================================================
info "linking XDG configuration files"

# Zsh configuration
link_file "$DOTFILES_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
link_config "zsh/.zshrc"
link_config "zsh/.zimrc"
link_config "zsh/conf.d"

# Starship prompt configuration
link_config "starship/starship.toml" "starship.toml"

# Git configuration
link_config "git/config"
link_config "git/ignore"

# Claude configuration (XDG_CONFIG_HOME supported since v1.0.28)
if [[ -d "$DOTFILES_DIR/config/claude" ]]; then
    CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
    mkdir -p "$CLAUDE_CONFIG_DIR"

    # Directories to link individually (allows coexistence with Claude-generated files)
    individual_link_dirs=("skills" "scripts")

    # Link non-individual items directly
    for claude_file in "$DOTFILES_DIR/config/claude"/*; do
        [[ -e "$claude_file" ]] || continue
        local_name=$(basename "$claude_file")

        # Skip directories that need individual linking
        for skip_dir in "${individual_link_dirs[@]}"; do
            if [[ "$local_name" == "$skip_dir" ]]; then
                continue 2
            fi
        done

        ln -fnsv "$claude_file" "$CLAUDE_CONFIG_DIR/"
    done

    # Link contents of individual directories
    for dir_name in "${individual_link_dirs[@]}"; do
        src_dir="$DOTFILES_DIR/config/claude/$dir_name"
        dest_dir="$CLAUDE_CONFIG_DIR/$dir_name"

        [[ -d "$src_dir" ]] || continue
        mkdir -p "$dest_dir"

        for item in "$src_dir"/*; do
            [[ -e "$item" ]] || continue
            ln -fnsv "$item" "$dest_dir/"
            info "Linked $dir_name: $(basename "$item")"
        done
    done

    # mcp.json: ホームディレクトリにもリンク（後方互換性）
    if [[ -f "$DOTFILES_DIR/config/claude/mcp.json" ]]; then
        ln -fnsv "$DOTFILES_DIR/config/claude/mcp.json" "$HOME/.mcp.json"
        info "Linked mcp.json to ~/.mcp.json for backward compatibility"
    fi
fi

# iTerm2 configuration
link_config "iterm2/com.googlecode.iterm2.plist"

# tmux configuration
link_config "tmux/tmux.conf"

# act configuration
link_config "act/actrc"

# VSCode configuration (macOS対応)
if [[ -d "$DOTFILES_DIR/config/vscode" ]]; then
    if isRunningOnMac; then
        VSCODE_DIR="$HOME/Library/Application Support/Code/User"
    else
        VSCODE_DIR="$HOME/.vscode"
    fi
    link_dir_contents "$DOTFILES_DIR/config/vscode" "$VSCODE_DIR" "file" "*.json"
fi

# wezterm configuration
link_config "wezterm/wezterm.lua"

# Cursor configuration (macOS対応)
if [[ -f "$DOTFILES_DIR/config/cursor/settings.json" ]]; then
    if isRunningOnMac; then
        CURSOR_DIR="$HOME/Library/Application Support/Cursor/User"
    else
        CURSOR_DIR="$XDG_CONFIG_HOME/Cursor/User"
    fi
    link_file "$DOTFILES_DIR/config/cursor/settings.json" "$CURSOR_DIR/settings.json"
fi

success "XDG configuration files linked"

# =============================================================================
# XDG Data Home のシンボリックリンク作成
# =============================================================================
info "linking XDG data files"

# Brewfiles
link_dir_contents "$DOTFILES_DIR/local/share/dotfiles/brewfiles" "$XDG_DATA_HOME/dotfiles/brewfiles" "file"

# Package files
link_dir_contents "$DOTFILES_DIR/local/share/dotfiles/packages" "$XDG_DATA_HOME/dotfiles/packages" "file"

success "XDG data files linked"

# =============================================================================
# XDG State Home のシンボリックリンク作成
# =============================================================================
info "linking XDG state files"

# Backup files
link_dir_contents "$DOTFILES_DIR/local/state/dotfiles" "$XDG_STATE_HOME/dotfiles" "all"

success "XDG state files linked"

# =============================================================================
# Executable scripts
# =============================================================================
info "linking executable scripts"

link_dir_contents "$DOTFILES_DIR/local/bin" "$HOME/.local/bin" "exec"

success "executable scripts linked"

# =============================================================================
# テンプレートからローカル設定ファイルを作成
# =============================================================================
info "setting up local configuration files"

# shellcheck disable=SC2088
setup_from_template \
    "$DOTFILES_DIR/config/zsh/.zshrc.local.template" \
    "$XDG_CONFIG_HOME/zsh/.zshrc.local" \
    "~/.config/zsh/.zshrc.local"

# shellcheck disable=SC2088
setup_from_template \
    "$DOTFILES_DIR/config/git/config.local.template" \
    "$XDG_CONFIG_HOME/git/config.local" \
    "~/.config/git/config.local"

success "local configuration setup complete"

# =============================================================================
# 環境変数の確認と完了メッセージ
# =============================================================================
info "XDG Base Directory environment variables:"
info "  XDG_CONFIG_HOME: $XDG_CONFIG_HOME"
info "  XDG_DATA_HOME: $XDG_DATA_HOME"
info "  XDG_STATE_HOME: $XDG_STATE_HOME"
info "  XDG_CACHE_HOME: $XDG_CACHE_HOME"

success "XDG-compliant dotfiles linking complete"

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
