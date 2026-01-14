# Powerlevel10k instant prompt (must stay at the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load all config modules
for config in "$ZDOTDIR"/conf.d/*.zsh(N); do
  source "$config"
done

# Local customizations (not tracked in git)
[[ -f "$ZDOTDIR/zshrc.local" ]] && source "$ZDOTDIR/zshrc.local"
# Legacy location fallback
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Powerlevel10k theme configuration
[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"
