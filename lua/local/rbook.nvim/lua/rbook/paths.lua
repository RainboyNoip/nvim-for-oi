local config = require("rbook.config")

local M = {}

local function normalize(path)
  if not path or path == "" then
    return nil
  end
  local normalized = vim.fn.fnamemodify(path, ":p"):gsub("/$", "")
  return vim.fs.normalize(normalized)
end

function M.code_yaml_path()
  local opts = config.get()
  return normalize(opts.code_yaml_path)
end

function M.code_root()
  local opts = config.get()
  if opts.code_root then
    return normalize(opts.code_root)
  end
  local yaml_path = M.code_yaml_path()
  if yaml_path then
    local yaml_dir = vim.fs.dirname(yaml_path)
    return normalize(yaml_dir .. "/code")
  end
  return nil
end

function M.join(...)
  return vim.fs.normalize(table.concat({ ... }, "/"))
end

function M.exists(path)
  return path and vim.uv.fs_stat(path) ~= nil
end

function M.relative(path, root)
  path = vim.fs.normalize(path)
  root = vim.fs.normalize(root)
  root = root:gsub("/$", "")
  if path:sub(1, #root + 1) == root .. "/" then
    return path:sub(#root + 2)
  end
  return path
end


return M
