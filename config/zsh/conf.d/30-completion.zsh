# 補完スタイル（zimのcompletionモジュールで初期化済み）
setopt list_packed
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

# carapace（インストールされている場合）
if command -v carapace &>/dev/null; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  source <(carapace _carapace)
fi
