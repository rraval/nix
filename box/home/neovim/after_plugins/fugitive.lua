-- Extends fugitive
--
-- In diffs, open file under cursor in a new split/tab with gf/gF

-- force an autoload and then find the sourced script
vim.fn["fugitive#Real"]("")

local scripts = vim.fn.getscriptinfo({name = ".*/autoload/fugitive.vim"})
if #scripts == 0 then
    vim.notify("Did not find fugitive script", vim.log.levels.ERROR)
    return
end

local fugitiveSid = scripts[1].sid

local function openFile(cmd)
  local results = vim.fn["<SNR>" .. fugitiveSid .. "_cfile"]()
  local commitAndFile = results[1]

  if commitAndFile == nil then
      vim.notify("No file to open", vim.log.levels.INFO)
      return
  end

  local commit, file = unpack(vim.split(commitAndFile, ":"))
  vim.cmd(cmd .. " " .. file)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"git"},
  callback = function()
    vim.keymap.set("n", "gf", function() openFile("split") end, { buffer = true })
    vim.keymap.set("n", "gF", function() openFile("tabedit") end, { buffer = true })
  end
})
