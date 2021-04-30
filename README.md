# lir.nvim

A simple file explorer

Note: lir.nvim does not define any default mappings, you need to configure them yourself by referring to [help](doc/lir.txt).


## Installation

```vim
Plug 'tamago324/lir.nvim'
Plug 'nvim-lua/plenary.nvim'

" Optional
Plug 'kyazdani42/nvim-web-devicons'
```


## Configuration

```lua
local actions = require'lir.actions'
local mark_actions = require 'lir.mark.actions'
local clipboard_actions = require'lir.clipboard.actions'

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
    ['D']     = actions.delete,

    ['J'] = function()
      mark_actions.toggle_mark()
      vim.cmd('normal! j')
    end,
    ['C'] = clipboard_actions.copy,
    ['X'] = clipboard_actions.cut,
    ['P'] = clipboard_actions.paste,
  },
  float = {
    size_percentage = 0.5,
    winblend = 15,
    border = true,
    borderchars = {"╔" , "═" , "╗" , "║" , "╝" , "═" , "╚", "║"},

    -- -- If you want to use `shadow`, set `shadow` to `true`.
    -- -- Also, if you set shadow to true, the value of `borderchars` will be ignored.
    -- shadow = false,
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

-- use visual mode
function _G.LirSettings()
  vim.api.nvim_buf_set_keymap(0, 'x', 'J', ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>', {noremap = true, silent = true})

  -- echo cwd
  vim.api.nvim_echo({{vim.fn.expand('%:p'), 'Normal'}}, false, {})
end

vim.cmd [[augroup lir-settings]]
vim.cmd [[  autocmd!]]
vim.cmd [[  autocmd Filetype lir :lua LirSettings()]]
vim.cmd [[augroup END]]
```


## Usage

### Use normal buffer (like dirvish)

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
hi LirDir guifg=#7ebae4
hi LirSymLink guifg=#7c6f64
hi LirEmptyDirText guifg=#7c6f64
```


### Extensions

* [tamago324/lir-mmv.nvim](https://github.com/tamago324/lir-mmv.nvim)
* [tamago324/lir-bookmark.nvim](https://github.com/tamago324/lir-bookmark.nvim)


## Credit

* [mattn/vim-molder](https://github.com/mattn/vim-molder)
* [norcalli/nvim_utils](https://github.com/norcalli/nvim_utils)
* [lambdalisue/fern.vim](https://github.com/lambdalisue/fern.vim)

## Screenshots

![](https://github.com/tamago324/images/blob/master/lir.nvim/lir-normal.png)

![](https://github.com/tamago324/images/blob/master/lir.nvim/lir-float.png)


## License

MIT
