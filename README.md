# lir.nvim


[WIP] simple file explorer

```vim
Plug 'tamago324/lir.nvim'
" Optional
Plug 'kyazdani42/nvim-web-devicons'
```


## Exmaple

```vim
function! s:my_ft_lir() abort
    nnoremap <buffer> l     <cmd>lua require'lir.actions'.edit()<CR>
    nnoremap <buffer> o     <cmd>lua require'lir.actions'.edit()<CR>
    nnoremap <buffer> <C-s> <cmd>lua require'lir.actions'.split()<CR>
    nnoremap <buffer> <C-v> <cmd>lua require'lir.actions'.vsplit()<CR>
    nnoremap <buffer> <C-t> <cmd>lua require'lir.actions'.tabedit()<CR>

    nnoremap <buffer> h     <cmd>lua require'lir.actions'.up()<CR>
    nnoremap <buffer> q     <cmd>lua require'lir.actions'.quit()<CR>
    nnoremap <buffer> <C-e> <cmd>lua require'lir.actions'.quit()<CR>

    nnoremap <buffer> K     <cmd>lua require'lir.actions'.mkdir()<CR>
    nnoremap <buffer> N     <cmd>lua require'lir.actions'.newfile()<CR>
    nnoremap <buffer> R     <cmd>lua require'lir.actions'.rename()<CR>
    nnoremap <buffer> @     <cmd>lua require'lir.actions'.cd()<CR>
    nnoremap <buffer> Y     <cmd>lua require'lir.actions'.yank_path()<CR>
    nnoremap <buffer> .     <cmd>lua require'lir.actions'.toggle_show_hidden()<CR>
endfunction
augroup my-ft-lir
    autocmd!
    autocmd FileType lir call <SID>my_ft_lir()
augroup END

lua << EOF
-- custom folder icon
require'nvim-web-devicons'.setup({
  override = {
    lir_folder_icon = {
      icon = "",
      color = "#7ebae4",
      name = "LirFolderNode"
    },
  }
})
EOF
```


## Credit

* Thanks [vim-molder](https://github.com/mattn/vim-molder)


## License

MIT
