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
	let cmd .= ' --wintype=float'
	if has_key(a:opts, 'floatpos') 
		let cmd .= ' --position=' . fnameescape(a:opts.floatpos)
	endif
	if has_key(a:opts, 'width')
		let cmd .= ' --width=' . fnameescape(a:opts.width)
	endif
	if has_key(a:opts, 'height')
		let cmd .= ' --height=' . fnameescape(a:opts.height)
	endif
	if has_key(a:opts, 'title')
		let cmd .= ' --title=' . fnameescape(a:opts.title)
	endif
	let cmd .= ' --autoclose=0'
	let cmd .= ' --silent=' . get(a:opts, 'silent', 0)
	let cwd = (a:opts.cwd == '')? getcwd() : (a:opts.cwd)
	let cmd .= ' --cwd=' . fnameescape(cwd)
	let cmd .= ' ' . fnameescape(asyncrun#script_write(a:opts.cmd, 0))
	exec cmd
	if get(a:opts, 'focus', 1) == 0
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


