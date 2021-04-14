-----------------------------
-- Private
-----------------------------
local defaults_values = {
  show_hidden_files = false,
  devicons_enable = false,
  mappings = {},
  float = {
    size_percentage = 0.5,
    winblend = 15,
    border = false,
    borderchars = {"╔" , "═" , "╗" , "║" , "╝" , "═" , "╚", "║"},
  },
  hide_cursor = false,
}


-----------------------------
-- Export
-----------------------------

---@class lir_config
local config = {}
config.values = {}

---@param opts table
function config.set_default_values(opts)
  config.values = vim.tbl_deep_extend('force', defaults_values, opts or {})
end

return config
