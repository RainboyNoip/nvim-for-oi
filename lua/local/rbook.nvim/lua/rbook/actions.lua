local config = require("rbook.config")
local deps = require("rbook.deps")
local paths = require("rbook.paths")

local M = {}

local function notify(message, level)
  -- 有 snacks 时用它的通知样式；没有时退回 Neovim 原生 notify。
  local snacks = deps.snacks()
  if snacks and snacks.notify then
    snacks.notify(message, { level = level or vim.log.levels.INFO })
  else
    vim.notify(message, level or vim.log.levels.INFO)
  end
end

local function read_lines(path)
  if vim.fn.filereadable(path) == 0 then
    notify("文件不可读: " .. path, vim.log.levels.ERROR)
    return nil
  end
  return vim.fn.readfile(path)
end

local function with_fold_markers(lines, item)
  -- 折叠标记是可选动作，默认关闭，避免污染提交到 OJ 的代码。
  if not config.get().insert.fold_markers then
    return lines
  end

  local title = item.title or vim.fn.fnamemodify(item.code_path, ":t")
  local copy = vim.list_slice(lines)
  table.insert(copy, 1, "// rbook_begin: " .. title)
  copy[#copy + 1] = "// rbook_end"
  return copy
end

function M.insert_code(item, opts)
  -- 插入策略固定为“当前光标行之前插入”，不替换当前行，避免误删用户代码。
  opts = opts or {}
  if not item or not item.code_path then
    notify("没有可插入的代码文件", vim.log.levels.ERROR)
    return
  end

  local lines = read_lines(item.code_path)
  if not lines then
    return
  end

  if opts.fold_markers then
    local old = config.get().insert.fold_markers
    config.get().insert.fold_markers = true
    lines = with_fold_markers(lines, item)
    config.get().insert.fold_markers = old
  else
    lines = with_fold_markers(lines, item)
  end

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local row = vim.api.nvim_win_get_cursor(win)[1]
  vim.api.nvim_buf_set_lines(buf, row - 1, row - 1, false, lines)
  notify("已插入: " .. vim.fn.fnamemodify(item.code_path, ":t"))
end

function M.copy_code(item)
  -- 同时写入系统剪贴板和默认寄存器，方便在 Neovim 内外复用。
  if not item or not item.code_path then
    notify("没有可复制的代码文件", vim.log.levels.ERROR)
    return
  end

  local lines = read_lines(item.code_path)
  if not lines then
    return
  end

  vim.fn.setreg("+", table.concat(lines, "\n"))
  vim.fn.setreg('"', table.concat(lines, "\n"))
  notify("已复制: " .. vim.fn.fnamemodify(item.code_path, ":t"))
end

function M.open_code(item)
  if item and item.code_path then
    vim.cmd.edit(vim.fn.fnameescape(item.code_path))
  end
end

function M.open_code_root()
  local code_root = paths.code_root()
  if code_root then
    vim.cmd.edit(vim.fn.fnameescape(code_root))
  end
end

return M
