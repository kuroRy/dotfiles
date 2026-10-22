#!/bin/bash
# Git hooks (秘密情報のコミット前スキャン)
#
# 適用範囲は dotfiles リポジトリのみ。global の core.hooksPath は設定しない
# (設定すると全リポジトリの .git/hooks が無効化され、影響範囲が大きすぎるため)

GITHOOKS_SRC="$DOTFILES_DIR/config/git/hooks"
[[ -d "$GITHOOKS_SRC" ]] || return 0

# 実行ビットを保証する (clone 直後に落ちている場合がある)
chmod +x "$GITHOOKS_SRC"/* 2>/dev/null || true

# worktree や submodule では .git がファイルなので、-d 判定では検出できない
if ! git -C "$DOTFILES_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    debug "dotfiles is not a git repository; skipping hooks setup"
    return 0
fi

GITHOOKS_CURRENT=$(git -C "$DOTFILES_DIR" config --local --get core.hooksPath 2>/dev/null || true)
case "$GITHOOKS_CURRENT" in
    "config/git/hooks")
        debug "core.hooksPath already set for dotfiles repo"
        ;;
    "")
        # 掃除と同じく補助処理なので、失敗しても link.sh 全体を止めない
        if git -C "$DOTFILES_DIR" config --local core.hooksPath "config/git/hooks"; then
            info "Enabled pre-commit secret scan for dotfiles repo"
        else
            warning "Failed to set core.hooksPath; pre-commit secret scan is inactive"
        fi
        ;;
    *)
        # husky / lefthook など他ツールの設定を黙って壊さない
        warning "core.hooksPath is already set to '$GITHOOKS_CURRENT'; leaving it untouched"
        warning "  pre-commit secret scan is NOT active for this repo"
        ;;
esac
