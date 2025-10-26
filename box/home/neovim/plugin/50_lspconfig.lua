local lspconfig = require("lspconfig")
local util = require('lspconfig.util')

lspconfig.harper_ls.setup({})

lspconfig.basedpyright.setup({})

lspconfig.ruff.setup({})

lspconfig.rust_analyzer.setup({})

lspconfig.lua_ls.setup({
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          "''${3rd}/luv/library",
        }
      }
    })
  end,
  settings = {
    Lua = {}
  }
})

lspconfig.ts_ls.setup({})
