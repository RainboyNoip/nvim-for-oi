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
local did_create_keymap_autocmd = false

-- 给单个 buffer 绑定 `<leader>;`：必须逐 buffer 绑，这个键只对 C/C++ 有意义。
local function map_leader_semicolon(bufnr)
  vim.keymap.set('n', '<leader>;', conditional_add_semicolon_normal, {
    buffer = bufnr or true,
    silent = true,
    desc = "在行尾添加分号",
  })
end

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

-- lazy.nvim 在 FileType 之后才加载本插件，所以触发加载的那个 buffer 不会再跑一遍
-- FileType autocmd；setup() 里先手动绑一次，autocmd 负责后续所有 C/C++ buffer。
local function create_cpp_keymap_autocmd()
  if did_create_keymap_autocmd then
    return
  end
  did_create_keymap_autocmd = true

  local group = vim.api.nvim_create_augroup("RainboyCppKeys", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "cpp", "c", "h", "hpp", "cc", "cxx" },
    desc = "为每个 C/C++ buffer 绑定 <leader>;",
    callback = function(args)
      map_leader_semicolon(args.buf)
    end,
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

  -- 这两行是没采用的备选写法（首行跳未插入模式），保留作参考：
  -- vim.keymap.set('n', '<leader>;', 'A;<Esc>', ...)
  -- vim.keymap.set('i', '<leader>;', '<C-o>A;', { buffer = true, silent = true, desc = "在行尾添加分号" })

  map_leader_semicolon()
  create_cpp_keymap_autocmd()
  create_cpp_fold_autocmd()
end

-- 返回这个模块，这样其他文件才能 require 它
return M
