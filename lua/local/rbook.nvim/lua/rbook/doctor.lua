local catalog = require("rbook.catalog")
local paths = require("rbook.paths")
local config = require("rbook.config")

local M = {}

local function add(lines, level, text)
  lines[#lines + 1] = string.format("[%s] %s", level, text)
end

local function code_exists(item)
  return item.code_path and paths.exists(item.code_path)
end

function M.run()
  local data = catalog.refresh()
  if not data then
    return
  end

  local lines = { "# Rbook Doctor", "" }
  local errors = 0
  local warnings = 0

  local opts = config.get()
  local yaml_path = paths.code_yaml_path()
  local code_root = paths.code_root()

  add(lines, "INFO", "code_yaml_path: " .. (yaml_path or "未配置"))
  add(lines, "INFO", "code_root: " .. (code_root or "未推导"))

  if not yaml_path then
    errors = errors + 1
    add(lines, "ERROR", "未配置 code_yaml_path")
  elseif not paths.exists(yaml_path) then
    errors = errors + 1
    add(lines, "ERROR", "code.yaml 不存在: " .. yaml_path)
  else
    add(lines, "OK", "code.yaml 存在")
  end

  if not code_root then
    errors = errors + 1
    add(lines, "ERROR", "code_root 无法推导")
  elseif not paths.exists(code_root) then
    errors = errors + 1
    add(lines, "ERROR", "code_root 不存在: " .. code_root)
  else
    add(lines, "OK", "code_root 存在")
  end

  for _, err in ipairs(data.errors or {}) do
    errors = errors + 1
    add(lines, "ERROR", err)
  end

  local code_ref_count = {}
  for _, item in ipairs(data.templates) do
    if not code_exists(item) then
      errors = errors + 1
      add(lines, "ERROR", "模板代码不存在: " .. (item.desc or "") .. " (" .. (item.id or "") .. ")")
    end

    if item.code_path then
      code_ref_count[item.code_path] = (code_ref_count[item.code_path] or 0) + 1
    end
  end

  for file, count in pairs(code_ref_count) do
    if count > 1 then
      warnings = warnings + 1
      add(lines, "WARN", "同一代码被多个模板引用: " .. (code_root and paths.relative(file, code_root) or file))
    end
  end

  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("templates=%d, code_files=%d, errors=%d, warnings=%d", #data.templates, #data.code_files, errors, warnings)

  vim.cmd("new")
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, "RbookDoctor")
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

return M
