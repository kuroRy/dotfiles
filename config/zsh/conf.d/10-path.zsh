# Homebrew PATH は ~/.zshenv で設定済み
# （zoxide 等の Homebrew ツールを Zim 初期化時に検出するため）

# Gradle
[[ -d "/opt/homebrew/opt/gradle@8/bin" ]] && export PATH="/opt/homebrew/opt/gradle@8/bin:$PATH"

# anyenv パス設定（初期化は40-tools.zshで遅延読み込み）
[[ -d "$HOME/.anyenv/bin" ]] && export PATH="$HOME/.anyenv/bin:$PATH"
