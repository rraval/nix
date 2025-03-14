require("blink.cmp").setup({
  keymap = { preset = 'default' },
  sources = {
    per_filetype = {
      codecompanion = { "codecompanion" },
    },
    providers = {
      path = {
        opts = {
          get_cwd = function()
            return vim.fn.getcwd()
          end,
        },
      },
      cmdline = {
        min_keyword_length = function(ctx)
          -- when typing a command, only show when the keyword is 3 characters or longer
          if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 3 end
          return 0
        end
      },
    },
  },
  completion = {
    list = {
      selection = {
        preselect = false,
      },
    },
  },
  cmdline = {
    keymap = { preset = 'default' },
    completion = {
      menu = { auto_show = true },
      list = {
        selection = {
          preselect = false,
        },
      },
    },
  },
})
