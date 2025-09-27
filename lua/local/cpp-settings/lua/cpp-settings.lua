-- 普通模式下的函数
local function conditional_add_semicolon_normal()
  local line = vim.api.nvim_get_current_line()
  -- 检查行尾是否已经有分号 (忽略末尾的空白字符)
  if not line:match(";%s*$") then
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_buf_set_lines(0, pos[1] - 1, pos[1], false, { line .. ";" })
    vim.api.nvim_win_set_cursor(0, pos)
  end
end

-- 插入模式下的函数
local function conditional_add_semicolon_insert()
  local line = vim.api.nvim_get_current_line()
  -- 检查行尾是否已经有分号 (忽略末尾的空白字符)
  if not line:match(";%s*$") then
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_buf_set_lines(0, pos[1] - 1, pos[1], false, { line .. ";" })
    vim.api.nvim_win_set_cursor(0, pos)
  end
end

-- 创建一个名为 M 的 table，代表我们的模块
local M = {}

-- 创建一个 setup 函数，这是模块的入口点
function M.setup()
  print("Custom C++ settings from an external LOCAL module file loaded!")

  -- 设定缓冲区局部的选项
  vim.bo.tabstop = 4
  vim.bo.shiftwidth = 4
  vim.bo.softtabstop = 4
  vim.bo.expandtab = true

  -- 设定缓冲区局部的快捷键
  local opts = { buffer = true, silent = true }
  -- vim.keymap.set('n', '<F5>', ':w <bar> !g++ -std=c++17 % -o %< && ./%< <CR>', {
  --   buffer = true,
  --   desc = "Compile & Run C++ file"
  -- })

  -- ... 你未来可以添加更多快捷键和设置在这里 ...

  -- Toggle current line (linewise) using C-/
  local api = require("Comment.api")
  vim.keymap.set({ 'n', 'v' }, '<C-_>', api.toggle.linewise.current, { buffer = true, silent = true, desc = "切换注释" })
  -- Toggle current line (blockwise) using C-\
  vim.keymap.set('n', '<C-\\>', api.toggle.blockwise.current, { buffer = true, silent = true, desc = "切换注释" })

  -- // TODO 更多的注释快捷键
  -- // 选中多行注释
  -- // 快速注释，一个函数


  -- 在行尾添加分号 (如果需要)

  vim.keymap.set('n', '<leader>;', conditional_add_semicolon_normal, { buffer = true, silent = true, desc = "在行尾添加分号" })
  vim.keymap.set('i', '<leader>;', conditional_add_semicolon_insert, { buffer = true, silent = true, desc = "在行尾添加分号" })
  -- vim.keymap.set('n', '<leader>;', 'A;<Esc>', { buffer = true, silent = true, desc = "在行尾添加分号" })
  -- vim.keymap.set('i', '<leader>;', '<C-o>A;', { buffer = true, silent = true, desc = "在行尾添加分号" })
end

-- 返回这个模块，这样其他文件才能 require 它
return M
