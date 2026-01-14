# 補完システム初期化（1回のみ、キャッシュ付き）
autoload -Uz compinit

# 補完キャッシュを1日1回だけ再構築
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
else
  compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
fi

# 補完スタイル
setopt list_packed
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

# carapace（インストールされている場合）
if command -v carapace &>/dev/null; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  source <(carapace _carapace)
fi
