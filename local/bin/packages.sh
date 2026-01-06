#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source ${SCRIPT_DIR}/common.sh


BREWFILES_DIR="$(getDotfilesDir)/local/share/dotfiles/brewfiles"
BREWFILE="$BREWFILES_DIR/.Brewfile"

require_macos() {
  if ! isRunningOnMac; then
    error "このスクリプトはmacOS専用です (detected: $(getPlatformInfo))"
    exit 1
  fi
}

ensure_brew() {
  if ! isHomebrewInstalled; then
    error "Homebrew is not installed"
    error "Please run 'make init' first"
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
  
  info "Installing packages with Homebrew (brew bundle --global)"
  brew bundle --global
  success "Installation of macOS packages has completed"
}

dump_brewfile() {
  require_macos
  ensure_brew

  info "Dumping installed packages to Brewfile"
  brew bundle dump --file="$BREWFILE" --force

  if [ -f "$BREWFILE" ]; then
    local new_entries
    new_entries=$(grep -c '^[^#[:space:]]' "$BREWFILE" 2>/dev/null || echo 0)
    success "Brewfile created: $BREWFILE"
    info "  entries: $new_entries"
  else
    error "Failed to create Brewfile"
    exit 1
  fi
}

main() {
  local cmd="${1:-install}"
  case "$cmd" in
    install) install_macos ;;
    status)  status ;;
    dump)    dump_brewfile ;;
    *)
      error "不明なコマンド: $cmd"
      echo "利用可能: install | status | dump"
      exit 1
      ;;
  esac
}

# デバッグ情報を出力
if [ "${DEBUG:-}" = "1" ]; then
  debugPlatformInfo
fi

main "$@"
