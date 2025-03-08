if vim.g.started_by_firenvim == true then
  vim.g.firenvim_config = {
    localSettings = {
        ['.*'] = {
          takeover = 'never',
          priority = 0,
        },
    },
  }

  vim.o.guifont = 'monospace:h10'

  vim.api.nvim_create_autocmd({'BufEnter'}, {
      pattern = "github.com_*.txt",
      command = "set filetype=markdown"
  })
end
