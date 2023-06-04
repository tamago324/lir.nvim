local defaults_values = {
  show_hidden_files = false,
  ignore = {},
  devicons = {
    enable = false,
    highlight_dirname = false,
  },
  hide_cursor = false,
  on_init = function() end,
  mappings = {},
  float = {
    winblend = 0,
    curdir_window = {
      enable = false,
      highlight_dirname = false,
    },
  },
  get_filters = nil,
}

---@class lir.config
---@field values lir.config.values
local config = {}

---@class lir.config.values
---@field ignore            table
---@field show_hidden_files boolean
---@field devicons          lir.config.values.devicons
---@field on_init           function
---@field mappings          table
---@field float             lir.config.values.float
---@field hide_cursor       boolean
---@field get_filters fun(): lir.config.filter_func[]
config.values = {}


---@class lir.config.values.devicons
---@field enable            boolean
---@field highlight_dirname boolean

---@alias lir.config.filter_func fun(files: lir_item[]): lir_item[]

---@class lir.config.values.float
---@field winblend        number
---@field win_opts        table|function
---@field curdir_window   lir.config.values.float.curdir_window

---@class lir.config.values.float.size_percentage
---@field width  number
---@field height number

---@class lir.config.values.float.curdir_window
---@field enable  boolean
---@field highlight_dirname boolean

local function echo_warning(message)
  vim.api.nvim_echo({ { "\n", "Normal" } }, false, {})
  vim.api.nvim_echo({ { message, "WarningMsg" } }, false, {})
end

local function warning_deprecated(opts)
  if opts.devicons_enable then
    config.values.devicons.enable = true
    echo_warning("[lir.nvim] `devicons_enable` is deprecated. Use `devicons.enable` instead. \n")
  end

  -- if opts.on_init then
  --   echo_warning("on_init", "vim.api.nvim_create_autocmd()")
  -- end
end

---@param opts lir.config.values
function config.set_default_values(opts)
  config.values = vim.tbl_deep_extend("force", defaults_values, opts or {})

  -- For an empty table
  if vim.tbl_isempty(config.values.float) then
    config.values.float = defaults_values.float
  elseif vim.tbl_isempty(config.values.float.curdir_window) then
    config.values.float.curdir_window = defaults_values.float.curdir_window
  end

  if vim.tbl_isempty(config.values.devicons) then
    config.values.devicons = defaults_values.devicons
  end

  warning_deprecated(opts)
end

return config
