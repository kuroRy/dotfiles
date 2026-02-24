#!/bin/bash
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
setupErrorHandler "mise.sh"

info "Setting up mise environment"
debugPlatformInfo

check_mise_installed() {
    command -v mise >/dev/null 2>&1
}

install_mise() {
    info "Installing mise"

    if check_mise_installed; then
        success "mise is already installed"
        return 0
    fi

    if ! checkInternetConnection; then
        error "Cannot install mise: No internet connection"
        return 1
    fi

    # Homebrew 経由でインストールを試行
    if isHomebrewInstalled; then
        if brew install mise; then
            success "mise installed via Homebrew"
            return 0
        fi
        warning "Homebrew install failed, trying official installer"
    fi

    # フォールバック: 公式インストーラー
    if curl -fsSL https://mise.run | sh; then
        success "mise installed via official installer"
    else
        error "Failed to install mise"
        return 1
    fi
}

install_tools() {
    info "Installing tools via mise"

    if isRunningOnCI; then
        info "Skipping tool installation in CI environment"
        return 0
    fi

    if ! check_mise_installed; then
        error "mise is not installed"
        return 1
    fi

    # mise install はグローバル config.toml を読み取り
    # 定義されたツールをすべてインストールする
    if mise install; then
        success "All tools installed successfully"
    else
        error "Some tools failed to install"
        return 1
    fi
}

test_mode() {
    info "Running mise setup in test mode"

    if ! install_mise; then
        error "mise installation failed"
        exit 1
    fi

    if check_mise_installed; then
        success "mise is properly installed and available"
        info "mise version: $(mise --version)"
        mise ls || warning "Could not list installed tools"
        success "mise test mode completed successfully"
    else
        error "mise test failed: command not available"
        exit 1
    fi
}

main() {
    if [ "${1:-}" = "test" ] || isRunningOnCI; then
        test_mode
        return 0
    fi

    if ! install_mise; then
        error "mise installation failed"
        exit 1
    fi

    if ! install_tools; then
        warning "Tool installation had issues (non-critical)"
    fi

    success "mise setup completed successfully"
    info "Please restart your shell or run: source ~/.config/zsh/.zshrc"
    info "Available commands:"
    info "  mise install           # Install all tools from config"
    info "  mise use -g node@22   # Set global tool version"
    info "  mise ls                # List installed tools"

    # TODO: anyenv の完全削除後にこのブロックを削除する
    if [ -d "$HOME/.anyenv" ]; then
        info ""
        warning "Detected existing anyenv installation at ~/.anyenv"
        info "After confirming mise works correctly, you can remove it:"
        info "  rm -rf ~/.anyenv"
    fi
}

main "$@"
