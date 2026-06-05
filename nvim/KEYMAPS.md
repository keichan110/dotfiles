# LazyVim キーバインディング チートシート

> `<leader>` = `Space`

---

## ファイル・バッファ

| キー | 説明 |
|------|------|
| `<leader><space>` | ファイル検索 (root dir) |
| `<leader>ff` | ファイル検索 (root dir) |
| `<leader>fF` | ファイル検索 (cwd) |
| `<leader>fr` | 最近開いたファイル |
| `<leader>fn` | 新規ファイル作成 |
| `<leader>fc` | 設定ファイルを検索 |
| `<leader>e` | ファイルエクスプローラー (Snacks / root dir) |
| `<leader>E` | ファイルエクスプローラー (Snacks / cwd) |
| `<S-h>` / `<S-l>` | 前 / 次のバッファ |
| `[b` / `]b` | 前 / 次のバッファ |
| `<leader>bb` | 直前のバッファに切り替え |
| `<leader>bd` | バッファを閉じる |
| `<leader>bo` | 他のバッファをすべて閉じる |
| `<leader>bi` | 非表示バッファをすべて閉じる |
| `<leader>bD` | バッファとウィンドウを閉じる |
| `<leader>bp` | バッファをピン留め |
| `<leader>bj` | バッファをピックして切り替え |

---

## ウィンドウ・タブ

| キー | 説明 |
|------|------|
| `<C-h/j/k/l>` | ウィンドウ間を移動 |
| `<C-Up/Down>` | ウィンドウの高さを変更 |
| `<C-Left/Right>` | ウィンドウの幅を変更 |
| `<leader>-` | ウィンドウを水平分割 |
| `<leader>\|` | ウィンドウを垂直分割 |
| `<leader>wd` | ウィンドウを閉じる |
| `<leader>wm` | ズームモードをトグル |
| `<leader><tab><tab>` | 新規タブ |
| `<leader><tab>d` | タブを閉じる |
| `<leader><tab>]` | 次のタブ |
| `<leader><tab>[` | 前のタブ |
| `<leader><tab>f` | 最初のタブ |
| `<leader><tab>l` | 最後のタブ |
| `<leader><tab>o` | 他のタブをすべて閉じる |

---

## 検索・Grep

| キー | 説明 |
|------|------|
| `<leader>/` | プロジェクト全体をGrep (root dir) |
| `<leader>sg` | プロジェクト全体をGrep (root dir) |
| `<leader>sG` | プロジェクト全体をGrep (cwd) |
| `<leader>sw` | カーソル下の単語をGrep (root dir) |
| `<leader>sb` | バッファ内を行単位で検索 |
| `<leader>sB` | 開いているバッファ全体をGrep |
| `<leader>ss` | LSP シンボル検索 |
| `<leader>sS` | LSP ワークスペースシンボル検索 |
| `<leader>sd` | 診断一覧 |
| `<leader>sh` | ヘルプページ検索 |
| `<leader>sk` | キーマップ検索 |
| `<leader>sm` | マーク一覧 |
| `<leader>sj` | ジャンプリスト |
| `<leader>sR` | 前回の検索を再開 |
| `<leader>sr` | 検索・置換 (grug-far) |
| `n` / `N` | 次 / 前の検索結果（センタリング付き）|
| `*` / `#` | カーソル下の単語を前後検索（センタリング付き）|

---

## LSP・コード

| キー | 説明 |
|------|------|
| `gd` | 定義へジャンプ |
| `gD` | 宣言へジャンプ |
| `gr` | 参照一覧 |
| `gI` | 実装へジャンプ |
| `gy` | 型定義へジャンプ |
| `K` | ホバードキュメント表示 |
| `gK` | シグネチャヘルプ |
| `<leader>cl` | LSP 情報 |
| `<leader>ca` | コードアクション |
| `<leader>cc` | Codelens を実行 |
| `<leader>cr` | シンボルリネーム |
| `<leader>cR` | ファイルリネーム |
| `<leader>cf` | フォーマット |
| `<leader>co` | import を整理 |
| `<leader>cd` | 行の診断を表示 |
| `<leader>cs` | シンボル一覧 (Trouble) |
| `]]` / `[[` | 次 / 前のリファレンス |
| `]d` / `[d` | 次 / 前の診断 |
| `]e` / `[e` | 次 / 前のエラー |
| `]w` / `[w` | 次 / 前のWarning |

---

## Git

| キー | 説明 |
|------|------|
| `<leader>gs` | Git ステータス |
| `<leader>gd` | Git Diff (hunks) |
| `<leader>gD` | Git Diff (origin) |
| `<leader>gl` | Git ログ |
| `<leader>gL` | Git ログ (cwd) |
| `<leader>gb` | Git blame (行) |
| `<leader>gf` | 現在のファイルの履歴 |
| `<leader>gB` | Git Browse (ブラウザで開く) |
| `<leader>gS` | Git スタッシュ |

---

## ターミナル

| キー | 説明 |
|------|------|
| `<leader>ft` | ターミナルを開く (root dir) |
| `<leader>fT` | ターミナルを開く (cwd) |
| `<C-/>` | ターミナルトグル |

---

## UI・表示切り替え

| キー | 説明 |
|------|------|
| `<leader>ub` | 背景（明/暗）トグル |
| `<leader>ul` | 行番号トグル |
| `<leader>uL` | 相対行番号トグル |
| `<leader>uw` | 折り返しトグル |
| `<leader>ud` | 診断表示トグル |
| `<leader>uf` | 自動フォーマット on/off (グローバル) |
| `<leader>uF` | 自動フォーマット on/off (バッファ) |
| `<leader>us` | スペルチェックトグル |
| `<leader>uh` | インレイヒントトグル |
| `<leader>ug` | インデントガイドトグル |
| `<leader>uC` | カラースキーム選択 |
| `<leader>un` | 通知をすべて消す |
| `<leader>uZ` | ズームモードトグル |
| `<leader>uz` | Zen モードトグル |

---

## Quickfix・リスト

| キー | 説明 |
|------|------|
| `<leader>xl` | Location list を開く |
| `<leader>xq` | Quickfix list を開く |
| `<leader>xx` | 診断一覧 (Trouble) |
| `<leader>xX` | バッファの診断一覧 (Trouble) |
| `]q` / `[q` | 次 / 前のQuickfixアイテム |

---

## その他

| キー | 説明 |
|------|------|
| `<leader>qq` | 全ウィンドウを閉じて終了 |
| `<leader>n` | 通知履歴 |
| `<leader>L` | LazyVim チェンジログ |
| `<leader>?` | バッファのキーマップ一覧 (which-key) |
| `gco` / `gcO` | 下 / 上にコメント行を追加 |
| `<C-s>` | ファイル保存 |
| `<A-j>` / `<A-k>` | 行を上下に移動 |
| `gsa` | サラウンドを追加 (mini.surround) |
| `gsd` | サラウンドを削除 |
| `gsr` | サラウンドを置換 |

---

## カスタムキーマップ（keymaps.lua）

| キー | 説明 |
|------|------|
| `<leader>w` | ファイル保存 |
| `<leader>h` | 行頭（非空白）へ移動 |
| `<leader>l` | 行末へ移動 ※`Lazy`コマンドを上書き |
| `x` | 文字削除（ヤンクなし） |
| `s` | 文字削除して挿入（ヤンクなし） |
| `;` | コマンドモードへ（`:` 代替） |
| `:` | `f`/`t` モーションを繰り返す |
