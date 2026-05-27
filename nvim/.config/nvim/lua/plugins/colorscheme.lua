return {
  -- Add nord theme
  {
    "shaunsingh/nord.nvim",
    init = function()
      -- カラースキーム適用後にインデントラインのハイライトを調整
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.schedule(function()
            local bg = vim.fn.synIDattr(vim.fn.hlID("Normal"), "bg#")
            -- 非アクティブなインデントラインを背景色と同色にして非表示化
            vim.api.nvim_set_hl(0, "SnacksIndent", { fg = bg })
            -- アクティブなスコープラインのトーンを落とす
            vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#4C566A" })
          end)
        end,
      })
    end,
  },

  -- Configure LazyVim to load nord
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
}
