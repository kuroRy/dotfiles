#!/bin/bash
# Claude configuration (XDG_CONFIG_HOME supported since v1.0.28)

[[ -d "$DOTFILES_DIR/config/claude" ]] || return 0

CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
mkdir -p "$CLAUDE_CONFIG_DIR"

# Directories to link individually (allows coexistence with Claude-generated files)
individual_link_dirs=("skills" "scripts")

# Files Claude Code writes back to. Installed as local copies, not symlinks:
# auto mode setup and /config store machine- or work-specific values here,
# which must not end up in this public repository.
local_copy_files=("settings.json")

# Link non-individual items directly
for claude_file in "$DOTFILES_DIR/config/claude"/*; do
    [[ -e "$claude_file" ]] || continue
    local_name=$(basename "$claude_file")

    # Skip items handled separately below
    for skip_name in "${individual_link_dirs[@]}" "${local_copy_files[@]}"; do
        if [[ "$local_name" == "$skip_name" ]]; then
            continue 2
        fi
    done

    ln -fnsv "$claude_file" "$CLAUDE_CONFIG_DIR/"
done

# Install local copies (a symlink left by older setups is converted in place)
for copy_name in "${local_copy_files[@]}"; do
    installLocalCopy "$DOTFILES_DIR/config/claude/$copy_name" "$CLAUDE_CONFIG_DIR/$copy_name"
done

# Link contents of individual directories
for dir_name in "${individual_link_dirs[@]}"; do
    src_dir="$DOTFILES_DIR/config/claude/$dir_name"
    dest_dir="$CLAUDE_CONFIG_DIR/$dir_name"

    [[ -d "$src_dir" ]] || continue
    mkdir -p "$dest_dir"

    # dotfiles から削除・リネームされた項目のリンク切れを掃除する
    prune_stale_links "$dest_dir"

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
