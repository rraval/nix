require("actions-preview").setup({
  backend = { "snacks" },
  highlight_command = {
    require("actions-preview.highlight").delta(),
  },
})
