local M = {}
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
local vim = vim


local get_ns = function ()
  return vim.api.nvim_create_namespace('lir')
end

local icon
local ICON_WIDTH

if has_devicons then
  icon, _ = devicons.get_icon('default_icon')
  ICON_WIDTH = vim.fn.strlen(icon)

  M.get_devicons = function(filename, is_dir)
    if is_dir then
      filename = 'folder_icon'
    end
    return devicons.get_icon(filename, string.match(filename, '%a+$'))
  end
else
  icon = ''
  ICON_WIDTH = vim.fn.strlen(icon)

  M.get_devicons = function(filename, is_dir)
    return ''
  end
end


M.update_highlights = function (files)
  local ns = get_ns()
  local col_start, col_end = #' ', ICON_WIDTH + #' '

  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  for i, file in ipairs(files) do
    vim.api.nvim_buf_add_highlight(0, ns, file.devicons.highlight_name, i-1, col_start, col_end)
  end
end


return M
