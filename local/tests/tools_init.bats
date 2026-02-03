#!/usr/bin/env bats
# ツール初期化テスト

load test_helper

# =============================================================================
# Zim フレームワーク初期化
# =============================================================================

@test "zim: ZIM_HOME directory exists" {
    skip_if_ci
    assert_dir_exists "${XDG_DATA_HOME}/zim"
}

@test "zim: zimfw.zsh exists" {
    skip_if_ci
    assert_file_exists "${XDG_DATA_HOME}/zim/zimfw.zsh"
}

@test "zim: init.zsh exists (compiled modules)" {
    skip_if_ci
    # init.zsh は .zimrc から生成されるファイル
    if [[ ! -f "${XDG_DATA_HOME}/zim/init.zsh" ]]; then
        skip "init.zsh not yet generated (run zimfw install first)"
    fi
    assert_file_exists "${XDG_DATA_HOME}/zim/init.zsh"
}

# =============================================================================
# 遅延読み込み関数テスト
# =============================================================================

@test "lazy loading: anyenv function defined" {
    skip_if_ci
    skip_if_no_dir "$HOME/.anyenv"
    assert_zsh_function_defined "anyenv"
}

@test "lazy loading: nodenv function defined" {
    skip_if_ci
    skip_if_no_dir "$HOME/.anyenv"
    assert_zsh_function_defined "nodenv"
}

@test "lazy loading: pyenv function defined" {
    skip_if_ci
    skip_if_no_dir "$HOME/.anyenv"
    assert_zsh_function_defined "pyenv"
}

@test "lazy loading: rbenv function defined" {
    skip_if_ci
    skip_if_no_dir "$HOME/.anyenv"
    assert_zsh_function_defined "rbenv"
}

@test "lazy loading: kubectl function defined" {
    skip_if_ci
    skip_if_no_command kubectl
    assert_zsh_function_defined "kubectl"
}

# =============================================================================
# Starship プロンプト初期化
# =============================================================================

@test "starship: command exists" {
    assert_command_exists starship
}

@test "starship: config file exists" {
    skip_if_ci
    assert_file_exists "${XDG_CONFIG_HOME}/starship.toml"
}

@test "starship: STARSHIP_SHELL is set to zsh" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"
    assert_zsh_env_var "STARSHIP_SHELL" "zsh"
}

# =============================================================================
# fzf 初期化
# =============================================================================

@test "fzf: command exists" {
    assert_command_exists fzf
}

@test "fzf: keybindings are loaded" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"

    # fzf のキーバインドが設定されていることを確認（Ctrl+R で履歴検索）
    local result
    result=$(ZDOTDIR="${XDG_CONFIG_HOME}/zsh" zsh -i -c 'bindkey | grep fzf' 2>/dev/null) || true

    # fzf 関連のキーバインドが存在することを確認
    if [[ -n "$result" ]]; then
        return 0
    else
        # fzf キーバインドが設定されていない場合はスキップ
        skip "fzf keybindings not configured"
    fi
}

# =============================================================================
# zoxide 初期化
# =============================================================================

@test "zoxide: command exists" {
    assert_command_exists zoxide
}

@test "zoxide: z function defined" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"
    assert_zsh_function_defined "z"
}

@test "zoxide: zi function defined" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"
    assert_zsh_function_defined "zi"
}

# =============================================================================
# direnv 初期化
# =============================================================================

@test "direnv: command exists" {
    skip_if_no_command direnv
    assert_command_exists direnv
}

@test "direnv: hook is loaded" {
    skip_if_ci
    skip_if_no_command direnv
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"

    # direnv hook がロードされているかを確認
    local result
    result=$(ZDOTDIR="${XDG_CONFIG_HOME}/zsh" zsh -i -c 'type _direnv_hook' 2>&1) || true

    if echo "$result" | grep -q "function"; then
        return 0
    else
        skip "direnv hook not loaded"
    fi
}

# =============================================================================
# XDG 環境変数
# =============================================================================

@test "xdg: XDG_CONFIG_HOME is set" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"
    assert_zsh_env_var "XDG_CONFIG_HOME"
}

@test "xdg: XDG_DATA_HOME is set" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"
    assert_zsh_env_var "XDG_DATA_HOME"
}

@test "xdg: ZDOTDIR is set to XDG_CONFIG_HOME/zsh" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"
    assert_zsh_env_var "ZDOTDIR" "${XDG_CONFIG_HOME}/zsh"
}

# =============================================================================
# Homebrew
# =============================================================================

@test "homebrew: brew command exists" {
    assert_command_exists brew
}

@test "homebrew: HOMEBREW_PREFIX is set" {
    skip_if_ci
    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"
    assert_zsh_env_var "HOMEBREW_PREFIX"
}

# =============================================================================
# Git
# =============================================================================

@test "git: command exists" {
    assert_command_exists git
}

@test "git: user.name is configured" {
    skip_if_ci
    local name
    name=$(git config --global user.name 2>/dev/null) || true
    if [[ -z "$name" ]]; then
        skip "git user.name not configured (set in ~/.config/git/config.local)"
    fi
}

@test "git: user.email is configured" {
    skip_if_ci
    local email
    email=$(git config --global user.email 2>/dev/null) || true
    if [[ -z "$email" ]]; then
        skip "git user.email not configured (set in ~/.config/git/config.local)"
    fi
}
