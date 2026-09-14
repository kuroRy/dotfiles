#!/bin/bash
# Claude configuration (XDG_CONFIG_HOME supported since v1.0.28)

[[ -d "$DOTFILES_DIR/config/claude" ]] || return 0

CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
mkdir -p "$CLAUDE_CONFIG_DIR"

# Directories to link individually (allows coexistence with Claude-generated files)
individual_link_dirs=("skills" "scripts")

# Link non-individual items directly
for claude_file in "$DOTFILES_DIR/config/claude"/*; do
    [[ -e "$claude_file" ]] || continue
    local_name=$(basename "$claude_file")

    # Skip directories that need individual linking
    for skip_dir in "${individual_link_dirs[@]}"; do
        if [[ "$local_name" == "$skip_dir" ]]; then
            continue 2
        fi
    done

    ln -fnsv "$claude_file" "$CLAUDE_CONFIG_DIR/"
done

# Link contents of individual directories
for dir_name in "${individual_link_dirs[@]}"; do
    src_dir="$DOTFILES_DIR/config/claude/$dir_name"
    dest_dir="$CLAUDE_CONFIG_DIR/$dir_name"

    [[ -d "$src_dir" ]] || continue
    mkdir -p "$dest_dir"

    # dotfiles から削除・リネームされた項目のリンク切れを掃除
    # 対象は dotfiles を指すリンク切れのみ。実ディレクトリ・実ファイル
    # (Claude が生成したもの) と、dotfiles 外を指すリンクには触れない
    # 隠し項目は対象外 (直後のリンク作成ループも同じく * のため一貫)
    # 掃除は補助処理なので、失敗しても本処理を止めない
    for stale_link in "$dest_dir"/*; do
        [[ -L "$stale_link" && ! -e "$stale_link" ]] || continue
        link_target=$(readlink "$stale_link")
        [[ "$link_target" == "$DOTFILES_DIR"/* ]] || continue
        if rm -f "$stale_link"; then
            info "Removed broken symlink: $stale_link"
        else
            warning "Failed to remove broken symlink: $stale_link"
        fi
    done

    for item in "$src_dir"/*; do
        [[ -e "$item" ]] || continue
        item_name=$(basename "$item")
        dest_path="$dest_dir/$item_name"
        link_with_dir_prompt "$item" "$dest_path"
    done
done

# mcp.json: ホームディレクトリにもリンク（後方互換性）
if [[ -f "$DOTFILES_DIR/config/claude/mcp.json" ]]; then
    ln -fnsv "$DOTFILES_DIR/config/claude/mcp.json" "$HOME/.mcp.json"
    info "Linked mcp.json to ~/.mcp.json for backward compatibility"
fi
