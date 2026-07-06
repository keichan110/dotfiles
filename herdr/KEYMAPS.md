# Herdr キーバインディング チートシート

> プレフィックスキー: `ctrl+b`（`prefix` と表記）
> 設定ファイル: `.config/herdr/config.toml`

---

## プレフィックスモード操作

| キー | 説明 |
|------|------|
| `prefix+?` | ヘルプ |
| `prefix+s` | 設定 |
| `prefix+q` | デタッチ |
| `prefix+shift+r` | 設定リロード |
| `prefix+o` | 通知ターゲットを開く |
| `prefix+w` | ワークスペースピッカー |
| `prefix+g` | goto |
| `prefix+shift+n` | 新規ワークスペース |
| `prefix+shift+g` | 新規worktree |
| `prefix+shift+w` | ワークスペースをリネーム |
| `prefix+shift+d` | ワークスペースを閉じる |

---

## タブ操作

| キー | 説明 |
|------|------|
| `prefix+c` | 新規タブ |
| `prefix+shift+t` | タブをリネーム |
| `prefix+p` | 前のタブ |
| `prefix+n` | 次のタブ |
| `prefix+1..9` | タブ切り替え（番号指定） |
| `prefix+shift+x` | タブを閉じる |

---

## ペイン操作

| キー | 説明 |
|------|------|
| `prefix+shift+p` | ペインをリネーム |
| `prefix+e` | スクロールバック編集 |
| `prefix+h` | 左のペインへフォーカス |
| `prefix+j` | 下のペインへフォーカス |
| `prefix+k` | 上のペインへフォーカス |
| `prefix+l` | 右のペインへフォーカス |
| `prefix+tab` | 次のペインへ循環 |
| `prefix+shift+tab` | 前のペインへ循環 |
| `prefix+v` | 垂直分割 |
| `prefix+minus` | 水平分割 |
| `prefix+x` | ペインを閉じる |
| `prefix+z` | ズーム（旧名: fullscreen） |
| `prefix+r` | リサイズモード |
| `prefix+b` | サイドバー表示切り替え |

---

## ナビゲートモード

> ナビゲートモード中のみ有効。`focus_pane_*` とは独立した別のショートカット。

| キー | 説明 |
|------|------|
| `up` | ワークスペースを上に移動 |
| `down` | ワークスペースを下に移動 |
| `h` / `←` | 左のペインへ移動 |
| `j` | 下のペインへ移動 |
| `k` | 上のペインへ移動 |
| `l` / `→` | 右のペインへ移動 |

---

## カスタムコマンド（keys.command）

| キー | コマンド | 種別 |
|------|---------|------|
| `prefix+alt+g` | `lazygit` | 一時ペイン（終了時に自動で閉じる） |

---

## 未設定（デフォルトで空）のバインディング

以下は用途に応じて `config.toml` の `[keys]` に追記することで有効化できる。

| 項目 | 説明 |
|------|------|
| `open_worktree` | worktreeを開く |
| `remove_worktree` | worktreeを削除（確認あり） |
| `previous_workspace` / `next_workspace` | 前 / 次のワークスペース |
| `previous_agent` / `next_agent` | 前 / 次のエージェント |
| `focus_agent` | エージェント行への直接フォーカス（例: `prefix+alt+1..9`） |
| `switch_workspace` | ワークスペース切り替え（例: `prefix+shift+1..9`） |
| `last_pane` | 直前のペインへ戻る |

---

## 補足: プレフィックス以外の関連設定

| 設定項目 | 説明 |
|------|------|
| `remote_image_paste` (`ctrl+v`) | `herdr --remote` 使用時のみ有効な画像ペースト |
| `keys.indexed` | レガシー形式の連番ショートカット（`tabs`/`workspaces`/`agents`）。新規設定では非推奨 |
