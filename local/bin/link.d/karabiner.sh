#!/bin/bash
# Karabiner-Elements complex modifications (right Cmd -> Hyper key)
#
# 1. complex_modifications の JSON ファイルを Karabiner の設定ディレクトリにリンク
# 2. karabiner.json に未登録のルールがあれば自動で有効化

[[ -d "$DOTFILES_DIR/config/karabiner/assets/complex_modifications" ]] || return 0

# --- シンボリックリンクの作成 ---
KARABINER_MODS_DIR="$XDG_CONFIG_HOME/karabiner/assets/complex_modifications"
mkdir -p "$KARABINER_MODS_DIR"
link_dir_contents "$DOTFILES_DIR/config/karabiner/assets/complex_modifications" "$KARABINER_MODS_DIR" "file" "*.json"

# --- ルールの自動有効化 ---
KARABINER_JSON="$XDG_CONFIG_HOME/karabiner/karabiner.json"
[[ -f "$KARABINER_JSON" ]] || return 0

for mod_file in "$DOTFILES_DIR/config/karabiner/assets/complex_modifications"/*.json; do
    [[ -f "$mod_file" ]] || continue

    rule_count=$(jq '.rules | length' "$mod_file" 2>/dev/null || echo "0")
    for idx in $(seq 0 $((rule_count - 1))); do
        rule_desc=$(jq -r ".rules[$idx].description" "$mod_file")
        [[ -z "$rule_desc" || "$rule_desc" == "null" ]] && continue

        # 既に登録済みならスキップ
        if jq -e --arg desc "$rule_desc" \
            '.profiles[0].complex_modifications.rules // [] | any(.description == $desc)' \
            "$KARABINER_JSON" >/dev/null 2>&1; then
            debug "Karabiner rule already enabled: $rule_desc"
        else
            # ルールを karabiner.json に追加
            rule_json=$(jq ".rules[$idx]" "$mod_file")
            jq --argjson rule "$rule_json" \
                '.profiles[0].complex_modifications.rules += [$rule]' \
                "$KARABINER_JSON" > "${KARABINER_JSON}.tmp" \
                && mv "${KARABINER_JSON}.tmp" "$KARABINER_JSON" \
                && info "Karabiner rule enabled: $rule_desc"
        fi
    done
done
