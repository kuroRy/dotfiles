#!/bin/bash
# skills.txt に書いた外部 skill を npx skills でグローバルに入れる
set -eu
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
setupErrorHandler "skills.sh"

SKILLS_FILE="${SKILLS_FILE:-$(getDotfilesDir)/local/share/dotfiles/skills.txt}"

if ! command -v npx >/dev/null 2>&1; then
  error "npx が見つかりません (mise で node を入れてください)"
  exit 1
fi

while read -r source; do
  info "Installing skills from ${source}"
  # shellcheck disable=SC2046
  npx skills add "$source" -g -y --skill $(awk -v s="$source" '$1 == s { print $2 }' "$SKILLS_FILE") </dev/null
done < <(awk '!/^#/ && NF { print $1 }' "$SKILLS_FILE" | sort -u)
success "skills のインストールが完了しました"
