require("blink.cmp").setup({
  keymap = { preset = 'enter' },
  sources = {
    per_filetype = {
      codecompanion = { "codecompanion" },
    }
  },
  completion = {
    menu = {
      auto_show = function(ctx) return ctx.mode ~= 'cmdline' end,
    },
  }
})
