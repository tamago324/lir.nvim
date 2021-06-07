-----------------------------
-- Private
-----------------------------
local defaults_values = {
  show_hidden_files = false,
  devicons_enable = false,
  mappings = {},
  float = {
    size_percentage = { width = 0.5, height = 0.5 },
    winblend = 15,
    border = false,
    borderchars = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
    shadow = false,
  },
  hide_cursor = false,
}

-----------------------------
-- Export
-----------------------------

---@class lir.config
---@field values lir.config.values
local config = {}

---@class lir.config.values
---@field show_hidden_files boolean
---@field devicons_enable   boolean
---@field mappings          table
---@field float             lir.config.values.float
---@field hide_cursor       boolean
config.values = {}

---@class lir.config.values.float
---@field size_percentage lir.config.values.float.size_percentage
---@field winblend        number
---@field border          boolean
---@field borderchars     string[]
---@field shadow          boolean

---@class lir.config.values.float.size_percentage
---@field width  number
---@field height number

---@param opts lir.config.values
function config.set_default_values(opts)
  config.values = vim.tbl_deep_extend("force", defaults_values, opts or {})
end

return config
