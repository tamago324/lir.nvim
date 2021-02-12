# lir.nvim


[WIP] simple file explorer

```vim
Plug 'tamago324/lir.nvim'
Plug 'nvim-lua/plenary.nvim'

" Optional
Plug 'kyazdani42/nvim-web-devicons'
```


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
  },
  float = {
    size_percentage = 0.5,
    winblend = 15,
    border = true,
    borderchars = {"═" , "║" , "═" , "║" , "╔" , "╗" , "╝" , "╚"},
  },
  hide_cursor = true,
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


## Usage

```sh
$ nvim /path/to/directory/
```

or

```vim
:edit .
```

### Use floating window

```
:lua require'lir.float'.toggle()
:lua require'lir.float'.init()
```

Change highlights groups.

```viml
hi LirFloatNormal guibg=#32302f
hi LirFloatBorder guifg=#7c6f64
```


### Extensions

* [tamago324/lir-mark.nvim](https://github.com/tamago324/lir-mark.nvim)
* [tamago324/lir-mmv.nvim](https://github.com/tamago324/lir-mmv.nvim)
* [tamago324/lir-bookmark.nvim](https://github.com/tamago324/lir-bookmark.nvim)


## Credit

* [mattn/vim-molder](https://github.com/mattn/vim-molder)
* [norcalli/nvim_utils](https://github.com/norcalli/nvim_utils)
* [lambdalisue/fern.vim](https://github.com/lambdalisue/fern.vim)


## License

MIT
