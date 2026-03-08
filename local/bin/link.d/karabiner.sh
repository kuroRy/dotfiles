#!/bin/bash
# Karabiner-Elements complex modifications (right Cmd -> Hyper key)

[[ -d "$DOTFILES_DIR/config/karabiner/assets/complex_modifications" ]] || return 0

KARABINER_MODS_DIR="$XDG_CONFIG_HOME/karabiner/assets/complex_modifications"
mkdir -p "$KARABINER_MODS_DIR"
link_dir_contents "$DOTFILES_DIR/config/karabiner/assets/complex_modifications" "$KARABINER_MODS_DIR" "file" "*.json"

# karabiner.json にルールが未登録なら自動で有効化する
KARABINER_JSON="$XDG_CONFIG_HOME/karabiner/karabiner.json"
[[ -f "$KARABINER_JSON" ]] || return 0

for mod_file in "$DOTFILES_DIR/config/karabiner/assets/complex_modifications"/*.json; do
    [[ -f "$mod_file" ]] || continue
    # complex_modifications JSON 内の各ルールを取得して登録する
    rule_count=$(python3 -c "import json; rules=json.load(open('$mod_file')).get('rules',[]); print(len(rules))" 2>/dev/null || echo "0")
    for idx in $(seq 0 $((rule_count - 1))); do
        rule_desc=$(python3 -c "import json; print(json.load(open('$mod_file'))['rules'][$idx]['description'])" 2>/dev/null || echo "")
        [[ -z "$rule_desc" ]] && continue
        # 既に登録済みならスキップ
        if python3 -c "
import json, sys
config = json.load(open('$KARABINER_JSON'))
rules = config.get('profiles', [{}])[0].get('complex_modifications', {}).get('rules', [])
sys.exit(0 if any(r.get('description') == '''$rule_desc''' for r in rules) else 1)
" 2>/dev/null; then
            debug "Karabiner rule already enabled: $rule_desc"
        else
            # ルールを karabiner.json に追加
            python3 -c "
import json
mod = json.load(open('$mod_file'))
rule = mod['rules'][$idx]
config = json.load(open('$KARABINER_JSON'))
profile = config.setdefault('profiles', [{}])[0]
cm = profile.setdefault('complex_modifications', {})
rules = cm.setdefault('rules', [])
rules.append(rule)
with open('$KARABINER_JSON', 'w') as f:
    json.dump(config, f, indent=4)
" 2>/dev/null && info "Karabiner rule enabled: $rule_desc"
        fi
    done
done
