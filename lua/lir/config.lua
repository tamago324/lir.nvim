local config = {}
config.values = {}


local defaults_values = {
  show_hidden_files = false,
  devicons_enable = false,
  mappings = {},
}


function config.set_default_values(opts)
  config.values = vim.tbl_deep_extend('force', defaults_values, opts or {})
end


return config
