call minimode#newlist('MdashAbbrev', [[
  \ 'nnoremap ,mdash :call minimode#activate("MdashAbbrev", 1)<CR>',
  \ ], [
  \ 'autocmd InsertLeave * call minimode#activate("MdashAbbrev", 0)',
  \ 'inoreabbrev -- &mdash;',
  \ ]])


call minimode#newlist('undo/redo', [[
  \ 'nmap ,undoredo :call minimode#activate("undo/redo", 1)<CR>',
  \ ], [
  \ 'nmap <ESC> :call minimode#activate("undo/redo", 0)<CR>',
  \ 'nmap u g-',
  \ 'nmap r g+',
  \ ]])
