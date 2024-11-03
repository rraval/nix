{ pkgs, ... }:
{
  home.packages = [
    pkgs.ripgrep  # used by telescope-nvim
  ];

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      camelcasemotion
      coc-nvim
      coc-rust-analyzer
      coc-tslint-plugin
      coc-tsserver
      coffee-script
      copilot-vim
      fugitive
      marks-nvim
      nightfox-nvim
      oil-nvim
      scope-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      typescript-vim
      vim-eunuch
      vim-ledger
      vim-matchup
      vim-nix

      (pkgs.vimUtils.buildVimPlugin {
        name = "arena-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "dzfrias";
          repo = "arena.nvim";
          rev = "9c68cf8afe9665241cb3f7a52c9586095c17d0da";
          hash = "sha256-7u/+DHdipch2oG5geMXxvkwjTNu0HOlN4Oc7aRmSIFM=";
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
      set backupcopy=yes
      set nowrap
      set mouse=
      set tw=0
      set bg=dark
      set scrolloff=5
      set scrolljump=5
      set sidescroll=10
      set showmatch
      set showmode
      set cinoptions=>4,+8,(8,u0
      set number
      set relativenumber
      set signcolumn=auto:3

      " stop autoindenting things as I type
      autocmd FileType python setlocal indentkeys-=<:>
      " align with black code formatting style
      let g:pyindent_open_paren = 'shiftwidth()'
      let g:pyindent_nested_paren = 'shiftwidth()'
      let g:pyindent_continue = 'shiftwidth()'

      autocmd FileType ledger setlocal foldmethod=marker
      autocmd FileType git setlocal foldmethod=syntax

      " refresh files on navigation
      autocmd BufEnter,FocusGained,FocusLost,WinLeave * checktime

      " because Y being yy is stupid
      map Y y$

      " editing commands
      " Ctrl+D for inserting the current buffer's directory for optin relative editing
      cnoremap <expr> <C-d> expand('%:h/') . '/'

      " % takes too many hands to type for a common motion
      nnoremap <C-e> %
      vnoremap <C-e> %
      onoremap <C-e> %

      " kill any trailing whitespace on save
      autocmd BufWritePre * %s/\s\+$//e

      " Jump to last cursor position, see :help last-position-jump
      autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

      " camel case motion
      call camelcasemotion#CreateMotionMappings(',')

      " quickfix
      " automatically put the quickfix window as a fully expanded bottom most split
      autocmd FileType qf wincmd J
      nnoremap <C-J> :cn<CR>
      nnoremap <C-K> :cp<CR>
      " load quickfix from system clipboard
      noremap <Leader>z :cexpr getreg('+')<CR>

      " file navigation / version control
      noremap <Leader>a <cmd>tab split<CR>
      noremap <Leader>g <cmd>Git<CR>
      noremap <Leader>G <cmd>tab Git<CR>
      noremap <Leader>r <cmd>ArenaToggle<CR>

      " terminal shortcuts
      autocmd TermOpen * startinsert
      tnoremap <Esc> <C-\><C-n>

      " coc
      nnoremap <silent> K :call CocActionAsync('doHover')<cr>

      nmap <silent> <Leader>f :call CocAction('format')<cr>

      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)

      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)
      nmap <silent> gw :call coc#float#jump()<cr>

      inoremap <silent><expr> <c-space> coc#refresh()
      nmap <Leader>q <Plug>(coc-codeaction-cursor)

      highlight link CocHintSign Comment

      " scrollbind
      nnoremap <Leader>d :set scb!<CR>:echo 'scb=' . &scb

      " firenvim, firefox integration
      let g:firenvim_config = {
          \ 'localSettings': {
              \ '.*': {
                  \ 'priority': 0,
                  \ 'takeover': 'never',
              \ },
          \ }
      \ }

      " makeprg
      if !empty($NEOVIM_MAKEPRG)
        set makeprg=$NEOVIM_MAKEPRG
      endif

      " fugitive
      " buffers for `G diff` are important!
      autocmd User FugitivePager setlocal bufhidden= buflisted
    '';
    extraLuaConfig = ''
      require("marks").setup()

      require("arena").setup({
        max_items = 10,
      })
      -- Seems to not be coded properly in setup
      require("arena.config").always_context = {
          "mod.rs",
          "init.lua",
          "__init__.py",
          "__test__.py",
          "index.js",
          "index.ts",
          "index.coffee",
          "default.nix",
      }
      -- custom keybinds to quickly switch to a buffer
      for i = 1, 9 do
          require("arena").window.keymaps[tostring(i)] = function(win)
              local target = win:get(i + 1)
              local info = vim.fn.getbufinfo(target.bufnr)[1]
              vim.api.nvim_set_current_buf(target.bufnr)
              vim.fn.cursor(info.lnum, 0)
          end
      end

      require("telescope").setup({
        mappings = {
          i = {
            ["<C-a>"] = "select_all",
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

      require("scope").setup({})
      require("telescope").load_extension("scope")

      vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })
      vim.keymap.set("n", "<Leader>t", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
      vim.keymap.set("n", "<Leader>ff", "<cmd>Telescope live_grep<CR>", { desc = "Find in files" })
      vim.keymap.set("n", "<Leader>fg", "<cmd>Telescope git_branches<CR>", { desc = "Find git branches" })
      vim.keymap.set("n", "<Leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers in current tab" })
      vim.keymap.set("n", "<Leader>fB", "<cmd>Telescope scope buffers<CR>", { desc = "Find buffers in all tabs" })
      vim.keymap.set("n", "<Leader>fm", "<cmd>Telescope marks<CR>", { desc = "Find marks" })

      -- jump to tab by number
      for i = 1, 9 do
        vim.keymap.set("n", "<Leader>" .. i, "" .. i .. "gt<CR>", { desc = "Switch to tab " .. i })
      end

      local oil = require("oil")
      oil.setup()
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

      local function openTerminal(openCmd)
          local bufnr = vim.api.nvim_get_current_buf()
          local buftype = vim.bo[bufnr].buftype
          local filetype = vim.bo[bufnr].filetype

          local bufDir
          if filetype == 'oil' then
              bufDir = oil.get_current_dir(bufnr)
          elseif filetype == 'fugitive' then
              bufDir = vim.fn.fnamemodify(vim.b.git_dir, ':h')
          elseif buftype == 'terminal' then
              _, _, bufDir = string.find(vim.fn.expand('%:p:h'), "term://(.*)//")
          else
              bufDir = vim.fn.expand('%:p:h')
          end

          local shell = os.getenv('SHELL')

          vim.api.nvim_command(string.format('%s term://%s//%s', openCmd, bufDir, shell))
      end

      vim.api.nvim_set_keymap('n', '<Leader>w', "", {
        noremap = true,
        callback = function() openTerminal("vsplit") end,
        desc = "Open terminal in current buffer's directory",
      })

      vim.api.nvim_set_keymap('n', '<Leader>W', "", {
        noremap = true,
        callback = function() openTerminal("tabe") end,
        desc = "Open terminal in current buffer's directory",
      })
    '';
  };

  home.file = {
    ".config/nvim/coc-settings.json".source = ./coc-settings.json;
  };
}
