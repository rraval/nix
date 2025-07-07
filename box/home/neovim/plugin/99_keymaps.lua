vim.keymap.set('n', '<Leader>s', '<Plug>(leap)')
vim.keymap.set('n', '<Leader>S', '<Plug>(leap-from-window)')
vim.keymap.set({'x', 'o'}, '<Leader>s', '<Plug>(leap-forward)')
vim.keymap.set({'x', 'o'}, '<Leader>S', '<Plug>(leap-backward)')

vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<Leader>r", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
vim.keymap.set("n", "<Leader>R", function() require("buffer_manager.ui").toggle_quick_menu() end, { desc = "Manage buffers" })
vim.keymap.set("n", "<Leader>t", function()
  require("telescope").extensions.smart_open.smart_open({
    cwd_only = true,
    filename_first = false,
  })
end, { noremap = true, silent = true, desc = "Smart Open" })
vim.keymap.set({"n", "v"}, "<Leader>fr", "<cmd>GrugFar<CR>", { desc = "Find & Replace" })
vim.keymap.set("n", "<Leader>ft", "<cmd>Telescope<CR>", { desc = "Find in files" })
vim.keymap.set("n", "<Leader>ff", "<cmd>Telescope live_grep<CR>", { desc = "Find in files" })
vim.keymap.set("n", "<Leader>fg", "<cmd>Telescope git_branches<CR>", { desc = "Find git branches" })
vim.keymap.set("n", "<Leader>fm", "<cmd>Telescope marks<CR>", { desc = "Find marks" })

vim.keymap.set("n", "<C-CR>", require("actions-preview").code_actions, { desc = "LSP code action" })

-- jump to tab by number
for i = 1, 9 do
  vim.keymap.set("n", "<Leader>" .. i, "" .. i .. "gt<CR>", { desc = "Switch to tab " .. i })
end

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

local function currentBufDir()
    local bufnr = vim.api.nvim_get_current_buf()
    local buftype = vim.bo[bufnr].buftype
    local filetype = vim.bo[bufnr].filetype

    local bufDir
    if filetype == 'oil' then
        return require("oil").get_current_dir(bufnr)
    elseif filetype == 'fugitive' then
        return vim.fn.fnamemodify(vim.b.git_dir, ':h')
    elseif buftype == 'terminal' then
        _, _, bufDir = string.find(vim.fn.expand('%:p:h'), "term://(.*)//")
        return bufDir
    else
        return vim.fn.expand('%:p:h')
    end
end

local function findProjectDirUpwards(startDir)
  local curDir = startDir

  while curDir ~= '/' do
    if vim.fn.isdirectory(curDir .. '/.git') == 1 then
      return curDir
    end

    if vim.fn.filereadable(curDir .. '/justfile') == 1 then
      return curDir
    end

    curDir = vim.fn.fnamemodify(curDir, ':h')
  end

  return '/'
end

local function openTerminal(openCmd, dir)
    local shell = os.getenv('SHELL')
    vim.api.nvim_command(string.format('%s term://%s//%s', openCmd, dir, shell))
end

vim.api.nvim_set_keymap('n', '<Leader>w', "", {
  noremap = true,
  callback = function() openTerminal("vsplit", currentBufDir()) end,
  desc = "Open terminal in current buffer's directory",
})

vim.api.nvim_set_keymap('n', '<Leader>W', "", {
  noremap = true,
  callback = function() openTerminal("tabe", findProjectDirUpwards(currentBufDir())) end,
  desc = "Open terminal in current buffer's project directory",
})

vim.api.nvim_set_keymap('n', '<Leader><Leader>', "", {
  noremap = true,
  callback = function() require("snacks").scratch() end,
  desc = "Toggle Scratch Buffer",
})

vim.api.nvim_set_keymap('n', '<Leader>x', "<cmd>Trouble diagnostics toggle<cr>", {
  noremap = true,
  desc = "Diagnostics (Trouble)",
})

vim.keymap.set("n", "s", require('substitute').operator, { noremap = true })
vim.keymap.set("n", "ss", require('substitute').line, { noremap = true })
vim.keymap.set("n", "S", require('substitute').eol, { noremap = true })
vim.keymap.set("x", "s", require('substitute').visual, { noremap = true })

vim.api.nvim_set_keymap('n', 'gf', "<C-W>F", {
  desc = "Goto file line under cursor in split",
})
vim.api.nvim_set_keymap('n', 'gF', "<C-W>gF", {
  desc = "Goto file line under cursor in tab",
})

vim.keymap.set({ "n", "v" }, "<Leader>d", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "<Leader>D", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "<Leader>c", '"+y', { noremap = true, silent = true, desc = "Copy to system clipboard" })
vim.keymap.set({ "n", "v" }, "<Leader>p", '"+p', { noremap = true, silent = true, desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "<Leader>P", '"+P', { noremap = true, silent = true, desc = "Paste from system clipboard" })

vim.keymap.set('', '*', '<Plug>(asterisk-*)', {})
vim.keymap.set('', '#', '<Plug>(asterisk-#)', {})
vim.keymap.set('', 'g*', '<Plug>(asterisk-g*)', {})
vim.keymap.set('', 'g#', '<Plug>(asterisk-g#)', {})
vim.keymap.set('', 'z*', '<Plug>(asterisk-z*)', {})
vim.keymap.set('', 'gz*', '<Plug>(asterisk-gz*)', {})
vim.keymap.set('', 'z#', '<Plug>(asterisk-z#)', {})
vim.keymap.set('', 'gz#', '<Plug>(asterisk-gz#)', {})
