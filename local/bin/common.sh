#!/bin/bash
# where: local/bin/common.sh
# what: 共通ユーティリティ関数
# why: 各スクリプトから再利用される処理を集約するため

info () {
  printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

error () {
  printf "\r\033[2K  [\033[0;31mERROR\033[0m] %s\n" "$1"
}

warning () {
  printf "\r\033[2K  [\033[0;33mWARN\033[0m] %s\n" "$1"
}

debug () {
  if [ "${DEBUG:-}" = "1" ]; then
    printf "\r  [ \033[00;90mDEBUG\033[0m ] %s\n" "$1"
  fi
}

# 基本的なプラットフォーム検出
isRunningOnMac () {
  [ "$(uname)" = "Darwin" ]
}

isRunningOnLinux () {
  [ "$(uname)" = "Linux" ]
}

# 詳細なプラットフォーム検出
isRunningOnMacARM () {
  isRunningOnMac && [ "$(uname -m)" = "arm64" ]
}

isRunningOnMacIntel () {
  isRunningOnMac && [ "$(uname -m)" = "x86_64" ]
}

getLinuxDistro () {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  elif [ -f /etc/redhat-release ]; then
    echo "rhel"
  elif [ -f /etc/debian_version ]; then
    echo "debian"
  else
    echo "unknown"
  fi
}

# プラットフォーム情報を取得
getPlatformInfo () {
  local platform=""
  local distro=""
  
  if isRunningOnMac; then
    platform="macos"
    if isRunningOnMacARM; then
      platform="macos-arm"
    elif isRunningOnMacIntel; then
      platform="macos-intel"
    fi
  elif isRunningOnLinux; then
    distro="$(getLinuxDistro)"
    platform="linux-${distro}"
  else
    platform="unknown"
  fi
  
  echo "${platform}"
}

# Homebrewのパスを動的に取得
getHomebrewPath () {
  if isRunningOnMac; then
    if isRunningOnMacARM; then
      echo "/opt/homebrew"
    else
      echo "/usr/local"
    fi
  elif isRunningOnLinux; then
    echo "/home/linuxbrew/.linuxbrew"
  else
    return 1
  fi
}

# Homebrewがインストールされているかチェック
isHomebrewInstalled () {
  command -v brew >/dev/null 2>&1
}

# CI環境の検出
isRunningOnCI () {
  [ "${CI:-}" = "true" ] || [ "${GITHUB_ACTIONS:-}" = "true" ]
}

# dotfilesディレクトリのパスを取得
getDotfilesDir () {
  if isRunningOnCI; then
    # CI環境では現在のディレクトリを使用
    pwd
  elif [ -n "${DOTFILES_DIR:-}" ]; then
    # 環境変数が設定されている場合
    echo "$DOTFILES_DIR"
  elif [ -d "${HOME}/dotfiles" ]; then
    # 標準的な場所
    echo "${HOME}/dotfiles"
  else
    # スクリプトの親ディレクトリを推測
    (cd "$(dirname "$0")/.." && pwd)
  fi
}

# プラットフォーム情報をデバッグ出力
debugPlatformInfo () {
  debug "Platform: $(getPlatformInfo)"
  debug "Architecture: $(uname -m)"
  debug "CI Environment: $(isRunningOnCI && echo 'Yes' || echo 'No')"
  debug "Dotfiles directory: $(getDotfilesDir)"
  debug "Homebrew path: $(getHomebrewPath 2>/dev/null || echo 'N/A')"
  debug "Homebrew installed: $(isHomebrewInstalled && echo 'Yes' || echo 'No')"
}

# エラーハンドリング関数

# インターネット接続確認
checkInternetConnection() {
  local test_urls=("https://www.google.com" "https://github.com" "https://raw.githubusercontent.com")
  
  for url in "${test_urls[@]}"; do
    if curl -s --connect-timeout 10 --max-time 30 --head "$url" >/dev/null 2>&1; then
      debug "Internet connection confirmed via $url"
      return 0
    fi
  done
  
  return 1
}

# ダウンロード
safeDownload() {
  local url="$1"
  local output="$2"
  local description="${3:-file}"
  
  info "Downloading $description"
  debug "URL: $url"
  debug "Output: $output"
  
  # インターネット接続確認
  if ! checkInternetConnection; then
    error "No internet connection available"
    warning "Please check your network connection and try again"
    warning "If you're behind a corporate firewall, you may need to configure proxy settings"
    return 1
  fi
  
  # ダウンロード実行（リトライ付き）
  local max_retries=3
  local retry_count=0
  
  while [ $retry_count -lt $max_retries ]; do
    if curl -fsSL --connect-timeout 30 --max-time 300 "$url" -o "$output"; then
      success "$description downloaded successfully"
      return 0
    else
      retry_count=$((retry_count + 1))
      if [ $retry_count -lt $max_retries ]; then
        warning "Download failed. Retrying ($retry_count/$max_retries)..."
        sleep 2
      fi
    fi
  done
  
  error "Failed to download $description after $max_retries attempts"
  warning "Please check the URL: $url"
  return 1
}

# sudo権限チェック
checkSudoAccess() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    debug "Running as root"
    return 0
  fi
  
  if sudo -n true 2>/dev/null; then
    debug "Sudo access available (passwordless)"
    return 0
  fi
  
  info "Checking sudo access"
  if sudo -v 2>/dev/null; then
    debug "Sudo access confirmed"
    return 0
  else
    warning "Sudo access not available"
    return 1
  fi
}

