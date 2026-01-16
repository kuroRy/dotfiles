<!-- where: repository root; what: project overview; why: quick entry point -->
# dotfiles

XDG Base Directory Specification に準拠したマルチプラットフォーム対応の dotfiles です。
macOS / Linux をサポートし、開発環境を一貫して構築できます。

## 特徴

- **XDG 準拠**: 設定ファイルを `~/.config/` 配下に集約し、ホームディレクトリをクリーンに保つ
- **マルチプラットフォーム**: macOS (Intel/Apple Silicon)、Linux (Ubuntu/Fedora/Arch) に対応
- **タスク駆動**: Make ターゲットで初期化・リンク・パッケージ導入を自動化
- **CI 検証**: GitHub Actions で macOS/Ubuntu の両環境をテスト
- **Docker 検証**: ローカルで Ubuntu 22.04 環境を再現可能

## クイックスタート

```bash
# リポジトリをクローン
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 一括セットアップ (init → link → defaults → packages)
make all

# または段階的に実行
make init      # Homebrew、フォント、基本ツールのインストール
make link      # XDG 配下へシンボリックリンク作成
make defaults  # macOS の defaults 設定 (macOS のみ)
make packages  # Brewfile からパッケージをインストール
```

## ディレクトリ構造

```
dotfiles/
├── config/                    # アプリケーション設定
│   ├── zsh/                   # zsh 設定 (.zshrc, .p10k.zsh)
│   ├── git/                   # Git 設定
│   ├── tmux/                  # tmux 設定
│   ├── vscode/                # VS Code 設定
│   ├── cursor/                # Cursor 設定
│   ├── wezterm/               # WezTerm 設定
│   ├── iterm2/                # iTerm2 設定
│   ├── claude/                # Claude Code 設定 & スキル
│   ├── codex/                 # Codex 設定
│   └── act/                   # act (GitHub Actions ローカル実行) 設定
├── local/
│   ├── bin/                   # 実行スクリプト群
│   │   ├── common.sh          # 共通ユーティリティ関数
│   │   ├── init.sh            # 初期化スクリプト
│   │   ├── link.sh            # シンボリックリンク作成
│   │   ├── defaults.sh        # macOS defaults 設定
│   │   ├── packages.sh        # パッケージ管理
│   │   ├── anyenv.sh          # anyenv セットアップ
│   │   ├── test.sh            # テストスクリプト
│   │   ├── verify.sh          # 検証スクリプト
│   │   └── lint.sh            # Lint スクリプト
│   ├── share/dotfiles/
│   │   └── brewfiles/         # Brewfile 群
│   └── state/dotfiles/
│       └── backups/           # Brewfile バックアップ
├── docker/                    # Docker 検証用
├── .github/workflows/         # GitHub Actions CI
├── .zshenv                    # XDG 環境変数設定 (最初に読み込まれる)
└── makefile                   # タスクランナー
```

## コマンド一覧

### 基本コマンド

| コマンド | 説明 |
|----------|------|
| `make all` | 一括セットアップ (init → link → defaults → packages) |
| `make init` | Homebrew、フォント、基本パッケージのインストール |
| `make link` | XDG 配下へシンボリックリンク作成 |
| `make defaults` | macOS の defaults 設定 (macOS のみ) |
| `make packages` | Brewfile からパッケージをインストール |

### テスト・検証コマンド

| コマンド | 説明 |
|----------|------|
| `make test` | 構文チェック・ファイル存在確認・基本テスト |
| `make lint` | Shellcheck による静的解析 |
| `make verify` | 環境検証 (リンク・フォント・ツール) |
| `make ci` | CI 向け軽量テスト |

### パッケージ管理コマンド (macOS)

| コマンド | 説明 |
|----------|------|
| `make packages-status` | 現在のパッケージ管理状況を表示 |

### Docker 検証コマンド

```bash
# Ubuntu 22.04 で一括テスト
docker compose -f docker-compose.test.yml up --build ubuntu22-test

# インタラクティブモードで検証
docker compose -f docker-compose.test.yml run --rm ubuntu22-interactive
```

### デバッグモード

```bash
# 詳細ログを出力
DEBUG=1 make init
DEBUG=1 make link
```

## XDG Base Directory

このプロジェクトは XDG Base Directory Specification に準拠しています。

| 環境変数 | デフォルト値 | 用途 |
|----------|------------|------|
| `XDG_CONFIG_HOME` | `~/.config` | 設定ファイル |
| `XDG_DATA_HOME` | `~/.local/share` | データファイル |
| `XDG_STATE_HOME` | `~/.local/state` | 状態ファイル (履歴など) |
| `XDG_CACHE_HOME` | `~/.cache` | キャッシュファイル |

`.zshenv` で XDG 環境変数を設定し、各アプリケーションの設定が適切な場所に配置されます。

## 技術スタック

### シェル環境

- **zsh**: デフォルトシェル
- **zinit**: プラグインマネージャ
- **Powerlevel10k**: 高速なプロンプトテーマ
- **zsh-autosuggestions**: コマンド補完
- **fast-syntax-highlighting**: シンタックスハイライト

### 言語バージョン管理

- **anyenv**: バージョンマネージャの統合管理
  - **jenv**: Java バージョン管理
  - **nodenv**: Node.js バージョン管理
  - **goenv**: Go バージョン管理

### パッケージ管理

- **Homebrew**: macOS / Linux 向けパッケージマネージャ
- **apt**: Debian/Ubuntu 向け
- **dnf**: Fedora/RHEL 向け
- **pacman**: Arch Linux 向け

## ローカル設定

個人設定は `.local` ファイルで管理します。これらのファイルは Git 管理対象外です。

```bash
# テンプレートから生成 (make link で自動生成)
~/.config/zsh/.zshrc.local      # zsh のローカル設定
~/.config/git/config.local      # Git ユーザー情報など
```

テンプレートは以下の場所にあります:
- `config/zsh/.zshrc.local.template`
- `config/git/config.local.template`

## CI/CD

GitHub Actions で以下のテストを実行しています:

- **Shellcheck**: スクリプトの静的解析
- **macOS テスト**: Apple Silicon (M1/M2/M3) での動作確認
- **Ubuntu テスト**: Docker コンテナでの動作確認

## ノート

- `config/zsh/.zshrc.local` や `config/git/config.local` には秘匿情報を記載しないでください。
- macOS の `defaults` 変更時は、逆操作をコメントとして併記してください。

## ライセンス

MIT License
