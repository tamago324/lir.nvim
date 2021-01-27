scriptencoding utf-8


function! s:shutup_netrw() abort
  if exists('#FileExplorer')
    autocmd! FileExplorer *
  endif
  if exists('#NERDTreeHijackNetrw')
    autocmd! NERDTreeHijackNetrw *
  endif
endfunction


augroup lir
  autocmd!
  autocmd VimEnter *   call s:shutup_netrw()
  autocmd BufEnter *   lua require('lir').init()
  autocmd FileType lir let w:lir_before_lir_buffer = v:true
  autocmd BufLeave *   let w:lir_before_lir_buffer = &filetype !=# 'lir'
augroup END


augroup lir-float
  autocmd!
  autocmd FileType lir :lua require'lir.float.curdir_window'.new()
  autocmd FileType lir :lua require'lir.float.border'.new()
augroup END


highlight def link LirFloatNormal Normal
highlight def link LirFloatBorder LirFloatNormal
