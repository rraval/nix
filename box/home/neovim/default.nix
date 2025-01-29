{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # used by nvim-lspconfig
    lua-language-server
    pyright
    rust-analyzer
    typescript-language-server
    # used by telescope-nvim
    ripgrep
  ];

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      camelcasemotion
      coffee-script
      copilot-vim
      diffview-nvim
      firenvim
      fugitive
      leap-nvim
      marks-nvim
      nightfox-nvim
      nvim-bqf
      nvim-lspconfig
      oil-nvim
      smart-open-nvim
      substitute-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      trouble-nvim
      typescript-vim
      vim-eunuch
      vim-lastplace
      vim-ledger
      vim-matchup
      vim-nix
      zeavim-vim

      (nvim-treesitter.withPlugins (
        p: with p; [
          p.css
          p.fish
          p.html
          p.javascript
          p.json
          p.just
          p.ledger
          p.lua
          p.markdown
          p.nix
          p.python
          p.rust
          p.sql
          p.toml
          p.typescript
          p.vim
          p.vimdoc
          p.xml
        ]
      ))

      (pkgs.vimUtils.buildVimPlugin {
        name = "snacks-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "snacks.nvim";
          rev = "1b7a57a0b14b37a708330a346a767865954ce448";
          hash = "sha256-I/UKCtsLEfRdVWw4Mm+7wq8ESCc38h4ePtsTt7r7/+Q=";
        };
      })
    ];
    extraConfig = ''
      syntax enable
      set background=dark
      colorscheme nightfox

      set softtabstop=4
      set tabstop=4
      set shiftwidth=4
      set expandtab
      set nobackup
      set nowrap
      set mouse=
      set tw=0
      set scrolloff=5
      set scrolljump=5
      set sidescroll=10
      set showmode
      set number
      set relativenumber
      set signcolumn=auto:3
      set ignorecase
      set smartcase

      " stop autoindenting things as I type
      autocmd FileType python setlocal indentkeys-=<:>

      autocmd FileType ledger setlocal foldmethod=marker
      autocmd FileType git setlocal foldmethod=syntax

      " refresh files on navigation
      autocmd BufEnter,FocusGained,FocusLost,WinLeave * checktime

      " editing commands
      " Ctrl+D for inserting the current buffer's directory for optin relative editing
      cnoremap <expr> <C-d> expand('%:h/') . '/'

      " % takes too many hands to type for a common motion
      nnoremap <C-e> %
      vnoremap <C-e> %
      onoremap <C-e> %

      " kill any trailing whitespace on save
      autocmd BufWritePre * %s/\s\+$//e

      " camel case motion
      call camelcasemotion#CreateMotionMappings(',')

      " quickfix
      " automatically put the quickfix window as a fully expanded bottom most split
      autocmd FileType qf wincmd J
      nnoremap <C-J> :cn<CR>
      nnoremap <C-K> :cp<CR>

      " file navigation / version control
      noremap <Leader>a <cmd>tab split<CR>
      noremap <Leader>g <cmd>Git<CR>
      noremap <Leader>G <cmd>DiffviewOpen<CR>

      " terminal shortcuts
      autocmd TermOpen * startinsert
      tnoremap <Esc> <C-\><C-n>

      " scrollbind
      nnoremap <Leader>d :set scb!<CR>:echo 'scb=' . &scb

      " fugitive
      " buffers for `G diff` are important!
      autocmd User FugitivePager setlocal bufhidden= buflisted
    '';
    extraLuaConfig = ''
      -- use 2 space indents for specific filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"lua", "nix", "yaml"},
        callback = function()
          vim.bo.tabstop = 2
          vim.bo.softtabstop = 2
          vim.bo.shiftwidth = 2
        end,
      })

      require("marks").setup()

      vim.keymap.set('n', '<Leader>s', '<Plug>(leap)')
      vim.keymap.set('n', '<Leader>S', '<Plug>(leap-from-window)')
      vim.keymap.set({'x', 'o'}, '<Leader>s', '<Plug>(leap-forward)')
      vim.keymap.set({'x', 'o'}, '<Leader>S', '<Plug>(leap-backward)')

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

      vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })
      vim.keymap.set("n", "<Leader>r", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
      vim.keymap.set("n", "<Leader>t", function()
        require("telescope").extensions.smart_open.smart_open({
          cwd_only = true,
          filename_first = false,
        })
      end, { noremap = true, silent = true, desc = "Smart Open" })
      vim.keymap.set("n", "<Leader>ff", "<cmd>Telescope live_grep<CR>", { desc = "Find in files" })
      vim.keymap.set("n", "<Leader>fg", "<cmd>Telescope git_branches<CR>", { desc = "Find git branches" })
      vim.keymap.set("n", "<Leader>fm", "<cmd>Telescope marks<CR>", { desc = "Find marks" })

      -- jump to tab by number
      for i = 1, 9 do
        vim.keymap.set("n", "<Leader>" .. i, "" .. i .. "gt<CR>", { desc = "Switch to tab " .. i })
      end

      local oil = require("oil")
      oil.setup()
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

      require("bqf").setup({
        preview = {
          auto_preview = false,
        },
      })

      local function currentBufDir()
          local bufnr = vim.api.nvim_get_current_buf()
          local buftype = vim.bo[bufnr].buftype
          local filetype = vim.bo[bufnr].filetype

          local bufDir
          if filetype == 'oil' then
              return oil.get_current_dir(bufnr)
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

      -- firenvim, firefox integration
      if vim.g.started_by_firenvim == true then
        vim.g.firenvim_config = {
          localSettings = {
              ['.*'] = {
                takeover = 'never',
                priority = 0,
              },
          },
        }

        vim.o.guifont = 'monospace:h10'

        vim.api.nvim_create_autocmd({'BufEnter'}, {
            pattern = "github.com_*.txt",
            command = "set filetype=markdown"
        })
      end

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
      })
      vim.api.nvim_set_keymap('n', '<Leader><Leader>', "", {
        noremap = true,
        callback = function() Snacks.scratch() end,
        desc = "Toggle Scratch Buffer",
      })

      local lspconfig = require("lspconfig")

      lspconfig.pyright.setup({
        on_new_config = function(new_config, new_root_dir)
          -- poetry integration with local .venv directories
          local pythonPath = new_root_dir .. "/.venv/bin/python"
          if vim.fn.filereadable(pythonPath) then
            new_config.settings.python.pythonPath = pythonPath
          end
        end,
      })

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

      require("trouble").setup()
      vim.api.nvim_set_keymap('n', '<Leader>x', "<cmd>Trouble diagnostics toggle<cr>", {
        noremap = true,
        desc = "Diagnostics (Trouble)",
      })

      require("nvim-treesitter").setup()
      require("nvim-treesitter.configs").setup({
        ensure_installed = false,
        auto_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            node_incremental = "<Space>",
            scope_incremental = "<C-Space>",
            node_decremental = "<BS>",
          },
        },
      })

      require("substitute").setup()
      vim.keymap.set("n", "s", require('substitute').operator, { noremap = true })
      vim.keymap.set("n", "ss", require('substitute').line, { noremap = true })
      vim.keymap.set("n", "S", require('substitute').eol, { noremap = true })
      vim.keymap.set("x", "s", require('substitute').visual, { noremap = true })

      vim.api.nvim_create_autocmd({ 'TermRequest' }, {
        desc = 'Set `path` based on terminal cwd',
        callback = function(ev)
          if string.sub(vim.v.termrequest, 1, 4) == '\x1b]7;' then
            local dir = string.gsub(vim.v.termrequest, '\x1b]7;file://[^/]*', "")
            if vim.fn.isdirectory(dir) then
              vim.bo.path = dir
            end
          end
        end
      })

      vim.api.nvim_set_keymap('n', '<C-g>', "<C-W>F", {
        desc = "Goto file line under cursor in split",
      })

      -- zeal
      vim.g.zv_file_types = {
        help = 'vim',
        javascript = 'javascript,nodejs',
        python = 'python_3',
      }

      -- Check if an adjacent file exists and load it
      local function load_adjacent_file(file_name)
        local full_path = vim.fn.stdpath("config") .. "/" .. file_name
        local file_exists = vim.loop.fs_stat(full_path) ~= nil

        if file_exists then
          vim.notify("Loading " .. file_name, vim.log.levels.INFO)
          dofile(full_path)
        end
      end

      -- Attempt to load an adjacent configuration file
      load_adjacent_file("local.lua")
    '';
  };
}
