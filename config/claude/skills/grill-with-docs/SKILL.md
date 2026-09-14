---
name: grill-with-docs
description: 計画や設計を研ぎ澄ますための容赦のないインタビュー。進行に合わせてドキュメント（ADR と用語集）も作成する。
disable-model-invocation: true
---

<!-- Based on mattpocock/skills (skills/engineering/grill-with-docs) — Copyright (c) 2026 Matt Pocock, MIT.
     日本語訳・運用メモを加筆。ライセンス全文: ../THIRD-PARTY-LICENSES.md -->

Skill ツールを2回、"grilling" と "domain-modeling" に対して呼び出す。

## `grill-me` との違い

両者ともインタビュー中に必要な事実は環境から調べる。違いは **調べた結果を残すかどうか** である。

こちらは **ステートフル** である。コードベースの記述と発言内容の矛盾を突いたうえで、確定した用語を `CONTEXT.md` に、覆しにくい判断を `docs/adr/` に書き残す。既存プロダクトの設計を詰めるときはこちらを使う。

リポジトリを持たない検討（事業判断、文章、次に何をするか）であれば、何も残さない `grill-me` の方が適している。
