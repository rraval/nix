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
      noremap <Leader>g <cmd>tab Git<CR>
      noremap <Leader>r <cmd>ArenaToggle<CR>
      noremap <Leader>t <cmd>Telescope find_files<CR>
      noremap <Leader>ff <cmd>Telescope live_grep<CR>
      noremap <Leader>fg <cmd>Telescope git_branches<CR>
      noremap <Leader>fb <cmd>Telescope buffers<CR>
      noremap <Leader>fm <cmd>Telescope marks<CR>

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

      require("marks").setup()

      local oil = require("oil")
      oil.setup()
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })


      local function openTerminal()
          local bufnr = vim.api.nvim_get_current_buf()
          local fileType = vim.bo[bufnr].filetype

          local bufDir
          if fileType == 'oil' then
              bufDir = oil.get_current_dir(bufnr)
          elseif fileType == 'fugitive' then
              bufDir = vim.fn.fnamemodify(vim.b.git_dir, ':h')
          else
              bufDir = vim.fn.expand('%:p:h')
          end

          local shell = os.getenv('SHELL')

          vim.api.nvim_command(string.format('vsplit term://%s//%s', bufDir, shell))
      end

      vim.api.nvim_set_keymap('n', '<Leader>w', "", {
        noremap = true,
        callback = openTerminal,
        desc = "Open terminal in current buffer's directory",
      })
    '';
  };

  home.file = {
    ".config/nvim/coc-settings.json".source = ./coc-settings.json;
  };
}
