# nvim

[LazyVim](https://www.lazyvim.org/) ベースの Neovim 設定。

## 構成

```
nvim/.config/nvim/
├── init.lua              # エントリーポイント（lazy.nvim をブートストラップ）
├── lazyvim.json          # LazyVim extras の管理ファイル
├── lazy-lock.json        # プラグインのバージョンロック（手動編集不可）
├── stylua.toml           # Lua フォーマッター設定
└── lua/
    ├── config/
    │   ├── lazy.lua      # lazy.nvim の初期化
    │   ├── options.lua   # エディタオプション
    │   ├── keymaps.lua   # キーマップ追加
    │   └── autocmds.lua  # 自動コマンド
    └── plugins/              # プラグイン設定（ファイルを追加すると自動で読み込まれる）
```

## プラグイン（plugins/）
| ファイル | 設定内容 |
|---|---|
| `colorscheme.lua` | nord テーマを追加し LazyVim のデフォルトとして設定 |
| `snacks.lua` | Explorer で隠しファイルを常に表示 |
| `disable-themes.lua` | 不要なテーマを無効化 |
