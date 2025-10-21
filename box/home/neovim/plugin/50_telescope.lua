local function leapGetTargets (buf)
  local pick = require('telescope.actions.state').get_current_picker(buf)
  local scroller = require('telescope.pickers.scroller')
  local wininfo = vim.fn.getwininfo(pick.results_win)[1]
  local top = math.max(
    scroller.top(pick.sorting_strategy, pick.max_results, pick.manager:num_results()),
    wininfo.topline - 1
  )
  local bottom = wininfo.botline - 2  -- skip the current row
  local targets = {}
  for lnum = bottom, top, -1 do  -- start labeling from the closest (bottom) row
    table.insert(targets, { wininfo = wininfo, pos = { lnum + 1, 1 }, pick = pick, })
  end
  return targets
end

local function leapPick (buf)
  require('leap').leap {
    targets = function () return leapGetTargets(buf) end,
    action = function (target)
      target.pick:set_selection(target.pos[1] - 1)
      require('telescope.actions').select_default(buf)
    end,
  }
end

require("telescope").setup({
  defaults = {
    mappings = {
      n = {
      },
      i = {
        ["<C-s>"] = "select_all",
        ["<C-f>"] = leapPick,
      },
    },
    vimgrep_arguments = {
      -- defaults, see :h telescope.defaults.vimgrep_arguments
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      -- my additions
      "--glob", "!.git/**",
      "--hidden",
    },
  },
  pickers = {
    find_files = {
      file_ignore_patterns = { '^.git/' },
      hidden = true,
    },
    buffers = {
      mappings = {
        i = {
          ["<C-d>"] = "delete_buffer",
        },
      },
    },
  },
})
require("telescope").load_extension("fzf")
require("telescope").load_extension("smart_open")
