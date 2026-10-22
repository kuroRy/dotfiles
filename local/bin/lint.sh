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

# shfmtオプション
# 注意: 現状インデントは混在している (local/bin/*.sh は2スペース、
# link.d/*.sh と config/git/hooks/* は4スペース)。一括整形するまで
# この警告は解消しない。整形する場合は全ファイルを同じオプションで揃えること。
SHFMT_OPTS="-i 2"

# 検査対象: local/bin 直下、link.d 配下、および拡張子のないスクリプト
# (pre-commit フックは秘密情報を止める安全装置なので、必ず検査対象に含める)
lint_targets() {
    local f
    for f in "${DOTFILES_DIR}/local/bin"/*.sh \
        "${DOTFILES_DIR}/local/bin/link.d"/*.sh \
        "${DOTFILES_DIR}/local/bin/difit-cmux" \
        "${DOTFILES_DIR}/config/git/hooks"/*; do
        [ -f "$f" ] && printf '%s\n' "$f"
    done
}

info "=== Shellcheck (静的解析) ==="
while IFS= read -r script; do
    script_name=$(basename "$script")
    LINT_COUNT=$((LINT_COUNT + 1))

    # shellcheck disable=SC2086
    if shellcheck $SHELLCHECK_OPTS "$script" 2>&1; then
        success "✓ ${script_name}"
    else
        error "✗ ${script_name}"
        LINT_FAILED=$((LINT_FAILED + 1))
    fi
done < <(lint_targets)

# shfmtの存在確認（オプション）
if command -v shfmt >/dev/null 2>&1; then
    info ""
    info "=== shfmt (フォーマットチェック) ==="
    while IFS= read -r script; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")

            # shellcheck disable=SC2086
            if shfmt $SHFMT_OPTS -d "$script" >/dev/null 2>&1; then
                success "✓ ${script_name} (フォーマット OK)"
            else
                warning "⚠ ${script_name} (フォーマット差分あり)"
                info "  修正: shfmt ${SHFMT_OPTS} -w $script"
            fi
        fi
    done < <(lint_targets)
else
    info ""
    info "shfmtがインストールされていません（フォーマットチェックをスキップ）"
    info "インストール: brew install shfmt"
fi

# 結果の出力
info ""
info "=== Lint結果 ==="
info "検証スクリプト数: ${LINT_COUNT}"
if [ "$LINT_COUNT" -eq 0 ]; then
    error "検査対象が0件です。パス指定を確認してください"
    exit 1
fi
if [ "$LINT_FAILED" -eq 0 ]; then
    success "全てのスクリプトがShellcheckを通過しました！"
    exit 0
else
    error "失敗したスクリプト数: ${LINT_FAILED}"
    exit 1
fi
