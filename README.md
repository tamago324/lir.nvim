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
  ignore = {}, -- { ".DS_Store" "node_modules" } etc.
  devicons = {
    enable = false,
    highlight_dirname = false
  },
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
    winblend = 0,
    curdir_window = {
      enable = false,
      highlight_dirname = false
    },

    -- -- You can define a function that returns a table to be passed as the third
    -- -- argument of nvim_open_win().
    -- win_opts = function()
    --   local width = math.floor(vim.o.columns * 0.8)
    --   local height = math.floor(vim.o.lines * 0.8)
    --   return {
    --     border = {
    --       "+", "─", "+", "│", "+", "─", "+", "│",
    --     },
    --     width = width,
    --     height = height,
    --     row = 1,
    --     col = math.floor((vim.o.columns - width) / 2),
    --   }
    -- end,
  },
  hide_cursor = true
}

vim.api.nvim_create_autocmd({'FileType'}, {
  pattern = {"lir"},
  callback = function()
    -- use visual mode
    vim.api.nvim_buf_set_keymap(
      0,
      "x",
      "J",
      ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>',
      { noremap = true, silent = true }
    )
  
    -- echo cwd
    vim.api.nvim_echo({ { vim.fn.expand("%:p"), "Normal" } }, false, {})
  end
})

-- custom folder icon
require'nvim-web-devicons'.set_icon({
  lir_folder_icon = {
    icon = "",
    color = "#7ebae4",
    name = "LirFolderNode"
  }
})
```

NOTE: Actions can be added easily (see [wiki](https://github.com/tamago324/lir.nvim/wiki/Custom-actions))

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

### Extensions

- [tamago324/lir-mmv.nvim](https://github.com/tamago324/lir-mmv.nvim)
- [tamago324/lir-bookmark.nvim](https://github.com/tamago324/lir-bookmark.nvim)
- [tamago324/lir-git-status.nvim](https://github.com/tamago324/lir-git-status.nvim)

## Credit

- [mattn/vim-molder](https://github.com/mattn/vim-molder)
- [norcalli/nvim_utils](https://github.com/norcalli/nvim_utils)
- [lambdalisue/fern.vim](https://github.com/lambdalisue/fern.vim)

## Screenshots

![](https://github.com/tamago324/images/blob/master/lir.nvim/lir-normal.png)

![](https://github.com/tamago324/images/blob/master/lir.nvim/lir-float.png)

![](https://github.com/tamago324/images/blob/master/lir.nvim/lir-float-current-dir.png)

## License

MIT
