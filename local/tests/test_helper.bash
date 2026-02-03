#!/bin/bash
# BATS テスト用ヘルパー関数
# Usage: load test_helper in each .bats file

# dotfiles ディレクトリのパスを設定
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${TESTS_DIR}/../.." && pwd)"
BIN_DIR="${DOTFILES_DIR}/local/bin"

# common.sh の関数を読み込み
# shellcheck source=../bin/common.sh
source "${BIN_DIR}/common.sh"

# XDG 環境変数のデフォルト設定
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# =============================================================================
# BATS カスタムアサーション
# =============================================================================

# シンボリックリンクが正しいターゲットを指しているか検証
# Usage: assert_symlink <link_path> <expected_target>
assert_symlink() {
    local link_path="$1"
    local expected_target="$2"

    if [[ ! -L "$link_path" ]]; then
        echo "Not a symlink: $link_path" >&2
        return 1
    fi

    local actual_target
    actual_target="$(readlink "$link_path")"

    if [[ "$actual_target" != "$expected_target" ]]; then
        echo "Symlink target mismatch:" >&2
        echo "  Expected: $expected_target" >&2
        echo "  Actual: $actual_target" >&2
        return 1
    fi

    return 0
}

# シンボリックリンクが存在し、有効なターゲットを指しているか検証
# Usage: assert_symlink_exists <link_path>
assert_symlink_exists() {
    local link_path="$1"

    if [[ ! -L "$link_path" ]]; then
        echo "Not a symlink: $link_path" >&2
        return 1
    fi

    if [[ ! -e "$link_path" ]]; then
        echo "Symlink exists but target is broken: $link_path" >&2
        return 1
    fi

    return 0
}

# ファイルが存在するか検証
# Usage: assert_file_exists <file_path>
assert_file_exists() {
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        echo "File does not exist: $file_path" >&2
        return 1
    fi

    return 0
}

# ディレクトリが存在するか検証
# Usage: assert_dir_exists <dir_path>
assert_dir_exists() {
    local dir_path="$1"

    if [[ ! -d "$dir_path" ]]; then
        echo "Directory does not exist: $dir_path" >&2
        return 1
    fi

    return 0
}

# コマンドが存在するか検証
# Usage: assert_command_exists <command>
assert_command_exists() {
    local cmd="$1"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Command not found: $cmd" >&2
        return 1
    fi

    return 0
}

# zsh で関数が定義されているか検証
# Usage: assert_zsh_function_defined <function_name>
assert_zsh_function_defined() {
    local func_name="$1"

    if ! command -v zsh >/dev/null 2>&1; then
        skip "zsh not installed"
    fi

    local result
    result=$(ZDOTDIR="${XDG_CONFIG_HOME}/zsh" zsh -i -c "type $func_name" 2>&1) || true

    if echo "$result" | grep -q "function"; then
        return 0
    else
        echo "Function not defined in zsh: $func_name" >&2
        echo "Result: $result" >&2
        return 1
    fi
}

# zsh 環境変数が設定されているか検証
# Usage: assert_zsh_env_var <var_name> [expected_value]
assert_zsh_env_var() {
    local var_name="$1"
    local expected_value="${2:-}"

    if ! command -v zsh >/dev/null 2>&1; then
        skip "zsh not installed"
    fi

    local actual_value
    actual_value=$(ZDOTDIR="${XDG_CONFIG_HOME}/zsh" zsh -i -c "echo \$$var_name" 2>/dev/null)

    if [[ -z "$actual_value" ]]; then
        echo "Environment variable not set: $var_name" >&2
        return 1
    fi

    if [[ -n "$expected_value" && "$actual_value" != "$expected_value" ]]; then
        echo "Environment variable mismatch:" >&2
        echo "  Variable: $var_name" >&2
        echo "  Expected: $expected_value" >&2
        echo "  Actual: $actual_value" >&2
        return 1
    fi

    return 0
}

# =============================================================================
# スキップ条件
# =============================================================================

# CI 環境の場合はスキップ
skip_if_ci() {
    if isRunningOnCI; then
        skip "Skipped in CI environment"
    fi
}

# コマンドが存在しない場合はスキップ
skip_if_no_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        skip "$cmd not installed"
    fi
}

# ファイルが存在しない場合はスキップ
skip_if_no_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        skip "File not found: $file"
    fi
}

# ディレクトリが存在しない場合はスキップ
skip_if_no_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        skip "Directory not found: $dir"
    fi
}

# =============================================================================
# ユーティリティ関数
# =============================================================================

# 現在時刻をミリ秒で取得（クロスプラットフォーム対応）
# Usage: get_time_ms
get_time_ms() {
    if command -v gdate >/dev/null 2>&1; then
        # GNU date が利用可能（macOS で coreutils インストール済み）
        gdate +%s%3N
    elif [[ "$(uname)" == "Darwin" ]]; then
        # macOS: python3 を使用
        python3 -c 'import time; print(int(time.time()*1000))'
    else
        # Linux: date +%s%N からミリ秒を計算
        echo $(( $(date +%s%N) / 1000000 ))
    fi
}

# シェル起動時間を計測（ミリ秒）
# Usage: measure_shell_startup [runs]
measure_shell_startup() {
    local runs="${1:-5}"
    local total=0

    skip_if_no_command zsh
    skip_if_no_file "${XDG_CONFIG_HOME}/zsh/.zshrc"

    for _ in $(seq 1 "$runs"); do
        local start end elapsed
        start=$(get_time_ms)
        ZDOTDIR="${XDG_CONFIG_HOME}/zsh" zsh -i -c exit 2>/dev/null
        end=$(get_time_ms)
        elapsed=$((end - start))
        total=$((total + elapsed))
    done

    echo $((total / runs))
}

# dotfiles 内のシンボリックリンクターゲットパスを取得
# Usage: get_dotfiles_target <relative_path>
get_dotfiles_target() {
    local relative_path="$1"
    echo "${DOTFILES_DIR}/${relative_path}"
}
