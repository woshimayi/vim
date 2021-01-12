"======================================================================
"
" asyncrun_extra.vim - extra runners for asyncrun
"
" Created by skywind on 2021/01/11
" Last Modified: 2021/01/11 17:51:21
"
"======================================================================

"----------------------------------------------------------------------
" initialize
"----------------------------------------------------------------------
let g:asyncrun_runner = get(g:, 'asyncrun_runner', {})


"----------------------------------------------------------------------
" floaterm
"----------------------------------------------------------------------
function! s:floaterm_run(opts)
	let cmd = 'FloatermNew '
	" let cmd .= ' --position=bottomright'
	let cmd .= ' --wintype=float'
	" let cmd .= ' --height=0.4'
	" let cmd .= ' --width=0.4'
	" let cmd .= ' --title=' . fnameescape(' Floaterm Runner ')
	let cmd .= ' --autoclose=0'
	let cmd .= ' --silent=' . get(a:opts, 'silent', 0)
	let cwd = (a:opts.cwd == '')? getcwd() : (a:opts.cwd)
	let cmd .= ' --cwd=' . fnameescape(cwd)
	let cmd .= ' ' . a:opts.cmd
	echo cmd
	exec cmd
	if get(a:opts, 'focus', 1) == 0
		" Do not focus on floaterm window, and close it once cursor moves
		" If you want to jump to the floaterm window, use <C-w>p
		" You can choose whether to use the following code or not
		stopinsert | noa wincmd p
		augroup close-floaterm-runner
			autocmd!
			autocmd CursorMoved,InsertEnter * ++nested
						\ call timer_start(100, { -> s:floaterm_close() })
		augroup END
	endif
endfunction

function! s:floaterm_close() abort
	if &ft == 'floaterm' | return | endif
	for b in tabpagebuflist()
		if getbufvar(b, '&ft') == 'floaterm' &&
					\ getbufvar(b, 'floaterm_jobexists') == v:false
			execute b 'bwipeout!'
			break
		endif
	endfor
	autocmd! close-floaterm-runner
endfunction

let g:asyncrun_runner.floaterm = function('s:floaterm_run')


