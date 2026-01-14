# ヒストリ設定
export HISTTIMEFORMAT="%F %T "
HISTSIZE=10000
SAVEHIST=100000
HISTFILESIZE=100000

# ヒストリオプション
setopt share_history          # ターミナル間で履歴を共有
setopt extended_history       # タイムスタンプと実行時間を記録
setopt hist_ignore_space      # スペース始まりのコマンドは履歴に残さない
setopt hist_verify            # 履歴展開後に確認してから実行
setopt hist_reduce_blanks     # 余分な空白を削除
setopt hist_save_no_dups      # 重複コマンドは保存しない
setopt hist_expand            # 履歴展開を有効化
setopt hist_ignore_all_dups   # 古い重複エントリを削除
setopt hist_ignore_dups       # 連続する重複を無視
setopt append_history         # 履歴ファイルに追記
setopt inc_append_history     # コマンドを即座に追加
setopt hist_no_store          # historyコマンド自体は記録しない
