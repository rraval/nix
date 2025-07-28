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
})
