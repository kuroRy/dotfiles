# Dotfiles 改善 TODO

このドキュメントでは、dotfiles リポジトリの改善点をまとめています。

## 優先度：高

### Zsh 設定

- [ ] **zsh-history-substring-search のキーバインド設定**
  - ↑↓キーで部分一致履歴検索を有効化
  - `conf.d/20-keybinds.zsh` に追加

- [ ] **シェル起動時間プロファイリング機能**
  - 起動が遅い場合の原因特定用
  - `zmodload zsh/zprof` を使った計測オプション

### Tmux 設定

- [ ] **クリップボードのクロスプラットフォーム対応**
  - 現在 `pbcopy` (macOS) がハードコード
  - Linux では `xclip` または `wl-copy` を使用
  - プラットフォーム検出による自動切り替え

- [ ] **True Color サポートの追加**
  ```tmux
  set -g default-terminal "tmux-256color"
  set -ag terminal-overrides ",xterm-256color:RGB"
  ```

- [ ] **escape-time の最適化**
  - Vim/Neovim ユーザー向けに `set -sg escape-time 10`

### セキュリティ

- [ ] **Git コミット署名の設定ガイド**
  - GPG キーの生成・設定手順
  - `config.local.template` への追加

- [ ] **SSH キー管理のドキュメント化**
  - Ed25519 キーの生成手順
  - ssh-agent の設定

---

## 優先度：中

### パフォーマンス最適化

- [ ] **anyenv から mise への移行検討**
  - mise (旧 rtx) はより高速
  - 参考: https://mise.jdx.dev/
  - 移行スクリプトの作成

- [ ] **kubectl 補完の遅延読み込み**
  - 現在は起動時に毎回読み込み
  - 初回使用時に読み込むよう変更

### Brewfile の整理

- [ ] **パッケージのカテゴリ分け**
  - 開発ツール
  - ターミナル関連
  - GUI アプリケーション
  - フォント
  - VSCode 拡張機能

- [ ] **不要パッケージの精査**
  - 使用していないパッケージの削除
  - 非推奨 tap の更新 (adoptopenjdk 等)

### シェルスクリプト改善

- [ ] **エラーハンドリングの強化**
  - `set -u` の追加（未定義変数エラー）
  - trap によるクリーンアップ処理

- [ ] **ログ出力オプションの追加**
  - ファイルへのログ出力
  - CI 環境向けの構造化ログ

---

## 優先度：低

### ドキュメント

- [ ] **TROUBLESHOOTING.md の作成**
  - よくある問題と解決策
  - プラットフォーム固有の注意点

- [ ] **ARCHITECTURE.md の作成**
  - ディレクトリ構造の説明
  - 設定ファイルの読み込み順序
  - 依存関係図

- [ ] **設定ファイルへのコメント追加**
  - 各設定の目的を明記
  - カスタマイズのヒント

### 機能追加

- [ ] **Starship プロンプトのオプション対応**
  - P10k の軽量代替として
  - 設定ファイルの追加

- [ ] **Neovim 設定の追加**
  - Lua ベースの設定
  - LSP 設定

- [ ] **Fish シェルのサポート**
  - config.fish の作成
  - プラグイン管理

### テスト強化

- [ ] **機能テストの追加**
  - ツールが正しく初期化されるか
  - シンボリックリンクの検証

- [ ] **シェル起動時間のベンチマーク**
  - CI での定期計測
  - 閾値超過時のアラート

---

## 完了済み

- [x] zinit から zim への移行
- [x] .zshrc のモジュール化 (conf.d 構造)
- [x] .zshenv の統合
- [x] Git 設定の強化
- [x] グローバル gitignore の作成
- [x] fzf, zoxide の追加

---

## 参考リンク

- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [zim framework](https://zimfw.sh/)
- [mise (旧 rtx)](https://mise.jdx.dev/)
- [Starship](https://starship.rs/)
