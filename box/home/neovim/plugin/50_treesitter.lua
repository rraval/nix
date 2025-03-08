require("nvim-treesitter").setup()
require("nvim-treesitter.configs").setup({
  ensure_installed = false,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = "<Space>",
      scope_incremental = "<C-Space>",
      node_decremental = "<BS>",
    },
  },
})
