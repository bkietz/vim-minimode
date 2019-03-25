filetype off
set rtp+=~/.config/nvim/plugged/vader.vim
set rtp+=..
filetype plugin indent on
set syntax=off

call minimode#newlist('TabNav', [[
  \ 'nnoremap <C-t> :call minimode#activate("Tabnav", 1)<CR>',
  \ ], [
  \ 'nnoremap <ESC> :call minimode#activate("Tabnav", 0)<CR>',
  \ 'nnoremap h :tabprev<CR>',
  \ 'nnoremap l :tabnext<CR>',
  \ ]])