# パッケージが既にインストールされているかチェック
isPackageInstalled() {
  local package_manager="$1"
  local package="$2"
  local installed=0
  local not_installed=1

  case "$package_manager" in
    apt|apt-get)
      if dpkg -l "$package" 2>/dev/null | grep -q "^ii"; then
        return $installed
      else
        return $not_installed
      fi
      ;;
    dnf)
      if dnf list installed "$package" 2>/dev/null | grep -q "^$package\."; then
        return $installed
      else
        return $not_installed
      fi
      ;;
    pacman)
      if pacman -Q "$package" 2>/dev/null >/dev/null; then
        return $installed
      else
        return $not_installed
      fi
      ;;
    *)
      error "Unknown package manager: $package_manager"
      return 1
      ;;
  esac
}

# パッケージインストール（エラー耐性）
safePackageInstall() {
  local package_manager="$1"
  shift
  local packages=("$@")
  local failed_packages=()
  local skipped_packages=()
  local installed_packages=()
  
  info "Installing packages with $package_manager"
  
  for package in "${packages[@]}"; do
    # 既にインストールされているかチェック
    if isPackageInstalled "$package_manager" "$package"; then
      info "Package already installed, skipping: $package"
      skipped_packages+=("$package")
      continue
    fi
    
    info "Installing: $package"
    case "$package_manager" in
      apt|apt-get)
        if ! sudo apt-get install -y "$package" -qq 2>/dev/null; then
          warning "Failed to install: $package"
          failed_packages+=("$package")
        else
          installed_packages+=("$package")
        fi
        ;;
      dnf)
        if ! sudo dnf install -y "$package" -q 2>/dev/null; then
          warning "Failed to install: $package"
          failed_packages+=("$package")
        else
          installed_packages+=("$package")
        fi
        ;;
      pacman)
        if ! sudo pacman -S --noconfirm "$package" 2>/dev/null; then
          warning "Failed to install: $package"
          failed_packages+=("$package")
        else
          installed_packages+=("$package")
        fi
        ;;
      *)
        error "Unknown package manager: $package_manager"
        return 1
        ;;
    esac
  done
  
  if [ ${#skipped_packages[@]} -gt 0 ]; then
    info "Skipped packages (already installed): ${skipped_packages[*]}"
  fi
  
  if [ ${#installed_packages[@]} -gt 0 ]; then
    success "Successfully installed packages: ${installed_packages[*]}"
  fi
  
  if [ ${#failed_packages[@]} -gt 0 ]; then
    warning "Some packages failed to install: ${failed_packages[*]}"
    warning "You may need to install them manually later"
    info "Failed packages: ${failed_packages[*]}"
    return 1
  else
    success "All packages processed successfully"
    return 0
  fi
}

# Homebrewインストール（直接実行方式）
installHomebrew() {
  info "Installing Homebrew"
  
  # 複数のURL（フォールバック対応）
  local urls=(
    "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    "https://cdn.jsdelivr.net/gh/Homebrew/install@HEAD/install.sh"
    "https://raw.fastgit.org/Homebrew/install/HEAD/install.sh"
  )
  
  # インターネット接続確認
  if ! checkInternetConnection; then
    error "Cannot install Homebrew: No internet connection"
    warning "Please check your network connection and try again"
    return 1
  fi
  
  local attempt=0
  local max_attempts=${#urls[@]}
  
  for url in "${urls[@]}"; do
    attempt=$((attempt + 1))
    info "Homebrew install attempt $attempt/$max_attempts"
    debug "Trying URL: $url"
    
    # 直接実行方式：curl の出力を直接 bash に渡す
    # shellcheck disable=SC2086
    if /bin/bash -c "$(curl -fsSL --connect-timeout 30 --max-time 300 --retry 2 \
                      -H 'User-Agent: dotfiles-installer/1.0' \
                      -H 'Accept: text/plain, application/x-sh' \
                      "$url")"; then
      success "Homebrew installed successfully from: $url"
      
      # インストール確認
      local homebrew_path
      homebrew_path="$(getHomebrewPath)"
      if [ -n "$homebrew_path" ] && [ -x "$homebrew_path/bin/brew" ]; then
        success "Homebrew binary confirmed at: $homebrew_path/bin/brew"
        return 0
      else
        warning "Homebrew installed but binary not found at expected location"
        # PATH確認のために一度sourceしてみる
        if command -v brew >/dev/null 2>&1; then
          success "Homebrew is available in PATH"
          return 0
        else
          warning "Homebrew binary not found in PATH either"
        fi
      fi
    else
      local exit_code=$?
      warning "Homebrew install failed from URL: $url (exit code: $exit_code)"
      
      # 最後の試行でない場合は継続
      if [ "$attempt" -lt "$max_attempts" ]; then
        info "Trying next URL..."
        sleep 3
      fi
    fi
  done
  
  # 全てのURLで失敗
  error "Failed to install Homebrew from all available sources"
  warning "URLs tried:"
  for url in "${urls[@]}"; do
    warning "  - $url"
  done
  warning ""
  warning "Manual installation instructions:"
  warning "1. Visit https://brew.sh"
  warning "2. Copy and run the installation command"
  warning "3. Follow the on-screen instructions"
  
  if isRunningOnCI; then
    warning ""
    warning "CI Environment troubleshooting:"
    warning "- Check if GitHub/CDN access is blocked"
    warning "- Verify network connectivity in CI environment"
    warning "- Consider using a different base image or runner"
  fi

  return 1
}
