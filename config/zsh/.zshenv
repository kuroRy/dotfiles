# シェル起動時間プロファイリング
# 使用方法: ZSH_PROFILE=1 zsh -i -c exit
if [[ -n "$ZSH_PROFILE" ]]; then
  zmodload zsh/zprof
fi

# XDG Base Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# 必要なディレクトリを作成
[[ -d "$XDG_CONFIG_HOME" ]] || mkdir -p "$XDG_CONFIG_HOME"
[[ -d "$XDG_DATA_HOME" ]] || mkdir -p "$XDG_DATA_HOME"
[[ -d "$XDG_STATE_HOME" ]] || mkdir -p "$XDG_STATE_HOME"
[[ -d "$XDG_CACHE_HOME" ]] || mkdir -p "$XDG_CACHE_HOME"

# Zsh
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"

if [[ -f "$XDG_CONFIG_HOME/zsh/.zshrc" ]]; then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
elif [[ -f "$HOME/.zshrc" ]]; then
    # 従来の場所から読み込み（後方互換性）
    export ZDOTDIR="$HOME"
fi

export HISTFILE="$XDG_STATE_HOME/zsh/history"

# Homebrew - .zshrc の conf.d より前に PATH を設定する必要がある
# （zoxide 等の Homebrew ツールを Zim 初期化時に検出するため）
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

# Docker
[[ -d "$XDG_CONFIG_HOME/docker" ]] || mkdir -p "$XDG_CONFIG_HOME/docker"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

# AWS CLI
[[ -d "$XDG_CONFIG_HOME/aws" ]] || mkdir -p "$XDG_CONFIG_HOME/aws"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"

# Claude Code
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

# Less
[[ -d "$XDG_STATE_HOME/less" ]] || mkdir -p "$XDG_STATE_HOME/less"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
