require('copilot').setup({
  suggestion = {
    auto_trigger = true,
    keymap = {
      accept = "<M-l>",
      accept_word = "<M-;>",
      accept_line = "<M-'>",
      next = "<M-j>",
      prev = "<M-k>",
      dismiss = "<M-h>",
    },
  },
  should_attach = function (bufnr, bufname)
    -- retain default behavior
    if not vim.bo.buflisted then
      return false
    end

    if vim.bo.buftype ~= "" then
      return false
    end

    -- disable for .env / .envrc etc.
    if string.match(vim.fs.basename(bufname), '^%.env.*') then
      return false
    end

    return true
  end,
})
