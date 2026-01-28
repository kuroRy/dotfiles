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

# kubectl - 遅延読み込みで起動を高速化
if command -v kubectl &>/dev/null; then
  kubectl() {
    unset -f kubectl
    source <(command kubectl completion zsh)
    kubectl "$@"
  }
fi

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
