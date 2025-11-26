
" ============================================================================
" .vimrc of Minseop Choi
" ============================================================================

set nocompatible

" install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ----------------------------------------------------------------------------
" VIM-PLUG BEGIN
" ----------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')

" theme
Plug 'nanotech/jellybeans.vim'

call plug#end()

" ----------------------------------------------------------------------------
" BASIC SETTINGS
" ----------------------------------------------------------------------------

language messages en_US.UTF-8
set langmenu=en_US.UTF-8
set encoding=utf-8

"English spelling checker.
setlocal spelllang=en_us

colorscheme jellybeans
let g:airline_theme='jellybeans'

set autowrite
set number " show line numbers
set colorcolumn=80 " keep 80 columns.
set cursorline " highlight current cursor line
set hlsearch " highlight search
set ignorecase " ignore case on search
set infercase " adjust case on autocomplete
set scrolloff=5 " cursor offset by lines
set showmatch " show the matched bracket
set matchpairs+=<:> " add match pairs
set linebreak

" tab and indent
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set smarttab
set autoindent
set smartindent

" show tab characters
set list listchars=tab:»\ ,trail:·
