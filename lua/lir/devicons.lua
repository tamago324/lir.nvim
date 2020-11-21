local M = {}
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
local vim = vim


local folder_icon_name = 'lir_folder_icon'

local get_ns = function ()
  return vim.api.nvim_create_namespace('lir')
end


if has_devicons then
  local _, hi_name = devicons.get_icon(folder_icon_name)
  if hi_name:match('IconDefault$') then
    devicons.setup({
      override = {
        [folder_icon_name] = {
          icon = "",
          color = "#7ebae4",
          name = "LirFolderNode"
        },
      }
    })
  end

  local icon, _ = devicons.get_icon('default_icon')
  local ICON_WIDTH = vim.fn.strlen(icon)

  function M.get_devicons(filename, is_dir)
    if is_dir then
      filename = folder_icon_name
    end
    return devicons.get_icon(filename, string.match(filename, '%a+$'), {default = true})
  end

  function M.update_highlights(files)
    local ns = get_ns()
    local col_start, col_end = #' ', ICON_WIDTH + #' '

    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    for i, file in ipairs(files) do
      vim.api.nvim_buf_add_highlight(0, ns, file.devicons.highlight_name, i-1, col_start, col_end)
    end
  end
else
  function M.get_devicons(_, _)
    return '', ''
  end

  function M.update_highlights(files)
    local ns = get_ns()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    for i, file in ipairs(files) do
      if file.is_dir then
        vim.api.nvim_buf_add_highlight(0, ns, 'PreProc', i-1, 0, -1)
      end
    end
  end
end


return M
