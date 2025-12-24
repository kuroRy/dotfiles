#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPT_DIR}/common.sh


BREWFILES_DIR="$(getDotfilesDir)/local/share/dotfiles/brewfiles"
BREWFILE="$BREWFILES_DIR/Brewfile"

require_macos() {
  if ! isRunningOnMac; then
    error "このスクリプトはmacOS専用です (detected: $(getPlatformInfo))"
    exit 1
  fi
}

ensure_brew() {
  if ! isHomebrewInstalled; then
    error "Homebrewが未インストールです。先に 'make init' を実行してください。"
    exit 1
  fi
}

status() {
  require_macos
  info "Platform: $(getPlatformInfo)"
  info "Homebrew: $(isHomebrewInstalled && echo 'installed' || echo 'missing')"
  info "Brewfiles dir: $BREWFILES_DIR"
  if [ -f "$BREWFILE" ]; then
    info "  Brewfile present: $BREWFILE"
    info "  entries: $(grep -c '^[^#[:space:]]' "$BREWFILE" 2>/dev/null || echo 0)"
  else
    warning "  Brewfile not found: $BREWFILE"
  fi
  if [[ -L "$HOME/.Brewfile" ]]; then
    success "$HOME/.Brewfile symlink is present"
  else
    warning "$HOME/.Brewfile symlink not found (run 'make link')"
  fi
}

install_macos() {
  require_macos
  ensure_brew
  
  if [ ! -f "$BREWFILE" ]; then
    error "Brewfile not found: $BREWFILE"
    error "Please create $BREWFILE or run 'make link' first"
    exit 1
  fi
  
  info "Homebrewでインストールします (brew bundle --global)"
  brew bundle --global
  success "macOSパッケージのインストールが完了しました"
}

main() {
  local cmd="${1:-install}"
  case "$cmd" in
    install) install_macos ;;
    status)  status ;;
    *)
      error "不明なコマンド: $cmd"
      echo "利用可能: install | status"
      exit 1
      ;;
  esac
}

# デバッグ情報を出力
if [ "${DEBUG:-}" = "1" ]; then
  debugPlatformInfo
fi

main "$@"
