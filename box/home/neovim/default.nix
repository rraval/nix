{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      bufexplorer
      camelcasemotion
      coc-nvim
      coc-rust-analyzer
      coc-tslint-plugin
      coc-tsserver
      coffee-script
      fugitive
      fzf-vim
      nightfox-nvim
      oil-nvim
      typescript-vim
      vim-eunuch
      vim-ledger
      vim-matchup
      vim-nix
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
      noremap <Leader>a :tab split<CR>
      noremap <Leader>e :Lines<CR>
      noremap <Leader>r :Buffers<CR>
      noremap <Leader>t :GFiles<CR>
      noremap <Leader>g :tab Git<CR>

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

      " bufexplorer
      let g:bufExplorerDefaultHelp=0       " Do not show default help.
      let g:bufExplorerShowDirectories=0   " Do not show directories.

      " fugitive
      " buffers for `G diff` are important!
      autocmd User FugitivePager setlocal bufhidden= buflisted
    '';
    extraLuaConfig = ''
      require("oil").setup()
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    '';
  };

  home.file = {
    ".config/nvim/coc-settings.json".source = ./coc-settings.json;
  };
}
