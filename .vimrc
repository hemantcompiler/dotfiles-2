" __          __   _  __     _             _
" \ \        / /  | |/ _|   ( )           (_)
"  \ \  /\  / /__ | | |_ ___|/ ___  __   ___ _ __ ___  _ __ ___
"   \ \/  \/ / _ \| |  _/ _ \ / __| \ \ / / | '_ ` _ \| '__/ __|
"    \  /\  / (_) | | ||  __/ \__ \  \ V /| | | | | | | | | (__
"     \/  \/ \___/|_|_| \___| |___/ (_)_/ |_|_| |_| |_|_|  \___|


set clipboard=exclude:.*      " Improve startup time by ignoring x server clipboard
set foldmethod=marker         " Enables marker folding for this file
set nocompatible              " be iMproved, required

" Vim Plug {{{

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'suan/vim-instant-markdown'
Plug 'godlygeek/tabular'
Plug 'mattn/webapi-vim'
Plug 'mattn/gist-vim'
Plug 'WolfeCub/markdown-format-vim'
Plug 'terryma/vim-expand-region'
Plug 'scrooloose/syntastic'
Plug 'SirVer/ultisnips'
Plug 'Shougo/neocomplete.vim'

call plug#end()

" }}}

" Basic Configuration {{{

set tabstop=8
set softtabstop=0
set expandtab
set shiftwidth=4
set smarttab
set hlsearch
set laststatus=2     " Displays statusline by default
set backspace=2      " Allows for free backspacing
set incsearch	     " incremental search
set wildchar=<TAB>   " start wild expansion in the command line using <TAB>
set wildmenu         " wild char completion menu
set ignorecase       " case insensitive matching
set smartcase        " smartcase matching
set showmatch        " show matching brackets when text indicator is over them
set timeoutlen=1000 ttimeoutlen=0

" }}}

" Custom Configuration {{{

" Use :W to sudo write file
command! W w !sudo tee % > /dev/null

" Adds the :Shell command to execute a command via the shell and place the
" result in a buffer
function! s:ExecuteInShell(command)
	let command = join(map(split(a:command), 'expand(v:val)'))
	let winnr = bufwinnr('^' . command . '$')
	silent! execute  winnr < 0 ? 'botright new ' . fnameescape(command) : winnr . 'wincmd w'
	setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
	echo 'Execute ' . command . '...'
	silent! execute 'silent %!'. command
	silent! execute 'resize ' . line('$')
	silent! redraw
	silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
	silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . command . ''')<CR>'
	echo 'Shell command ' . command . ' executed.'
endfunction
command! -complete=shellcmd -nargs=+ Shell call s:ExecuteInShell(<q-args>)

" }}}

" Custom Keybinds {{{

let g:mapleader = "\<Space>"

" Make j and k behave like they should for wrapped lines
nnoremap j gj
nnoremap k gk
" Fast saving
nnoremap <leader>w :<C-u>update<cr>
" Spellcheck
noremap <leader>ss :setlocal spell!<cr>
" Ctrl+A goes to the beginning of the command line
cnoremap <C-A>	<Home>
" Ctrl+E goes to the end of the command line
cnoremap <C-E>	<End>
" Toggle folds
nnoremap <Tab> za
" Source current file
nnoremap <leader>so :source %<cr>
" Source current line
nnoremap <leader>S ^vg_y:execute @@<cr>
" Source visual selection
vnoremap <leader>S y:execute @@<cr>
" Remove search highlights
nnoremap <leader><leader> :set hlsearch! hlsearch?<cr>

" }}}

" Visual Configuration {{{

set relativenumber
set number
set background=dark
colorscheme gruvbox
let g:gruvbox_contrast_dark='hard'
syntax enable
set t_Co=256
filetype on
set showmatch

if $TERM_PROGRAM =~ "iTerm"
	let &t_SI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
	let &t_EI = "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
endif

" }}}

" Plugin Configs {{{

" Keybinds for Markdown Format
nnoremap <leader>h1 :MakeHeader 1<cr>
nnoremap <leader>h2 :MakeHeader 2<cr>
nnoremap <leader>h3 :MakeHeader 3<cr>
nnoremap <leader>h4 :MakeHeader 4<cr>
nnoremap <leader>h5 :MakeHeader 5<cr>
nnoremap <leader>h6 :MakeHeader 6<cr>
vnoremap <leader>l1 :<C-u>MakeListOne<cr>
vnoremap <leader>l2 :<C-u>MakeListTwo<cr>
vnoremap <leader>nl :<C-u>MakeNumberedList<cr>
vnoremap <leader>cb :<C-u>FencedCodeBlock<cr>

let g:airline_powerline_fonts = 1 " Sets the powerline font to work properly

" Gist clipboard access
let g:gist_clip_command = 'pbcopy'
" Gist detect filetype
let g:gist_detect_filetype = 1
" Open browser after post
let g:gist_open_browser_after_post = 1

" Change default ctrlp binding
let g:ctrlp_map = '<leader>p'

"Set up syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"Have syntastic use Python 3 for syntax checking
let g:syntastic_python_python_exec = '/usr/local/bin/python3'

" Trigger configuration. Do not use <tab> if you use
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"

" Configuration for Neocomplete
" Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
" End of neocomplete setup

" }}}

" Temp & Testing {{{

" To improve vim habits
" Unbind the cursor keys in insert, normal and visual modes.
for prefix in ['i', 'n', 'v']
	for key in ['<Up>', '<Down>', '<Left>', '<Right>']
		exe prefix . "noremap " . key . " <Nop>"
	endfor
endfor

function! GetSyntaxID()
    return synID(line('.'), col('.'), 1)
endfunction

function! GetSyntaxParentID()
    return synIDtrans(GetSyntaxID())
endfunction

function! GetSyntax()
    echo synIDattr(GetSyntaxID(), 'name')
    exec "hi ".synIDattr(GetSyntaxParentID(), 'name')
endfunction

" }}}

