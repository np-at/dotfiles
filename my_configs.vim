" mimic IDE intellisense behavior (cntl+space brings up suggestions)
" inoremap <C-space> <C-x><C-o>

" inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" inoremap <expr> <C-p> pumvisible() ? '<C-n>' :
"   \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
" inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
"   \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'    

" we want recursive mapping here to enable <C-,> in insert mode to replace leader
imap <silent><C-,> <leader>


" inoremap <silent><C-,> <leader>
if has('win32')
    nmap <C-/> <leader>c<Space>
    vmap <C-/> <leader>c<Space>
else
    nmap <C-_> <leader>c<Space>
    vmap <C-_> <leader>c<Space>
endif

" inoremap <expr><C-space> ddc#map#can_complete() ? ddc#map#complete() : '<C-space>'
call ddc#custom#patch_global('ui','native')
" call ddc#custom#patch_global('completionMenu','pum.vim')
" call ddc#custom#patch_global('completionMode','popupmenu')
"""""""""""""""""""""""""""""""""""""""""
" pum.vim bindings
"
""""""""""""""""""""""""""""

" <TAB>: completion.
inoremap <silent><expr> <TAB> pumvisible() ? '<C-n>' :  (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ? '<TAB>' : ddc#map#manual_complete()

inoremap <expr><TAB> pumvisible() ? pum#map#select_relative(+1) :  '<TAB>'

" <S-TAB>: completion back

inoremap <expr><S-TAB> pumvisible() ? pum#map#select_relative(-1) :  '<S-TAB>'

" <CR>: Select completion item if pum visible
"
inoremap <expr><CR> pumvisible() ? pum#map#confirm() : '<CR>'


" Up/Down + j /k Key bindings for pum.vim menu selection
" inoremap <expr><Down> pumvisible() ? pum#map#select_relative(+1) : '<Down>'
" inoremap <expr><Up> pumvisible() ? pum#map#select_relative(-1) : '<Up>'
" imap <expr><Down> pumvisible() ? pum#map#cancel() : '<Down>'



inoremap <expr><Up> pumvisible() ? ( pum#complete_info().selected >= 0 ? pum#map#select_relative(-1) : pum#map#cancel() ) : '<Up>'
inoremap <expr><Down> pumvisible() ? ( pum#complete_info().selected >= 0 ? pum#map#select_relative(+1) : pum#map#cancel() ) : '<Down>'



inoremap <expr>j pumvisible() ? pum#map#select_relative(-1) : 'j'
inoremap <expr>k pumvisible() ? pum#map#select_relative(+1) : 'k'

" <Esc>: cancels out of completion menu first
" (not using due to current bug where pum#map#cancel() has a massive delay before executing
" inoremap <expr><Esc> pumvisible() ? pum#map#cancel() : '<Esc>'


inoremap <expr><PageDown> pumvisible() ? pum#map#select_relative_page(+1) : '<PageDown>'
inoremap <expr><PageUp> pumvisible() ? pum#map#select_relative_page(-1) : '<PageUp>'


" inoremap <silent><expr><C-space> pum#visible() ? 'aa' : ddc#map#manual_complete(['ale'])
" keep priority low for spelling / mocword
call ddc#custom#patch_global('sources', ['ale'])
call ddc#custom#patch_global('sourceOptions', {
    \ 'mocword': {
    \   'minAutoCompleteLength': 3,
    \   'isVolatile': v:true,
    \   'maxItems': 40
    \   },
    \ 'ale': {
      \   'minAutoCompleteLength': 2,
      \  'isVolatile': v:false
      \   }
      \ }
      \)
call ddc#custom#patch_global('sourceParams', {'ale': {'cleanResultsWhitespace': v:false}})
" Customize global settings
" Use around source.
" https://github.com/Shougo/ddc-around
" call ddc#custom#patch_global('sources', ['around','ale'])
" call ddc#custom#patch_global('sources', ['ale'])

" Use matcher_head and sorter_rank.
"  https://github.com/Shougo/ddc-matcher_head
"  https://github.com/Shougo/ddc-sorter_rank
call ddc#custom#patch_global('sourceOptions', {
       \ '_': {
       \   'matchers': ['matcher_head'],
       \   'sorters': ['sorter_rank']
       \ }
       \ })

