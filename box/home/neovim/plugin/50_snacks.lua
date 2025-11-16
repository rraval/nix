require("snacks").setup({
  scratch = {
    ft = function()
      -- \\ opens a global markdown scratch
      -- everything else uses a count-specific filetype-specific scratch
      if vim.v.count1 ~= 1 and vim.bo.buftype == "" and vim.bo.filetype ~= "" then
        return vim.bo.filetype
      end

      return "markdown"
    end,
    filekey = {
      cwd = false,
      branch = false,
      count = true,
    },
    win = {
      keys = {
        q = false,
      },
    },
  },
  indent = {
    enabled = true,
    indent = {
      only_scope = true,
      only_current = true,
    },
    animate = {
      enabled = false,
    },
  },
  scope = {
    enabled = true,
  },
  notifier = {
  },
})
