filetype off
set rtp+=~/.config/nvim/plugged/vader.vim
set rtp+=..
filetype plugin indent on
set syntax=off
call minimode#init()

Minimode UndoRedo
  \""""
  \    nmap ,undoredo :MinimodeSet UndoRedo<CR>
  \
  \""""
  \    nmap <ESC> :MinimodeSet UndoRedo<CR>
  \    nmap u g-
  \    nmap r g+

Minimode MdashAbbrev
  \""""
  \    nnoremap ,mdash :MinimodeSet MdashAbbrev<CR>
  \
  \""""
  \    autocmd InsertLeave * MinimodeSet MdashAbbrev
  \    inoreabbrev -- &mdash;
