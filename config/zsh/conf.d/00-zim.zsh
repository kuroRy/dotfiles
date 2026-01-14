# zim フレームワーク初期化
# https://zimfw.sh/

# XDG準拠のzimホームディレクトリ
ZIM_HOME="${XDG_DATA_HOME}/zim"

# zimがインストールされていない場合はインストール
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# モジュールが未インストールの場合はインストール
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# zimを初期化
source ${ZIM_HOME}/init.zsh
