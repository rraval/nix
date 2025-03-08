-- use 2 space indents for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"lua", "nix", "yaml"},
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
  end,
})
