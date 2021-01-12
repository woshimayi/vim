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
" gnome-terminal
"----------------------------------------------------------------------
function! s:gnome_run(opts)
	let cmds = []
	let cmds += ['cd ' . shellescape(getcwd()) ]
	let cmds += [a:opts.cmd]
	let cmds += ['echo ""']
	let cmds += ['read -n1 -rsp "press any key to continue ..."']
	let text = shellescape(join(cmds, ";"))
	let command = 'gnome-terminal -- bash -c ' . text
	call system(command . ' &')
endfunction

function! s:gnome_tab(opts)
	let cmds = []
	let cmds += ['cd ' . shellescape(getcwd()) ]
	let cmds += [a:opts.cmd]
	let cmds += ['echo ""']
	let cmds += ['read -n1 -rsp "press any key to continue ..."']
	let text = shellescape(join(cmds, ";"))
	let command = 'gnome-terminal --tab --active -- bash -c ' . text
	call system(command . ' &')
endfunction

let g:asyncrun_runner.gnome = function('s:gnome_run')
let g:asyncrun_runner.gnome_tab = function('s:gnome_tab')


"----------------------------------------------------------------------
" run in xterm
"----------------------------------------------------------------------
function! s:xterm_run(opts)
	let cmds = []
	let cmds += ['cd ' . shellescape(getcwd()) ]
	let cmds += [a:opts.cmd]
	let cmds += ['echo ""']
	let cmds += ['read -n1 -rsp "press any key to continue ..."']
	let text = shellescape(join(cmds, ";"))
	let command = 'xterm '
	let command .= ' -T ' . shellescape(':AsyncRun ' . a:opts.cmd)
	let command .= ' -e bash -c ' . text
	call system(command . ' &')
endfunc

let g:asyncrun_runner.xterm = function('s:xterm_run')


"----------------------------------------------------------------------
" floaterm
"----------------------------------------------------------------------
function! s:floaterm_run(opts)
	let cmd = 'FloatermNew '
	let cmd .= ' --wintype=float'
	if has_key(a:opts, 'position') 
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
	" for precise arguments passing and shell builtin commands
	" a temporary file is introduced
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


