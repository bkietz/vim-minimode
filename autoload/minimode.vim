let g:minimode#deactivation_for = {}

function g:minimode#init()
endfunction

function! g:minimode#get_deactivation_for(cmd)
  let verb_args = matchlist(a:cmd, '\v^\s*(\i+!?)(.*)$')
  if len(verb_args) == 0 || !has_key(g:minimode#deactivation_for, verb_args[1])
    return ''
  endif
  return g:minimode#deactivation_for[verb_args[1]](verb_args[2])
endfunction

" create deactivation command when the arguments are <special>s followed by a
" single left-hand-side (nmap, abbreviate)
function! s:simple_deactivation(verb, args)
  let special_args = ''
  let other_args = a:args
  while v:true
    try
      " possible special arguments, see :help :map-arguments
      let matches = matchlist(other_args,
        \ '\v^\s+\<(buffer|nowait|silent|script|expr|unique)\>(.*)$')
      let [special_arg, other_args] = matches[1:2]
      let special_args .= ' <' . special_arg . '>'
    catch
      break
    endtry
  endwhile
  let lhs = matchlist(other_args, '\v^\s+(\S+).*$')[1]
  return a:verb . special_args . ' ' . lhs
endfunction

function! s:define_simple_deactivation(prefix, verb)
  let Deactivation = {args -> s:simple_deactivation(a:prefix . 'un' . a:verb, args)}
  let g:minimode#deactivation_for[a:prefix . a:verb] = Deactivation
  let g:minimode#deactivation_for[a:prefix . 'nore' . a:verb] = Deactivation
endfunction

function! s:define_builtin_deactivations()
  for prefix in split('n v x s o i l c t')
    call s:define_simple_deactivation(prefix, 'map')
  endfor
  call s:define_simple_deactivation('', 'map')
  call s:define_simple_deactivation('', 'map!')

  for prefix in split('c i')
    call s:define_simple_deactivation(prefix, 'abbrev')
  endfor
  call s:define_simple_deactivation('', 'abbrev')
  call s:define_simple_deactivation('', 'abbreviate')
endfunction

call s:define_builtin_deactivations()

function! s:get_deactivation_block(activation_block)
  " build a list of deactivations in reverse order
  let deactivation_block = []
  for cmd in a:activation_block
    let uncmd = minimode#get_deactivation_for(cmd)
    if uncmd == '' | continue | endif
    call insert(deactivation_block, uncmd)
  endfor
  return deactivation_block
endfunction

function! s:_activate(state)
  for cmd in a:state.activation_block | execute cmd | endfor
endfunction

function! s:_deactivate(state)
  " lazily build deactivation blocks
  if !has_key(a:state, 'deactivation_block')
    let a:state.deactivation_block = s:get_deactivation_block(a:state.activation_block)
    call insert(a:state.deactivation_block, 'autocmd! ' . a:state.mode.name)
  endif
  for cmd in a:state.deactivation_block | execute cmd | endfor
endfunction

let s:modes = {}

function! s:make(name, activations)
  let mode = {
    \ 'name': a:name,
    \ 'current': 0,
    \ 'states': [],
    \ }

  function mode.toggle() dict
    return self.states[!self.current].activate()
  endfunction

  for block in a:activations
    let state = {
      \ 'mode': mode,
      \ 'index': len(mode.states),
      \ 'activation_block': block,
      \ }

    function state.activate() dict
      let current = self.mode.states[self.mode.current]
      call s:_deactivate(current)
      call s:_activate(self)
      let self.mode.current = self.index
    endfunction

    " bracket activation commands with an augroup for easy deactivation
    call insert(state.activation_block, 'augroup ' . mode.name)
    call add(state.activation_block, 'augroup END')

    call add(mode.states, state)
  endfor

  " begin with default state active
  call s:_activate(mode.states[0])

  let s:modes[mode.name] = mode
  return mode
endfunction

command! -nargs=* MinimodeSet call s:command(<f-args>)

function! s:command(mode, ...)
  let mode = s:modes[a:mode]
  if len(a:000) == 0
    return mode.toggle()
  endif
  return mode.states[a:0].activate()
endfunction

command! -bang -nargs=* Minimode call s:define(<bang>0, <q-args>)

function! s:define(override, defstr)
  let [expr, name, states] = matchlist(a:defstr, '\v^(\s*\<expr\>\s+|)(\i+)(.*)$')[1:3]
  if !a:override && has_key(s:modes, name)
    throw 'Minimode with name ' . name
      \ . ' already defined, use Minimode! to override'
  endif
  if expr != ''
    let states = eval(states)
  else
    let states = minimode#indentblocksplit(states)
  endif
  call s:make(name, states)
endfunction

" public for testing purposes
function! g:minimode#indentsplit(str) abort
  let indent = matchlist(a:str, '\v^(\s+)\S.*$')[1]
  return split(a:str, indent)
endfunction

function! g:minimode#indentblocksplit(str) abort
  let [divider, rest] = matchlist(a:str, '\v^(\S+)(.*)$')[1:2]
  let blocks = split(rest, divider)
  return map(blocks, { i, block -> minimode#indentsplit(block) })
endfunction

