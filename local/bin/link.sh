#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
setupErrorHandler "link.sh"

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

# XDG_CONFIG_HOME への設定ファイルリンク
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

# dotfiles を指すリンク切れを掃除する
# Usage: prune_stale_links <dir>
# dotfiles から削除・リネームされた項目の取り残しだけを消す。
# 実ファイル・実ディレクトリと、dotfiles 外を指すリンクには触れない。
# 隠し項目も対象にする (.p10k.zsh のような取り残しがあるため)。
# 掃除は補助処理なので、失敗しても本処理を止めない。
prune_stale_links() {
    local dir="$1"
    local link target

    [[ -d "$dir" ]] || return 0

    for link in "$dir"/* "$dir"/.[!.]*; do
        [[ -L "$link" && ! -e "$link" ]] || continue
        target=$(readlink "$link")
        [[ "$target" == "$DOTFILES_DIR"/* ]] || continue
        if rm -f "$link"; then
            info "Removed broken symlink: $link"
        else
            warning "Failed to remove broken symlink: $link"
        fi
    done
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
    prune_stale_links "$dest_dir"

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

# 実ディレクトリが存在する場合に確認プロンプトを表示してリンクを作成
# Usage: link_with_dir_prompt <source> <destination>
# Returns: 0 if linked or skipped, 1 if error
link_with_dir_prompt() {
    local src="$1"
    local dest="$2"
    local dest_name
    dest_name=$(basename "$dest")

    # 宛先が実ディレクトリ（シンボリックリンクではない）の場合
    if [[ -d "$dest" && ! -L "$dest" ]]; then
        # 非対話時 (CI、パイプ、cron) は尋ねずにスキップする
        # read が rc=1 を返して set -e で link.sh 全体が中断するのを防ぐ
        if [[ ! -t 0 ]]; then
            warning "Real directory exists (non-interactive, skipped): $dest"
            return 0
        fi
        warning "Real directory exists: $dest"
        printf "  Delete and replace with symlink? [y/N]: "
        read -r answer || answer=""
        case "$answer" in
            [yY]|[yY][eE][sS])
                # 削除ではなく退避する。誤操作でも元に戻せるようにする
                local backup
                backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
                mv "$dest" "$backup"
                info "Moved to backup: $backup"
                ln -fnsv "$src" "$dest"
                ;;
            *)
                info "Skipped: $dest_name"
                return 0
                ;;
        esac
    else
        ln -fnsv "$src" "$dest"
    fi
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
# 個別リンクのため link_dir_contents を通らない。取り残しを明示的に掃除する
prune_stale_links "$XDG_CONFIG_HOME/zsh"
link_file "$DOTFILES_DIR/config/zsh/.zshenv" "$HOME/.zshenv"
link_config "zsh/.zshrc"
link_config "zsh/.zimrc"
link_config "zsh/conf.d"

# Starship prompt configuration
link_config "starship/starship.toml" "starship.toml"

# Git configuration
link_config "git/config"
link_config "git/ignore"

# ccstatusline configuration (Claude Code status line)
link_config "ccstatusline/settings.json"

# iTerm2 configuration
link_config "iterm2/com.googlecode.iterm2.plist"

# tmux configuration
link_config "tmux/tmux.conf"

# act configuration
link_config "act/actrc"

# mise configuration (development tool version manager)
link_config "mise/config.toml"

# AeroSpace configuration (tiling window manager)
link_config "aerospace/aerospace.toml"

# Zed configuration
# ディレクトリごとではなく JSON 単位でリンクする
# (Zed 自身が ~/.config/zed 配下に themes/ や prompts/ を生成するため)
link_dir_contents "$DOTFILES_DIR/config/zed" "$XDG_CONFIG_HOME/zed" "file" "*.json"

# アプリ固有の設定（link.d/ 内のスクリプトを読み込み）
for link_script in "$SCRIPT_DIR/link.d"/*.sh; do
    [[ -f "$link_script" ]] || continue
    # shellcheck source=/dev/null
    source "$link_script"
done

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
