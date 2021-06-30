local F = require("plenary.functional")

local M = {}

local default_opts = {
  size_percentage = { width = 0.5, height = 0.5 },
  border = "none",
}

--- Return a table with highlighted borderchars.
---   { {'=', highlight }, {'|', highlight}, ... }
---@param borderchars table
---@param highlight string
---@return table
M.make_border_opts = function(borderchars, highlight)
  return vim.tbl_map(function(char)
    return { char, highlight }
  end, borderchars)
end

--- Return the default value of the option
---@param opts table
---@return table
M.make_default_win_config = function(opts)
  opts = F.if_nil(opts, default_opts, opts)

  local width_percentage, height_percentage
  if type(opts.size_percentage) == "number" then
    width_percentage = opts.size_percentage
    height_percentage = opts.size_percentage
  elseif type(opts.size_percentage) == "table" then
    width_percentage = opts.size_percentage.width
    height_percentage = opts.size_percentage.height
  else
    error(string.format(
      "'size_percentage' can be either number or table: %s",
      vim.inspect(opts.size_percentage)
    ))
  end

  local width = math.floor(vim.o.columns * width_percentage)
  local height = math.floor(vim.o.lines * height_percentage)

  local top = math.floor(((vim.o.lines - height) / 2) - 1)
  local left = math.floor((vim.o.columns - width) / 2)

  local result = {
    relative = "editor",
    row = top,
    col = left,
    width = width,
    height = height,
    style = "minimal",
    border = opts.border,
  }

  return result
end

return M
