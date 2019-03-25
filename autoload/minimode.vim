let g:minimode#deactivation_for = {}

function! g:minimode#get_deactivation_for(cmd)
  let verb_args = matchlist(a:cmd, '\v^(\i+!?)(.*)$')
  if has_key(g:minimode#deactivation_for, verb_args[1])
    return g:minimode#deactivation_for[verb_args[1]](verb_args[2])
  endif
  return ''
endfunction

function! s:simple_deactivation(verb, args)
  let special_args = ''
  let other_args = a:args
  while v:true
    " possible special arguments to map, abbreviate, ...
    let special_matches = matchlist(other_args,
      \ '\v^\s+\<(buffer|nowait|silent|script|expr|unique)\>(.*)$')
    if len(special_matches) == 0
      break
    endif
    let special_args .= ' <' . special_matches[1] . '>'
    let other_args = special_matches[2]
  endwhile
  return a:verb . special_args . ' ' . matchlist(other_args, '\v^\s+(\S+).*$')[1]
endfunction

function s:define_simple_deactivation(prefix, verb)
  let Deactivation = {args -> s:simple_deactivation(a:prefix . 'un' . a:verb, args)}
  let g:minimode#deactivation_for[a:prefix . a:verb] = Deactivation
  let g:minimode#deactivation_for[a:prefix . 'nore' . a:verb] = Deactivation
endfunction

function s:define_builtin_deactivations()
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

let s:modelists = {}

function s:activate(modelist)
  for cmd in a:modelist.activations[a:modelist.current]
    execute cmd
  endfor
endfunction

function s:deactivate(modelist)
  for cmd in a:modelist.deactivations[a:modelist.current]
    execute cmd
  endfor
endfunction

function g:minimode#newlist(name, activations)
  let modelist = { 'current': 0, 'activations': a:activations, 'deactivations': [] }

  for activation_list in a:activations
    " build a list of deactivations in reverse order
    let deactivation_list = []
    for cmd in activation_list
      let uncmd = minimode#get_deactivation_for(cmd)
      if uncmd == '' | continue | endif
      call insert(deactivation_list, uncmd)
    endfor

    " bracket activation commands with an augroup for easy deactivation
    call insert(activation_list, 'augroup ' . a:name)
    call add(activation_list, 'augroup END')
    call insert(deactivation_list, 'autocmd! ' . a:name)

    call add(modelist.deactivations, deactivation_list)
  endfor
  call s:activate(modelist)
  let s:modelists[a:name] = modelist
endfunction

function g:minimode#activate(name, index)
  let modelist = s:modelists[a:name]
  call s:deactivate(modelist)
  let modelist.current = a:index
  call s:activate(modelist)
endfunction

