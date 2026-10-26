#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
setupErrorHandler "test.sh"

info "dotfilesテストを開始"
debugPlatformInfo

# dotfilesディレクトリのパスを取得
DOTFILES_DIR="$(getDotfilesDir)"
info "dotfilesディレクトリ: ${DOTFILES_DIR}"

TEST_FAILED=0
TEST_COUNT=0

# テスト関数
test_assert() {
    local description="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    info "テスト ${TEST_COUNT}: ${description}"
    
    if eval "$command" >/dev/null 2>&1; then
        actual_exit_code=0
    else
        actual_exit_code=$?
    fi
    
    if [ "$actual_exit_code" -eq "$expected_exit_code" ]; then
        success "✓ ${description}"
    else
        error "✗ ${description} (終了コード: 期待値=${expected_exit_code}, 実際=${actual_exit_code})"
        TEST_FAILED=$((TEST_FAILED + 1))
    fi
}

# テスト関数（ファイル存在確認）
test_file_exists() {
    local description="$1"
    local file_path="$2"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    info "テスト ${TEST_COUNT}: ${description}"
    
    if [ -f "$file_path" ] || [ -L "$file_path" ]; then
        success "✓ ${description}"
    else
        error "✗ ${description} (ファイルが存在しません: ${file_path})"
        TEST_FAILED=$((TEST_FAILED + 1))
    fi
}

# テスト関数（コマンド存在確認）
test_command_exists() {
    local description="$1"
    local command_name="$2"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    info "テスト ${TEST_COUNT}: ${description}"
    
    if command -v "$command_name" >/dev/null 2>&1; then
        success "✓ ${description}"
    else
        error "✗ ${description} (コマンドが見つかりません: ${command_name})"
        TEST_FAILED=$((TEST_FAILED + 1))
    fi
}

# プラットフォーム検出のテスト
info "=== プラットフォーム検出テスト ==="
test_assert "基本プラットフォーム検出" "getPlatformInfo"
test_assert "Homebrewパス取得" "getHomebrewPath"

# getDotfilesDirがcwdを変更しないことを確認（直接テスト）
TEST_COUNT=$((TEST_COUNT + 1))
info "テスト ${TEST_COUNT}: getDotfilesDirはcwdを変更しない"
original_dir="$(pwd)"
getDotfilesDir >/dev/null
if [ "$(pwd)" = "$original_dir" ]; then
    success "✓ getDotfilesDirはcwdを変更しない"
else
    error "✗ getDotfilesDirはcwdを変更しない"
    TEST_FAILED=$((TEST_FAILED + 1))
fi

# 基本コマンドの存在確認
info "=== 基本コマンド存在確認 ==="
test_command_exists "bash" "bash"
test_command_exists "git" "git"

# プラットフォーム固有のテスト
if isRunningOnMac; then
    info "=== macOS固有テスト ==="
    test_command_exists "brew" "brew"
    test_assert "Xcode Command Line Tools" "xcode-select -p"
elif isRunningOnLinux; then
    info "=== Linux固有テスト ==="
    test_command_exists "curl" "curl"
    test_command_exists "wget" "wget"
fi

# dotfilesの基本構造テスト
info "=== dotfiles構造テスト ==="
test_file_exists "makefile" "${DOTFILES_DIR}/makefile"
test_file_exists "common.sh" "${DOTFILES_DIR}/local/bin/common.sh"
test_file_exists "init.sh" "${DOTFILES_DIR}/local/bin/init.sh"
test_file_exists "link.sh" "${DOTFILES_DIR}/local/bin/link.sh"
test_file_exists "zshrc" "${DOTFILES_DIR}/config/zsh/.zshrc"
test_file_exists "git config" "${DOTFILES_DIR}/config/git/config"
test_file_exists "ccstatusline settings" "${DOTFILES_DIR}/config/ccstatusline/settings.json"
test_file_exists ".Brewfile" "${DOTFILES_DIR}/local/share/dotfiles/brewfiles/.Brewfile"

# テンプレートファイルのテスト
info "=== テンプレートファイルテスト ==="
test_file_exists "zshrc.local.template" "${DOTFILES_DIR}/config/zsh/.zshrc.local.template"
test_file_exists "git config.local.template" "${DOTFILES_DIR}/config/git/config.local.template"

# ローカルコピー配置のテスト (Claude Code の settings.json などをリンクせずコピーで置く)
# 一時ディレクトリ内だけで完結させ、実環境には触れない
info "=== ローカルコピー配置テスト ==="
LC_DIR="$(mktemp -d)"
LC_SRC="${LC_DIR}/src.json"
printf '{"base": true}\n' > "$LC_SRC"

installLocalCopy "$LC_SRC" "${LC_DIR}/new/dest.json" >/dev/null || true
test_assert "宛先がなければ、リンクではなく実ファイルとしてコピーする" \
    "[ -f '${LC_DIR}/new/dest.json' ] && [ ! -L '${LC_DIR}/new/dest.json' ] && cmp -s '${LC_SRC}' '${LC_DIR}/new/dest.json'"

ln -s "$LC_SRC" "${LC_DIR}/linked.json"
installLocalCopy "$LC_SRC" "${LC_DIR}/linked.json" >/dev/null || true
test_assert "dotfiles を指す旧方式のリンクは、中身を保った実ファイルに置き換える" \
    "[ ! -L '${LC_DIR}/linked.json' ] && cmp -s '${LC_SRC}' '${LC_DIR}/linked.json'"
