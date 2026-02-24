# mise - 開発ツールバージョン管理
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
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
