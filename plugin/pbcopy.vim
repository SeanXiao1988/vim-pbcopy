"
" @file pbcopy.vim
" synopsis  support system clipboard and grep for *nix
" @author foding, xiaol.ghost@gmail.com
" @version 1.0.0
" @date 2014-12-26
"
if exists('g:copyAndGrepMap_loaded')
	finish
endif
let g:copyAndGrepMap_loaded = 1

if !executable('pbcopy')
	echomsg 'cannot load clipboard copy content, not on a mac ?'
	finish
endif

if !executable('grep')
	echomsg 'cannot load grep command'
	finish
endif

let s:isCopy = 0
let s:isGrep = 0

if !exists('g:copyAndGrepMap_copy')
	let g:copyAndGrepMap_copy = "<leader>c"
endif

if !exists('g:copyAndGrepMap_grep')
	let g:copyAndGrepMap_grep = "<leader>g"
endif

if (!exists('g:copyAndGrepVar_grepInclude') 
			\ || type(g:copyAndGrepVar_grepInclude) !=# type([])
			\ || len(g:copyAndGrepVar_grepInclude) < 1)
	let g:copyAndGrepVar_grepInclude = ['*']
endif

function! s:_copyEscape(str)
	return shellescape(escape(join(split(a:str, "\n"), "\n"), '\'), 1)
endfunction

function! s:_grepEscape(str)
	let str = a:str
	if (!empty(str) && char2nr(str[strlen(str) - 1]) == 10)
		let str = strpart(str, 0, strlen(str) - 1)
	endif
	let lst = [ '\', '/', '^', '$', '"', "'", '!', '|', ]
	if &magic
		let magicLst = [ '*', '.', '~', '[', ']' ]
		call extend(lst, magicLst)
	endif
	for i in lst
		let str = escape(str, i)
	endfor
	let str = "\"". str ."\""
	return str
endfunction

function! s:_getVisualSelection()
	let a_save = @a
	normal! gv"ay
	if s:isCopy
		return s:_copyEscape(@a)
	else
		return s:_grepEscape(@a)
	endif
endfunction

function! s:_getNormalSelection()
	let @a = expand('<cword>')
	if s:isCopy
		return s:_copyEscape(@a)
	else
		return s:_grepEscape(@a)
	endif
endfunction

function! s:_getSelectionWithMode(mode)
	if (a:mode == 'n')
		" normal mode call
		let copyStr = s:_getNormalSelection()
	else
		" visual mode call
		let copyStr = s:_getVisualSelection()
	endif
	return copyStr
endfunction

function! s:_getGrepCommand(mode)
	let copyStr = s:_getSelectionWithMode(a:mode)
	let includeStr = ''
	let commandStr = ''

	for item in g:copyAndGrepVar_grepInclude
		let includeStr .= '--include=' . "\'" . item . "\'" . ' '
	endfor
	let commandStr = commandStr . "silent grep! -R -i -n " . includeStr . copyStr . ' .'
	return commandStr
endfunction

function! <SID>s:Grep(mode)
	let s:isCopy = 0
	let s:isGrep = 1
	let command = s:_getGrepCommand(a:mode)
	exec command
	redraw!
	bot copen
endfunction

function! <SID>s:Copy(mode)
	let s:isCopy = 1
	let s:isGrep = 0
	let copyStr = s:_getSelectionWithMode(a:mode)
	exe "silent !echo -n " . copyStr . " | " . "pbcopy"
	redraw!
endfunction

" Key Mapping
exec 'nmap ' . g:copyAndGrepMap_copy . " :call <SID>s:Copy('n')<CR>"
exec 'vmap ' . g:copyAndGrepMap_copy . " :call <SID>s:Copy('v')<CR>"
exec 'nmap ' . g:copyAndGrepMap_grep . " :call <SID>s:Grep('n')<CR>"
exec 'vmap ' . g:copyAndGrepMap_grep . " :call <SID>s:Grep('v')<CR>"
