require("codecompanion").setup({
  adapters = {
    acp = {
      claude_code = function()
        return require("codecompanion.adapters").extend("claude_code", {
          env = {
            CLAUDE_CODE_OAUTH_TOKEN = "cmd:cat ~/.config/nvim/claude_code_oauth_token",
          },
        })
      end,
    },
  },
})
