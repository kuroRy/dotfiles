<!-- Based on mattpocock/skills (skills/engineering/domain-modeling/CONTEXT-FORMAT.md) — Copyright (c) 2026 Matt Pocock, MIT.
     日本語訳。ライセンス全文: ../THIRD-PARTY-LICENSES.md -->

# CONTEXT.md の書式

## 構成

```md
# {コンテキスト名}

{このコンテキストが何であり、なぜ存在するのかを1〜2文で。}

## Language

**Order**:
{その用語が何であるかの1〜2文の説明}
_Avoid_: Purchase, transaction

**Invoice**:
納品後に顧客へ送付される支払いの請求。
_Avoid_: Bill, payment request

**Customer**:
注文を行う個人または組織。
_Avoid_: Client, buyer, account
```

## ルール

- **立場を明確にする。** 同じ概念に複数の語が存在する場合、最良の一つを選び、残りを `_Avoid_` に列挙する。
- **定義は締める。** 最大でも1〜2文。それが **何であるか** を定義するのであって、何をするかではない。
- **このプロジェクトの文脈に固有の用語だけを載せる。** 一般的なプログラミング概念（タイムアウト、エラー型、ユーティリティのパターン）は、プロジェクトで多用していても対象外。用語を追加する前に問う。これはこのコンテキストに固有の概念か、それとも一般的なプログラミング概念か。前者だけが該当する。
- **自然なまとまりが現れたら、小見出しでグループ化する。** すべての用語が一つのまとまった領域に属するなら、フラットな一覧で構わない。

## 単一コンテキストか、複数コンテキストか

**単一コンテキスト（大半のリポジトリ）**: ルートに `CONTEXT.md` を1つ置く。

**複数コンテキスト**: ルートの `CONTEXT-MAP.md` が、コンテキストの一覧・所在・相互関係を示す。

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md): 顧客の注文を受け付け、追跡する
- [Billing](./src/billing/CONTEXT.md): 請求書を生成し、支払いを処理する
- [Fulfillment](./src/fulfillment/CONTEXT.md): 倉庫のピッキングと出荷を管理する

## Relationships

- **Ordering → Fulfillment**: Ordering が `OrderPlaced` イベントを発行し、Fulfillment がそれを消費してピッキングを開始する
- **Fulfillment → Billing**: Fulfillment が `ShipmentDispatched` イベントを発行し、Billing がそれを消費して請求書を生成する
- **Ordering ↔ Billing**: `CustomerId` と `Money` の型を共有する
```

どちらの構成かはスキルが推論する。

- `CONTEXT-MAP.md` があれば、それを読んでコンテキストを特定する
- ルートの `CONTEXT.md` だけがあれば、単一コンテキスト
- どちらもなければ、最初の用語が確定した時点でルートに `CONTEXT.md` を遅延作成する

複数のコンテキストが存在する場合、いま扱っている話題がどれに該当するかを推論する。判然としないときは質問する。
