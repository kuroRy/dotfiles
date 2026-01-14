# zinit インストール
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
[[ -d "$ZINIT_HOME" ]] || mkdir -p "$(dirname "$ZINIT_HOME")"
[[ -d "$ZINIT_HOME/.git" ]] || git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# テーマ
zinit ice depth=1
zinit light romkatv/powerlevel10k

# 補完と入力候補
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# シンタックスハイライト
zinit light zdharma-continuum/fast-syntax-highlighting

# OMZ スニペット
zinit snippet OMZP::git
zinit snippet PZTM::helper
