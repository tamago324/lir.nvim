local has_devicons, Devicons = pcall(require, "nvim-web-devicons")
local utils = require("lir.utils")
-- local config = 'lir.config'

local vim = vim
local a = vim.api

-----------------------------
-- Private
-----------------------------
local ns = a.nvim_create_namespace("lir_devicons")
local FOLDER_ICON_NAME = "lir_folder_icon"
local ICON_WIDTH = 0

-----------------------------
-- Export
-----------------------------

---@class lir_devicons
local devicons = {}

function devicons.setup()
  if not has_devicons then
    utils.error("[lir.nvim] Require nvim-web-devicons")
    -- XXX: Can I change the config here?
    -- config.values.devicons.enable = false
    return
  end
  local folder_icon, _ = Devicons.get_icon(FOLDER_ICON_NAME)
  if folder_icon == nil then
    Devicons.set_icon({
      [FOLDER_ICON_NAME] = {
        icon = "",
        color = "#7ebae4",
        name = "LirFolderNode",
      },
    })
  end

  local icon = Devicons.get_icon("default_icon", "", { default = true })
  ICON_WIDTH = vim.fn.strlen(icon)
end

---@param filename string
---@param is_dir   boolean
---@return string, string
function devicons.get_devicons(filename, is_dir)
  if is_dir then
    filename = FOLDER_ICON_NAME
  end
  return Devicons.get_icon(filename, string.match(filename, "%a+$"), { default = true })
end

---@param files lir_item[]
---@param header_offset integer
function devicons.update_highlight(files, header_offset)
  local col_start, col_end = #" ", ICON_WIDTH + #" "

  a.nvim_buf_clear_namespace(0, ns, 0, -1)
  for i, file in ipairs(files) do
    a.nvim_buf_add_highlight(0, ns, file.devicons.highlight_name, i - 1 + header_offset, col_start, col_end)
  end
end

return devicons
