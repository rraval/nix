local lspconfig = require("lspconfig")

lspconfig.harper_ls.setup({})

lspconfig.pyright.setup({
  on_new_config = function(new_config, new_root_dir)
    -- poetry integration with local .venv directories
    local pythonPath = new_root_dir .. "/.venv/bin/python"
    if vim.fn.filereadable(pythonPath) then
      new_config.settings.python.pythonPath = pythonPath
    end
  end,
})

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
