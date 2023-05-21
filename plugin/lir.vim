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
  " setlocal を使っているため、毎回セットする必要がある
  autocmd BufWinEnter * lua require('lir.float').setlocal_winhl()
  " BufLeave したバッファに対して処理が走る
  " 1つ前のバッファが lir かどうかを保持
  autocmd BufLeave *   let w:lir_prev_filetype = &filetype
augroup END


function Define_hlgroups()
	highligh def link LirFloatNormal             Normal
	highlight def link LirDir                     PreProc
	highlight def link LirSymLink                 PreProc
	highlight def link LirEmptyDirText            BlueSign
	highlight def link LirFloatCurdirWindowNormal Normal
	highlight def link LirFloatCurdirWindowDirName PreProc
	highlight def      LirTransparentCursor gui=strikethrough blend=100
	highlight def link LirFloatBorder             FloatBorder
	highlight def link LirFloatCursorLine         CursorLine
endfunction

call Define_hlgroups()

# Update highlights on ColorScheme event because
#  a theme might execute ":highlight clear"
augroup LirHighlight
	autocmd!
	au ColorScheme * call Define_hlgroups()
augroup END

