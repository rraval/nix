vim.api.nvim_create_autocmd({ 'TermRequest' }, {
  desc = 'Set `path` based on terminal cwd',
  callback = function(ev)
    if string.sub(vim.v.termrequest, 1, 4) == '\x1b]7;' then
      local dir = string.gsub(vim.v.termrequest, '\x1b]7;file://[^/]*', "")
      if vim.fn.isdirectory(dir) then
        vim.bo.path = dir
      end
    end
  end
})
