set encoding=utf-8
if &shell =~# 'fish$'
    set shell=sh
endif
set nocompatible              " be iMproved, required
" filetype off                  " required
" set termguicolors
syn on

" set completeopt=longest,menuone
" set dictionary?
" set dictionary+=/usr/share/hunspell

set relativenumber 



" Allow enabling by running the command ":Freeform", or <leader>sw
command! Softwrap :call SetupSoftwrap()
command! Freeform :call SetupFreeform()
map <Leader>sw :call SetupSoftwrap() <CR>

func! SetupFreeform()
  " Use setlocal for all of these so they don't affect other buffers

  " Enable line wrapping.
  setlocal wrap
  " Only break at words.
  setlocal linebreak
  " Turn on spellchecking
  setlocal spell

  " Make jk and 0$ work on visual lines.
  nnoremap <buffer> j gj
  nnoremap <buffer> k gk
  nnoremap <buffer> 0 g0
  nnoremap <buffer> $ g$

  " Disable colorcolumn, in case you use it as a column-width indicator
  " I use: let &colorcolumn = join(range(101, 300), ",")
  " so this overrides that.
  setlocal colorcolumn=

  " cursorline and cursorcolumn don't work as well in wrap mode, so
  " you may want to disable them. cursorline highlights the whole line,
  " so if you write a whole paragraph on a single line, the whole
  " paragraph will be highlighted. cursorcolumn only highlights the actual
  " column number, not the visual line, so the highlighting will be broken
  " up on wrapped lines.
  setlocal nocursorline
  setlocal nocursorcolumn
endfunc


let mapleader = ","
set showcmd
let custprofdir = "$HOME/.dotfiles"


let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

if has('nvim')
  Plug 'github/copilot.vim'
endif
Plug 'jiangmiao/auto-pairs'
Plug 'dense-analysis/ale'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
":Plugin 'maxbrunsfeld/vim-yankstack'
" Plugin 'mileszs/ack.vim'
" Plugin 'jlanzarotta/bufexplorer'
" Plugin 'ctrlpvim/ctrlp.vim'
" Plugin 'vim-scripts/mayansmoke'
Plug 'scrooloose/nerdtree'
" Plugin 'chr4/nginx.vim'
" Plugin 'amix/open_file_under_cursor.vim'
" Plugin 'MarcWeber/vim-addon-mw-utils'
" Plugin 'sophacles/vim-bundle-mako'
" Plugin 'kchmck/vim-coffee-script'
" Plugin 'altercation/vim-colors-solarized'
" Plugin 'michaeljsmith/vim-indent-object'
" Plugin 'groenewege/vim-less'
" Plugin 'therubymug/vim-pyte'
" Plugin 'garbas/vim-snipmate'
" Plugin 'honza/vim-snippets'
Plug 'tpope/vim-surround'
" Plugin 'terryma/vim-expand-region'
" Plugin 'terryma/vim-multiple-cursors'
" Plugin 'tpope/vim-fugitive'
" Plugin 'junegunn/goyo.vim'
" Plugin 'amix/vim-zenroom2'
" Plugin 'tpope/vim-repeat'
" Plug 'tpope/vim-commentary'
" Plugin 'airblade/vim-gitgutter'
" Plugin 'morhetz/gruvbox'
" Plugin 'nvie/vim-flake8'
" Plugin 'digitaltoad/vim-pug'
" Plugin 'itchyny/lightline.vim'
" Plugin 'maximbaz/lightline-ale'
" Plugin 'tpope/tpope-vim-abolish'
" Plugin 'rust-lang/rust.vim'
" Plugin 'godlygeek/tabular'
" Plugin 'preservim/vim-markdown'
" Plug 'plasticboy/vim-markdown'
" Plugin 'mattn/vim-gist'
" Plugin 'vim-ruby/vim-ruby'
" Plugin 'leafgarland/typescript-vim'
" Plugin 'pangloss/vim-javascript'
" Plugin 'Vimjas/vim-python-pep8-indent'

" Plugin 'PProvost/vim-ps1'
Plug 'khaveesh/vim-fish-syntax'
Plug 'rafi/awesome-vim-colorschemes'
" Plug 'sainnhe/vim-color-forest-night'
" Plugin 'vim-syntastic/syntastic'
Plug 'Shougo/ddc.vim'
" Plug 'Shougo/ddc-ui-native'
Plug 'vim-denops/denops.vim'

" Plug 'Shougo/pum.vim'

Plug 'Shougo/ddc-ui-native'
" Plug 'Shougo/ddc-ui-pum'
Plug 'Shougo/ddc-mocword'

Plug 'Shougo/ddc-matcher_head'
Plug 'Shougo/ddc-sorter_rank'
Plug 'Shougo/ddc-around'
Plug 'Shougo/ddc-cmdline'
Plug 'Shougo/neco-vim'

Plug 'statiolake/ddc-ale'
Plug 'LumaKernel/ddc-file'
Plug 'Shougo/ddc-omni'
" You Complete Me
" Plugin 'ycm-core/YouCompleteMe'
call plug#end()




" set omnifunc=syntaxcmplete#Complete
" set omnifunc=ale#completion#OmniFunc

" execute 'source' custprofdir . '/basic.vim'
" execute 'source' custprofdir . '/filetypes.vim'
" execute 'source' custprofdir . '/plugins_config.vim'
" execute 'source' custprofdir . '/extended.vim'
let g:sierra_Nevada = 1
colorscheme sierra 
" source ~/.dotfiles/basic.vim
" source "$HOME/.dotfiles/filetypes.vim"
" source ~/.dotfiles/plugins_config.vim
" source ~/.dotfiles/extended.vim

execute 'source' custprofdir . '/my_configs.vim'
" try
"     execute 'source' custprofdir . '/my_configs.vim'
" catch
" endtry

" set term=screen-256color
if !has('nvim')
    set ttymouse=xterm2
endif

set mouse=a
set number

call ddc#enable()
" ## added by OPAM user-setup for vim / base ## 93ee63e278bdfc07d1139a748ed3fff2 ## you can edit, but keep this line
let s:opam_share_dir = system("opam config var share")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

let s:opam_configuration = {}

function! OpamConfOcpIndent()
  execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
endfunction
let s:opam_configuration['ocp-indent'] = function('OpamConfOcpIndent')

function! OpamConfOcpIndex()
  execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"
endfunction
let s:opam_configuration['ocp-index'] = function('OpamConfOcpIndex')

function! OpamConfMerlin()
  let l:dir = s:opam_share_dir . "/merlin/vim"
  execute "set rtp+=" . l:dir
endfunction
let s:opam_configuration['merlin'] = function('OpamConfMerlin')

let s:opam_packages = ["ocp-indent", "ocp-index", "merlin"]
let s:opam_check_cmdline = ["opam list --installed --short --safe --color=never"] + s:opam_packages
let s:opam_available_tools = split(system(join(s:opam_check_cmdline)))
for tool in s:opam_packages
  " Respect package order (merlin should be after ocp-index)
  if count(s:opam_available_tools, tool) > 0
    call s:opam_configuration[tool]()
  endif
endfor
" ## end of OPAM user-setup addition for vim / base ## keep this line
" ## added by OPAM user-setup for vim / ocp-indent ## 0ff998cb10c19473d2845ab278449637 ## you can edit, but keep this line
if count(s:opam_available_tools,"ocp-indent") == 0
  source "/Users/np/.opam/default/share/ocp-indent/vim/indent/ocaml.vim"
endif
" ## end of OPAM user-setup addition for vim / ocp-indent ## keep this line
