# anyenv - 遅延読み込みで起動を高速化
if [[ -d "$HOME/.anyenv" ]]; then
  anyenv() {
    unset -f anyenv nodenv pyenv rbenv
    eval "$(command anyenv init -)"
    anyenv "$@"
  }
  # 各envマネージャーも遅延読み込み
  nodenv() { anyenv; nodenv "$@" }
  pyenv() { anyenv; pyenv "$@" }
  rbenv() { anyenv; rbenv "$@" }
fi

# kubectl - 存在チェック付き
if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh)
fi

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
