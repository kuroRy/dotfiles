# Load all config modules
for config in "$ZDOTDIR"/conf.d/*.zsh(N); do
  source "$config"
done

# Local customizations (not tracked in git)
[[ -f "$ZDOTDIR/zshrc.local" ]] && source "$ZDOTDIR/zshrc.local"
# Legacy location fallback
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Starship prompt initialization
eval "$(starship init zsh)"
