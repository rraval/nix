require("buffer_manager").setup({
  width = math.floor(vim.o.columns * 0.8),
  height = math.floor(vim.o.lines * 0.8),
  order_buffers = "fullpath",
  show_indicators = true,
  short_term_names = true,
})
