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
augroup END
