"
" @file pbcopy.vim
" synopsis  support system clipboard for *nix
" @author 佛丁, xiaol.ghost@gmail.com
" @version 1.0.0
" @date 2014-12-26
"

" For more infomation, use ":help pbcopy" command

if exists('g:clipBoardCopy_loaded')
	finish
endif
let g:clipBoardCopy_loaded = 1

if !executable('pbcopy') || !executable('textutil')
	echomsg 'cannot load clipboard copy content, not on a mac ?'
	finish
endif

" Key Mapping
vmap <Plug>ClipBoardCopyPlug :call <SID>ClipBoardCopy()
if (!hasmapto( '<Plug>ClipBoardCopyPlug', 'v'))
	vmap <leader>c <Plug>ClipBoardCopyPlug<CR>
endif

function! s:getVisualSelection()
	let [lnum1, col1] = getpos("'<")[1:2]
	let [lnum2, col2] = getpos("'>")[1:2]
	let lines = getline(lnum1, lnum2)
	let lines[-1] = lines[-1][:col2 - (&selection == 'inclusive' ? 1 : 2)]
	let lines[0] = lines[0][col1 - 1:]
	return join(lines, '\\n')
endfunction

function! <SID>ClipBoardCopy()
	let s:copyStr = s:getVisualSelection()
	exe 'silent !echo -n ' . s:copyStr . ' | ' . 'pbcopy'
	redraw!
endfunction
