#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
setupErrorHandler "lint.sh"

info "シェルスクリプトの静的解析を開始"

# 静的解析ツールの存在確認
if ! command -v shellcheck >/dev/null 2>&1; then
    error "shellcheckがインストールされていません"
    info "インストール方法:"
    info "  macOS: brew install shellcheck"
    info "  Ubuntu: sudo apt-get install shellcheck"
    exit 1
fi

DOTFILES_DIR="$(getDotfilesDir)"
LINT_FAILED=0
LINT_COUNT=0

# Shellcheckオプション
# -x: sourceされたファイルも追跡
# -e SC1091: sourceされたファイルが見つからない警告を無視（CI環境用）
SHELLCHECK_OPTS="-x -e SC1091"

info "=== Shellcheck (静的解析) ==="
for script in "${DOTFILES_DIR}/local/bin"/*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        LINT_COUNT=$((LINT_COUNT + 1))

        # shellcheck disable=SC2086
        if shellcheck $SHELLCHECK_OPTS "$script" 2>&1; then
            success "✓ ${script_name}"
        else
            error "✗ ${script_name}"
            LINT_FAILED=$((LINT_FAILED + 1))
        fi
    fi
done

# shfmtの存在確認（オプション）
if command -v shfmt >/dev/null 2>&1; then
    info ""
    info "=== shfmt (フォーマットチェック) ==="
    for script in "${DOTFILES_DIR}/local/bin"/*.sh; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")

            if shfmt -d "$script" >/dev/null 2>&1; then
                success "✓ ${script_name} (フォーマット OK)"
            else
                warning "⚠ ${script_name} (フォーマット差分あり)"
                info "  修正: shfmt -w $script"
            fi
        fi
    done
else
    info ""
    info "shfmtがインストールされていません（フォーマットチェックをスキップ）"
    info "インストール: brew install shfmt"
fi

# 結果の出力
info ""
info "=== Lint結果 ==="
info "検証スクリプト数: ${LINT_COUNT}"
if [ "$LINT_FAILED" -eq 0 ]; then
    success "全てのスクリプトがShellcheckを通過しました！"
    exit 0
else
    error "失敗したスクリプト数: ${LINT_FAILED}"
    exit 1
fi
