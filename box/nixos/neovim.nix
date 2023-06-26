{ pkgs, ... }: {
  enable = true;
  plugins = with pkgs.vimPlugins; [
    camelcasemotion
    coc-nvim
    coc-rust-analyzer
    coc-tslint-plugin
    coc-tsserver
    coffee-script
    fugitive
    fzf-vim
    solarized
    splice-vim
    typescript-vim
    vim-ledger
    vim-nix
  ];
  extraConfig = ''
    syntax enable
    set background=dark

    autocmd VimEnter,ColorScheme * call ExtendColorScheme()
    function ExtendColorScheme()
      hi! Pmenu ctermfg=0 ctermbg=15
      hi! link CocInlayHint CocHintSign
      hi! link CocSearch CocUnderline
      hi! link CocFloating Pmenu
      hi! link CocMenuSel PmenuSel

      hi! Folded ctermfg=0 ctermbg=13
    endfunction

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

    " because Y being yy is stupid
    map Y y$

    " editing commands
    " Ctrl+D for inserting the current buffer's directory for optin relative editing
    cnoremap <expr> <C-d> expand('%:h/') . '/'

    " kill any trailing whitespace on save
    autocmd BufWritePre * %s/\s\+$//e

    " Jump to last cursor position, see :help last-position-jump
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

    " Fold diffs inside fugitive commit windows
    autocmd FileType git set foldmethod=syntax

    " netrw can go die in a fire
    let g:loaded_netrw = 1
    let g:loaded_netrwPlugin = 1

    " splice
    let g:splice_prefix = ","

    " camel case motion
    call camelcasemotion#CreateMotionMappings(',')

    " quickfix
    " automatically put the quickfix window as a fully expanded bottom most split
    autocmd FileType qf wincmd J
    nnoremap <C-J> :cn<CR>
    nnoremap <C-K> :cp<CR>

    " file navigation / version control
    noremap <Leader>a :tab split<CR>
    noremap <Leader>t :GFiles<CR>
    noremap <Leader>r :Buffers<CR>
    noremap <Leader>g :vert Git<CR>

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

    " terminal
    nnoremap <Leader>w :terminal<CR>
    autocmd BufEnter term://* startinsert
    tnoremap <Esc> <C-\><C-n>
    tnoremap <A-h> <C-\><C-n><C-w>h
    tnoremap <A-j> <C-\><C-n><C-w>j
    tnoremap <A-k> <C-\><C-n><C-w>k
    tnoremap <A-l> <C-\><C-n><C-w>l
    nnoremap <A-h> <C-w>h
    nnoremap <A-j> <C-w>j
    nnoremap <A-k> <C-w>k
    nnoremap <A-l> <C-w>l

    " scrollbind
    nnoremap <Leader>d :set scb!<CR>:echo 'scb=' . &scb

    " arc
    function ArcRefTask()
      let l:ref = system('git show -s --format=%B HEAD^ | grep "^Ref"')
      put =l:ref
    endfunction

    function ArcDependsOnDiff()
      let l:commit_message = system('git show -s --format=%B HEAD^ | grep "^Differential Revision:"')
      let l:diff = matchlist(l:commit_message, '/\([^/]\+\)$')[1]
      let l:ref = 'Depends on ' . l:diff . '.'
      put =l:ref
    endfunction

    nnoremap <Leader>z :cexpr system("arc lint --output=compiler")<CR>
    nnoremap <Leader>x :call ArcRefTask()<CR>
    nnoremap <Leader>c :call ArcDependsOnDiff()<CR>

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
  '';
}
