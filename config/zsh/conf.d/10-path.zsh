# Homebrew - 動的検出と設定
if command -v brew &>/dev/null; then
  eval "$(brew shellenv)"
else
  for brew_path in "/opt/homebrew" "/usr/local" "/home/linuxbrew/.linuxbrew"; do
    if [[ -x "${brew_path}/bin/brew" ]]; then
      eval "$(${brew_path}/bin/brew shellenv)"
      break
    fi
  done
fi

# Gradle
[[ -d "/opt/homebrew/opt/gradle@8/bin" ]] && export PATH="/opt/homebrew/opt/gradle@8/bin:$PATH"

# anyenv パス設定（初期化は40-tools.zshで遅延読み込み）
[[ -d "$HOME/.anyenv/bin" ]] && export PATH="$HOME/.anyenv/bin:$PATH"
