# lir.nvim


[WIP] simple file explorer

```vim
Plug 'tamago324/lir.nvim'
" Optional
Plug 'kyazdani42/nvim-web-devicons'
```

If you want to use it with a floating window, you should also install [lir-float.nvim](https://github.com/tamago324/lir-float.nvim).


## Configuration

```lua
local actions = require'lir.actions'

require'lir'.setup {
  show_hidden_files = false,
  devicons_enable = true,
  mappings = {
    ['l']     = actions.edit,
    ['<C-s>'] = actions.split,
    ['<C-v>'] = actions.vsplit,
    ['<C-t>'] = actions.tabedit,

    ['h']     = actions.up,
    ['q']     = actions.quit,

    ['K']     = actions.mkdir,
    ['N']     = actions.newfile,
    ['R']     = actions.rename,
    ['@']     = actions.cd,
    ['Y']     = actions.yank_path,
    ['.']     = actions.toggle_show_hidden,
  }
}

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
```


## Credit

* [mattn/vim-molder](https://github.com/mattn/vim-molder)
* [norcalli/nvim_utils](https://github.com/norcalli/nvim_utils)


## License

MIT
