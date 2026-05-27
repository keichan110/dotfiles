return {
  "petertriho/nvim-scrollbar",
  event = "BufReadPost",
  opts = {
    handlers = {
      gitsigns = true,
      search = true,
      diagnostic = true,
    },
  },
}
