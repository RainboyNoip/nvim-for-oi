local Snacks = require("snacks")
local Terminal = require("snacks.terminal")
local M = {}

--- Version using Snacks picker for better UI
function M.select_toggle()
  local terminals = Terminal.list()
  
  if #terminals == 0 then
    return Terminal.toggle()
  end
  
  if #terminals == 1 then
    return terminals[1]:toggle()
  end
  
  -- 准备 picker 项目
  local items = {}
  for i, terminal in ipairs(terminals) do
    local cmd = terminal.cmd or "shell"
    local cmd_str = type(cmd) == "table" and table.concat(cmd, " ") or cmd
    -- local status = terminal:is_visible() and "visible" or "hidden"
    local status = terminal.win and vim.api.nvim_win_is_valid(terminal.win) and "visible" or "hidden"
    local buf_info = vim.fn.getbufinfo(terminal.buf)[1] or {}
    local buf_name = buf_info.name and vim.fn.fnamemodify(buf_info.name, ":t") or "terminal"
    
    table.insert(items, {
      id = tostring(i),
      text = cmd_str,
      sub = string.format("%s • buf:%d", status, terminal.buf or 0),
      terminal = terminal,
      ordinal = tostring(i) .. " " .. cmd_str
    })
  end
  
  -- 使用 Snacks picker
  -- if Snacks and Snacks.picker then
  if false then
    -- TODO fix this error
    Snacks.picker {
      prompt = "Select Terminal:",
      items = items,
      cb = function(item)
        if item and item.terminal then
          item.terminal:toggle()
        end
      end
    }
  else
    -- 回退到 vim.ui.select
    local choices = {}
    local choice_map = {}
    
    for _, item in ipairs(items) do
      local display_text = string.format("%s (%s)", item.text, item.sub)
      table.insert(choices, display_text)
      choice_map[display_text] = item.terminal
    end
    
    vim.ui.select(choices, {
      prompt = "Select Terminal to Toggle:",
    }, function(choice)
      if choice and choice_map[choice] then
        choice_map[choice]:toggle()
      end
    end)
  end
end

return M