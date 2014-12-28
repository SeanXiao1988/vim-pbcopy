"
" @file pbcopy.vim
" synopsis  support system clipboard for *nix
" @author 佛丁, xiaol.ghost@gmail.com
" @version 1.0.0
" @date 2014-12-26
"

if exists('g:clipBoardCopy_loaded')
	finish
endif
let g:clipBoardCopy_loaded = 1

if !executable('pbcopy')
	echomsg 'cannot load clipboard copy content, not on a mac ?'
	finish
endif

" Key Mapping
nmap <leader>c :call <SID>Copy('n')<CR>
vmap <leader>c :call <SID>Copy('v')<CR>

function! s:GetVisualSelection()
	" new version for visual selection
	let a_save = @a
	normal! gv"ay
	return shellescape(escape(join(split(@a, "\n"), "\n"), '\'), 1)

	" old version for visual selection
	"let [lnum1, col1] = getpos("'<")[1:2]
	"let [lnum2, col2] = getpos("'>")[1:2]
	"let lines = getline(lnum1, lnum2)
	"let lines[-1] = lines[-1][:col2 - (&selection == 'inclusive' ? 1 : 2)]
	"let lines[0] = lines[0][col1 - 1:]
	"return  join(lines, '\\n')
endfunction

function! s:GetNormalCursorWord()
	return expand("<cword>")
endfunction

function! <SID>Copy(mode)
	let s:copyStr = ''
	if (a:mode == 'n')
		" normal mode call
		let s:copyStr = s:GetNormalCursorWord()
	else
		" visual mode call
		let s:copyStr = s:GetVisualSelection()
	endif
	exe "silent !echo -n " . s:copyStr . " | " . "pbcopy"
	redraw!
endfunction
