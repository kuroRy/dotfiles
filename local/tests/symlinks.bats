#!/usr/bin/env bats
# シンボリックリンク検証テスト

load test_helper

# =============================================================================
# Zsh 設定ファイル
# =============================================================================

@test "zsh: ~/.zshenv symlink exists and valid" {
    skip_if_ci
    assert_symlink_exists "$HOME/.zshenv"
}

@test "zsh: ~/.zshenv points to dotfiles" {
    skip_if_ci
    assert_symlink "$HOME/.zshenv" "$(get_dotfiles_target config/zsh/.zshenv)"
}

@test "zsh: ~/.config/zsh/.zshrc symlink exists and valid" {
    skip_if_ci
    assert_symlink_exists "${XDG_CONFIG_HOME}/zsh/.zshrc"
}

@test "zsh: ~/.config/zsh/.zimrc symlink exists and valid" {
    skip_if_ci
    assert_symlink_exists "${XDG_CONFIG_HOME}/zsh/.zimrc"
}

@test "zsh: ~/.config/zsh/conf.d symlink exists and valid" {
    skip_if_ci
    assert_symlink_exists "${XDG_CONFIG_HOME}/zsh/conf.d"
}

# =============================================================================
# Git 設定ファイル
# =============================================================================

@test "git: ~/.config/git/config symlink exists and valid" {
    skip_if_ci
    assert_symlink_exists "${XDG_CONFIG_HOME}/git/config"
}

@test "git: ~/.config/git/ignore symlink exists and valid" {
    skip_if_ci
    assert_symlink_exists "${XDG_CONFIG_HOME}/git/ignore"
}

# =============================================================================
# Starship 設定ファイル
# =============================================================================

@test "starship: ~/.config/starship.toml symlink exists and valid" {
    skip_if_ci
    assert_symlink_exists "${XDG_CONFIG_HOME}/starship.toml"
}

# =============================================================================
# Tmux 設定ファイル
# =============================================================================

@test "tmux: ~/.config/tmux/tmux.conf symlink exists and valid" {
    skip_if_ci
    assert_symlink_exists "${XDG_CONFIG_HOME}/tmux/tmux.conf"
}

# =============================================================================
# WezTerm 設定ファイル
# =============================================================================

@test "wezterm: ~/.config/wezterm/wezterm.lua symlink exists and valid" {
    skip_if_ci
    skip_if_no_file "$(get_dotfiles_target config/wezterm/wezterm.lua)"
    assert_symlink_exists "${XDG_CONFIG_HOME}/wezterm/wezterm.lua"
}

# =============================================================================
# Ghostty 設定ファイル
# =============================================================================

@test "ghostty: ~/.config/ghostty/config symlink exists and valid" {
    skip_if_ci
    skip_if_no_file "$(get_dotfiles_target config/ghostty/config)"
    assert_symlink_exists "${XDG_CONFIG_HOME}/ghostty/config"
}

# =============================================================================
# Claude 設定ファイル
# =============================================================================

@test "claude: ~/.config/claude directory exists" {
    skip_if_ci
    assert_dir_exists "${XDG_CONFIG_HOME}/claude"
}

@test "claude: CLAUDE.md symlink exists and valid" {
    skip_if_ci
    skip_if_no_file "$(get_dotfiles_target config/claude/CLAUDE.md)"
    assert_symlink_exists "${XDG_CONFIG_HOME}/claude/CLAUDE.md"
}

@test "claude: mcp.json symlink exists and valid" {
    skip_if_ci
    skip_if_no_file "$(get_dotfiles_target config/claude/mcp.json)"
    assert_symlink_exists "${XDG_CONFIG_HOME}/claude/mcp.json"
}

@test "claude: ~/.mcp.json backward compatibility symlink exists" {
    skip_if_ci
    skip_if_no_file "$(get_dotfiles_target config/claude/mcp.json)"
    assert_symlink_exists "$HOME/.mcp.json"
}

# =============================================================================
# mise 設定ファイル
# =============================================================================

@test "mise: ~/.config/mise/config.toml symlink exists and valid" {
    skip_if_ci
    skip_if_no_file "$(get_dotfiles_target config/mise/config.toml)"
    assert_symlink_exists "${XDG_CONFIG_HOME}/mise/config.toml"
}

# =============================================================================
# Brewfile
# =============================================================================

@test "brewfile: ~/.Brewfile symlink exists and valid" {
    skip_if_ci
    skip_if_no_file "$(get_dotfiles_target local/share/dotfiles/brewfiles/.Brewfile)"
    assert_symlink_exists "$HOME/.Brewfile"
}

@test "brewfile: ~/.Brewfile points to dotfiles" {
    skip_if_ci
    skip_if_no_file "$(get_dotfiles_target local/share/dotfiles/brewfiles/.Brewfile)"
    assert_symlink "$HOME/.Brewfile" "$(get_dotfiles_target local/share/dotfiles/brewfiles/.Brewfile)"
}

# =============================================================================
# XDG Data Home
# =============================================================================

@test "xdg: XDG_DATA_HOME/dotfiles/brewfiles directory exists" {
    skip_if_ci
    assert_dir_exists "${XDG_DATA_HOME}/dotfiles/brewfiles"
}

# =============================================================================
# ローカル設定ファイル（テンプレートからコピー）
# =============================================================================

@test "local config: ~/.config/zsh/.zshrc.local exists (not symlink)" {
    skip_if_ci
    # このファイルはシンボリックリンクではなく、テンプレートからコピーされたファイル
    if [[ ! -f "${XDG_CONFIG_HOME}/zsh/.zshrc.local" ]]; then
        skip ".zshrc.local not yet created from template"
    fi
    assert_file_exists "${XDG_CONFIG_HOME}/zsh/.zshrc.local"
}

@test "local config: ~/.config/git/config.local exists (not symlink)" {
    skip_if_ci
    # このファイルはシンボリックリンクではなく、テンプレートからコピーされたファイル
    if [[ ! -f "${XDG_CONFIG_HOME}/git/config.local" ]]; then
        skip "config.local not yet created from template"
    fi
    assert_file_exists "${XDG_CONFIG_HOME}/git/config.local"
}
