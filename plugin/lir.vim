function! s:shutup_netrw() abort
    if exists('#FileExplorer')
        autocmd! FileExplorer *
    endif
    if exists('#NERDTreeHijackNetrw')
        autocmd! NERDTreeHijackNetrw *
    endif
endfunction

augroup lir_nvim
    autocmd!
    autocmd VimEnter * call s:shutup_netrw()
    autocmd BufEnter * lua require'lir'.init()
    autocmd FileType lir let w:lir_before_lir_buffer = v:true
    autocmd BufLeave * let w:lir_before_lir_buffer = &filetype !=# 'lir'
augroup END
