{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # used by nvim-lspconfig
    basedpyright
    harper
    lua-language-server
    ruff
    rustup
    typescript-language-server
    # used by telescope-nvim
    ripgrep
    # used by codecompanion
    claude-code
    claude-code-acp
  ];

  xdg.configFile."nvim/plugin".source = ./plugin;
  xdg.configFile."nvim/after/plugin/fugitive.lua".source = ./after_plugins/fugitive.lua;

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      actions-preview-nvim
      blink-cmp
      camelcasemotion
      codecompanion-nvim
      coffee-script
      copilot-lua
      diffview-nvim
      firenvim
      flatten-nvim
      fugitive
      grug-far-nvim
      leap-nvim
      marks-nvim
      nightfox-nvim
      nvim-bqf
      nvim-lspconfig
      oil-nvim
      smart-open-nvim
      snacks-nvim
      substitute-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      trouble-nvim
      typescript-vim
      vim-asterisk
      vim-eunuch
      vim-lastplace
      vim-ledger
      vim-matchup
      vim-nix
      zeavim-vim

      (pkgs.vimUtils.buildVimPlugin {
        name = "buffer_manager.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "j-morano";
          repo = "buffer_manager.nvim";
          rev = "03df0142e60cdf3827d270f01ccb36999d5a4e08";
          hash = "sha256-sIkz5jkt+VkZNbiHRB7E+ttcm9XNtDiI/2sTyyYd1gg=";
        };
        doCheck = false; # tests broken under nix build
      })

      (pkgs.vimUtils.buildVimPlugin {
        name = "codecompanion-spinners.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "lalitmee";
          repo = "codecompanion-spinners.nvim";
          rev = "86926cbf7554d69d40d2a5c3cf576063814a42d5";
          hash = "sha256-L+vG4wj2O1VaiHhhjBAi26nglW0WnPSTk8FihkK8cn0=";
        };
      })

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
      set signcolumn=number
      set ignorecase
      set smartcase
      set splitbelow
      set splitright

      " stop autoindenting things as I type
      autocmd FileType python setlocal indentkeys-=<:>

      autocmd FileType ledger setlocal foldmethod=marker
      autocmd FileType git setlocal foldmethod=syntax

      " refresh files on navigation
      autocmd BufEnter,FocusGained,FocusLost,WinLeave * checktime

      " editing commands
      " Ctrl+D for inserting the current buffer's directory for optin relative editing
      cnoremap <expr> <C-d> expand('%:h/') . '/'

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
      noremap <Leader>d <cmd>$tab split<CR>
      noremap <Leader>g <cmd>Git<CR>
      noremap <Leader>G <cmd>DiffviewOpen<CR>

      " terminal shortcuts
      autocmd TermOpen * startinsert
      tnoremap <Esc> <C-\><C-n>

      " fugitive
      " buffers for `G diff` are important!
      autocmd User FugitivePager setlocal bufhidden= buflisted
    '';
    extraLuaConfig = ''
      require("marks").setup()
      require("oil").setup()
      require("trouble").setup()
      require("substitute").setup()
      require("grug-far").setup()
    '';
  };
}