" Change source options
call ddc#custom#patch_global('sourceOptions', {
      \ 'around': {'mark': 'ar'},
      \ })
call ddc#custom#patch_global('sourceParams', {
      \ 'around': {'maxSize': 500},
      \ })

" Customize settings on a filetype
call ddc#custom#patch_filetype(['c', 'cpp'], 'sources', ['around', 'clangd'])
call ddc#custom#patch_filetype(['c', 'cpp'], 'sourceOptions', {
      \ 'clangd': {'mark': 'C'},
      \ })

call ddc#custom#patch_filetype(['sh'],'sources', ['ale','cmdline','file'])
call ddc#custom#patch_filetype(['sh'],'sourceOptions', { 
    \ 'cmdline': {
      \ 'mark': 'cmd',
    \ }
    \  })

call ddc#custom#patch_filetype('markdown','sources', ['ale','mocword'])
call ddc#custom#patch_filetype('markdown', 'sourceParams', {
      \ 'around': {'maxItems': 4},
      \ })
" call ddc#custom#patch_filetype(['css'],'sources',['ale'])

"""""""""""""""""""""""""""""""'
" ddc-file config (https://github.com/LumaKernel/ddc-file)
""""""""""""""""""""""""
call ddc#custom#patch_filetype(['ps1','dosbatch','autohotkey','registry','py',''],'sources', ['file'])
call ddc#custom#patch_global('sourceOptions', {
    \ 'file': {
    \   'mark': 'F',
    \   'isVolatile': v:true,
    \   'forceCompletionPattern': '\S/\S*',
    \ }})
call ddc#custom#patch_filetype(
    \ ['ps1', 'dosbatch', 'autohotkey', 'registry'], {
    \ 'sourceOptions': {
    \   'file': {
    \     'forceCompletionPattern': '\S\\\S*',
    \   },
    \ },
    \ 'sourceParams': {
    \   'file': {
    \     'mode': 'win32',
    \   },
    \ }})
call ddc#custom#patch_global('backspaceCompletion','v:true')

call ddc#custom#patch_filetype(
	    \ ['vim', 'toml'], 'sources', ['necovim'])
" 	call ddc#custom#patch_global('sourceOptions', {
" 	    \ '_': {
" 	    \   'matchers': ['matcher_head'],
" 	    \   'sorters': ['sorter_rank']
" 	    \ },
" 	    \ 'necovim': {'mark': 'vim'},
" 	    \ })

call ddc#custom#patch_filetype('css','sources',['ale'])


call ddc#custom#patch_filetype('Makefile','sources',['mocword','file'])
" Use ddc.





augroup AutoSaveFolds
  autocmd!
  autocmd BufWinLeave ?* mkview 1
  autocmd BufWinEnter ?* silent! loadview 1
augroup END

""""""""""""
" Ale
"
"""""""""""""
let g:ale_set_balloons = 1
" 
" let g:ale_completion_enabled = 1
" let g:ale_completion_enabled = 0

" let g:ale_hover_to_preview = 1
"" easy way to toggle Ale on and off
noremap <leader>a <Cmd>ALEToggle<CR>


let g:ale_fixers = {
  \   'markdown': ['pandoc'],
  \   'css':['stylelint','prettier']
  \}
" use airline status bar for error messages
let g:airline#extensions#ale#enabled = 1

" let g:ale_sign_error = '>>'
" let g:ale_sign_warning = '--'

highlight ALEWarning ctermbg=Brown
highlight ALEError ctermbg=LightCyan
" let g:ale_virtualtext_cursor = 1
call ale#Set('markdown_markdownlint_options','-r ~MD013')

call ale#Set('markdown_mdl_options','-r ~MD013')



""""""""""""
" Airline
" 
""""""""""""
let g:airline_theme='luna'


let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

