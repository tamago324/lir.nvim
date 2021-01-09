augroup lir-float
  autocmd!
  autocmd FileType lir :lua require'lir.float.curdir_window'.new()
augroup END