printf '{"local": true}\n' > "${LC_DIR}/linked.json"
test_assert "置き換え後にローカル側へ書き込んでも、dotfiles 側のファイルは変わらない" \
    "grep -q base '${LC_SRC}'"

printf '{"local": true}\n' > "${LC_DIR}/existing.json"
installLocalCopy "$LC_SRC" "${LC_DIR}/existing.json" >/dev/null || true
test_assert "既存の実ファイル (ローカルの変更) は上書きしない" \
    "grep -q local '${LC_DIR}/existing.json'"

printf '{"other": true}\n' > "${LC_DIR}/other.json"
ln -s "${LC_DIR}/other.json" "${LC_DIR}/foreign.json"
installLocalCopy "$LC_SRC" "${LC_DIR}/foreign.json" >/dev/null || true
test_assert "dotfiles 以外を指すリンクは、利用者の設定として触らない" \
    "[ -L '${LC_DIR}/foreign.json' ]"

[ -n "$LC_DIR" ] && [ -d "$LC_DIR" ] && rm -rf "$LC_DIR"

# cmux-worktree のテスト (git-gtr はスタブに差し替え、一時ディレクトリ内だけで完結させる)
info "=== cmux-worktree テスト ==="
WT_DIR="$(cd "$(mktemp -d)" && pwd -P)"
mkdir -p "${WT_DIR}/stub" "${WT_DIR}/tmp"
# git gtr new <branch> --porcelain の出力形式 (key<TAB>value) を模す
cat > "${WT_DIR}/stub/git-gtr" <<'EOS'
#!/bin/bash
[ "$1" = new ] || exit 1
wt="$(git rev-parse --show-toplevel)/../wt-$2"
git worktree add -q -b "$2" "$wt" >&2
printf 'path\t%s\nbranch\t%s\nhook_status\tnone\n' "$(cd "$wt" && pwd -P)" "$2"
EOS
chmod +x "${WT_DIR}/stub/git-gtr"
git init -q "${WT_DIR}/repo"
git -C "${WT_DIR}/repo" -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m init
WT_ENV="PATH='${WT_DIR}/stub':\$PATH TMPDIR='${WT_DIR}/tmp/' CMUX_WORKSPACE_ID=test"
WT_BIN="${DOTFILES_DIR}/local/bin/cmux-worktree"

test_assert "create は入力したブランチ名で worktree を作り、そのパスを出力する" \
    "cd '${WT_DIR}/repo' && [ \"\$(echo feature-x | env ${WT_ENV} '${WT_BIN}' create)\" = '${WT_DIR}/wt-feature-x' ]"
test_assert "attach は create が書いた worktree に移ってからコマンドを実行する" \
    "[ \"\$(env ${WT_ENV} '${WT_BIN}' attach pwd)\" = '${WT_DIR}/wt-feature-x' ]"
test_assert "create は git リポジトリの外では失敗する" \
    "cd '${WT_DIR}/tmp' && echo x | env ${WT_ENV} '${WT_BIN}' create" 1
# 失敗が伝わらないと attach が待ち続けるため、5 秒で打ち切ってテスト全体が止まらないようにする
# (GitHub の macOS ランナーには timeout コマンドがないため、perl の alarm で代用する。打ち切り時は 142 で失敗扱い)
test_assert "create が失敗したら、attach は待ち続けずにエラーで終わる" \
    "env ${WT_ENV} perl -e 'alarm 5; exec @ARGV' '${WT_BIN}' attach true" 1

[ -n "$WT_DIR" ] && [ -d "$WT_DIR" ] && rm -rf "$WT_DIR"

# スクリプトの構文チェック (link.d 配下も対象に含める)
info "=== スクリプト構文チェック ==="
for script in "${DOTFILES_DIR}/local/bin"/*.sh "${DOTFILES_DIR}/local/bin/link.d"/*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        test_assert "${script_name}の構文チェック" "bash -n $script"
    fi
done
# 拡張子なしで ~/.local/bin に置くコマンド
test_assert "cmux-worktreeの構文チェック" "bash -n ${DOTFILES_DIR}/local/bin/cmux-worktree"

# 設定ファイルの基本チェック（CI環境では実際のファイル配置後のみ）
info "=== 設定ファイル基本チェック ==="
if ! isRunningOnCI; then
    # ローカル環境でのみ実行（シンボリンクが作成されている前提）
    if [ -f "${HOME}/.config/zsh/.zshrc" ]; then
        # .zshrcはzsh固有の構文を含むためbash構文チェックは行わない
        test_file_exists ".zshrc存在確認(XDG)" "${HOME}/.config/zsh/.zshrc"
    fi
else
    # CI環境では元ファイルの存在確認のみ
    test_file_exists ".zshrc元ファイル確認" "${DOTFILES_DIR}/config/zsh/.zshrc"
fi

# 結果の出力
info "=== テスト結果 ==="
info "実行テスト数: ${TEST_COUNT}"
if [ "$TEST_FAILED" -eq 0 ]; then
    success "全てのテストが成功しました！"
    exit 0
else
    error "失敗したテスト数: ${TEST_FAILED}"
    exit 1
fi
