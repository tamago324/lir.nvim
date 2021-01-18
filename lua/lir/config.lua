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
  },
  hide_cursor = false,
}


-----------------------------
-- Export
-----------------------------
local config = {}
config.values = {}

function config.set_default_values(opts)
  config.values = vim.tbl_deep_extend('force', defaults_values, opts or {})
end

return config
