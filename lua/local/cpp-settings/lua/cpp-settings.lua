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

-- 创建一个名为 M 的 table，代表我们的模块
local M = {}
local did_create_fold_autocmd = false

local function create_cpp_fold_autocmd()
  if did_create_fold_autocmd then
    return
  end
  did_create_fold_autocmd = true

  local group = vim.api.nvim_create_augroup("RainboyCppAutoFold", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = { "*.cpp", "*.hpp", "*.h", "*.cc", "*.cxx" },
    callback = function(args)
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end

      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(args.buf) and vim.api.nvim_get_current_buf() == args.buf then
          vim.cmd("normal! zM")
        end
      end, 10)
    end,
    desc = "打开C++文件后自动折叠所有代码"
  })
end

-- 创建一个 setup 函数，这是模块的入口点
function M.setup()
  -- print("Custom C++ settings from an external LOCAL module file loaded!")

  -- 设定缓冲区局部的选项
  vim.bo.tabstop = 4
  vim.bo.shiftwidth = 4
  vim.bo.softtabstop = 4
  vim.bo.expandtab = true

  -- Toggle current line (linewise) using C-/
  local api = require("Comment.api")
  vim.keymap.set({ 'n', 'v' }, '<C-_>', api.toggle.linewise.current, { buffer = true, silent = true, desc = "切换注释" })
  -- Toggle current line (blockwise) using C-\
  vim.keymap.set('n', '<C-\\>', api.toggle.blockwise.current, { buffer = true, silent = true, desc = "切换注释" })

  -- // TODO 更多的注释快捷键
  -- // 选中多行注释
  -- // 快速注释，一个函数


  vim.keymap.set('n', '<leader>;', conditional_add_semicolon_normal, { buffer = true, silent = true, desc = "在行尾添加分号" })

  -- vim.keymap.set('n', '<leader>;', 'A;<Esc>', { buffer = true, silent = true, desc = "在行尾添加分号" })
  -- vim.keymap.set('i', '<leader>;', '<C-o>A;', { buffer = true, silent = true, desc = "在行尾添加分号" })

  create_cpp_fold_autocmd()
end

-- 返回这个模块，这样其他文件才能 require 它
return M
