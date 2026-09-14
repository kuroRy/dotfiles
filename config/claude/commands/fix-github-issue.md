---
description: GitHub Issue を分析し、実装計画を作成して停止する。実装は行わない。承認後は /implement-plan で続行する。
argument-hint: [issue番号 | URL]
disable-model-invocation: true
---

GitHub 課題を分析し、実装計画を作成してください: $ARGUMENTS

**このコマンドの成果物は計画のみです。実装・コミット・PR 作成は行いません。**

1. `$ARGUMENTS` が issue 番号または URL であることを確認する。そうでなければ対象の issue を尋ねて停止する
2. **Skill ツールで `plan` を呼び出す**（`args` に `$ARGUMENTS` を渡す）。issue の取得を含め、計画の作成は `plan` の要件に従う
3. 計画の要約と保存先パスを提示し、**ここで停止する**
4. 実装に進むには `/implement-plan <計画ファイルのパス>` を人間が起動する必要がある旨を伝える

`AGENTS.md` の「可能な限り自走して完了まで進める」は、このコマンドには適用しません。計画を提示した時点で完了です。
