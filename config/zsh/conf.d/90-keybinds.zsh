# キーバインド
# ^R は zim の fzf モジュールが fzf-history-widget に割り当てるため、ここでは上書きしない

# zsh-history-substring-search（↑↓キーで部分一致履歴検索）
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# Emacs/vi モード対応
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
