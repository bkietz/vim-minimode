MinimodeDefine undo/redo '
  \----
  \    nmap ,undoredo :Minimode undo/redo<CR>
  \
  \----
  \    nmap <ESC> :Minimode undo/redo<CR>
  \    nmap u g-
  \    nmap r g+
  \'

MinimodeDefine MdashAbbrev '
  \----
  \  nnoremap ,mdash :Minimode MdashAbbrev<CR>
  \
  \----
  \  autocmd InsertLeave * Minimode MdashAbbrev
  \  inoreabbrev -- &mdash;
  \'
