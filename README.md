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
- **秘密情報のコミット防止**: `make link` で pre-commit フックを有効化し、トークン・APIキー・秘密鍵の混入を検出

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
│   ├── zed/                   # Zed 設定
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
│   │   ├── mise.sh            # mise セットアップ
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

### セキュリティ

| 項目 | 説明 |
|------|------|
| pre-commit フック | `make link` 時に有効化。ステージされた追加行からトークン・APIキー・秘密鍵を検出しコミットを中断する |
| 秘密情報の置き場所 | `~/.config/git/config.local` や `~/.config/zsh/.zshrc.local` など、`*.local` 系 (git 管理外) に置く |
| 意図的に通す場合 | `git commit --no-verify` |

このリポジトリは public です。ツールが `git config --global` や設定ファイルへ書き込んだ
マシン固有の値が、追跡ファイルに紛れ込むことがあります。コミット前に `git diff --cached` を確認してください。

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

- **[mise](https://mise.jdx.dev/)**: 開発ツールバージョン管理
  - Node.js 24.22.1
  - Go 1.26.10

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
~/.config/claude/settings.json  # Claude Code 設定 (config/claude/settings.json のコピー)
```

テンプレートは以下の場所にあります:
- `config/zsh/.zshrc.local.template`
- `config/git/config.local.template`
- `config/claude/settings.json`

Claude Code の `settings.json` は、Claude Code 自身が書き戻します (auto モードの環境情報など、業務固有の値を含みます)。
そのためリンクせずコピーで配置し、旧方式のリンクが残っている場合は `make link` で中身を保ったまま実ファイルに置き換えます。
dotfiles 側を変更したときは、差分を確認して手で反映してください:

```bash
diff <(jq -S . config/claude/settings.json) <(jq -S 'del(.autoMode)' ~/.config/claude/settings.json)
```

## CI/CD

GitHub Actions で以下のテストを実行しています:

- **Shellcheck**: スクリプトの静的解析
- **macOS テスト**: Apple Silicon (M1/M2/M3) での動作確認
- **Ubuntu テスト**: Docker コンテナでの動作確認

## ノート

- **秘匿情報 (トークン、APIキー、業務固有の情報) は、git 管理外の `~/.config/**/*.local` に置いてください。**
  リポジトリで追跡されるファイル (`config/` 配下、`local/bin/` 配下、`.Brewfile` など) には絶対に書かないでください。
  このリポジトリは public です。一度コミットすると履歴から回収できません。
- テンプレート (`*.template`) はリポジトリで追跡されます。ここに実際の値を書かないでください。
- macOS の `defaults` 変更時は、逆操作をコメントとして併記してください。

## ライセンス

MIT License
