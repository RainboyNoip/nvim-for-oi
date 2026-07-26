local config = require("rbook.config")
local deps = require("rbook.deps")
local paths = require("rbook.paths")

local M = {}

local function read_file(path)
  local lines = vim.fn.readfile(path)
  if not lines then
    return nil
  end
  return table.concat(lines, "\n")
end

local function iter_files(root, predicate)
  local result = {}
  if not paths.exists(root) then
    return result
  end

  local function walk(dir)
    local handle = vim.uv.fs_scandir(dir)
    if not handle then
      return
    end

    while true do
      local name, t = vim.uv.fs_scandir_next(handle)
      if not name then
        break
      end
      local full = dir .. "/" .. name
      if t == "directory" then
        walk(full)
      elseif t == "file" and predicate(full) then
        result[#result + 1] = full
      end
    end
  end

  walk(root)
  table.sort(result)
  return result
end

local function list_contains(list, value)
  if type(list) ~= "table" then
    return false
  end
  for _, item in ipairs(list) do
    if item == value then
      return true
    end
  end
  return false
end

local function normalize_tags(value)
  if type(value) == "table" then
    return value
  end
  if type(value) == "string" and value ~= "" then
    return { value }
  end
  return {}
end

local function parse_code_yaml(lyaml)
  local yaml_path = paths.code_yaml_path()
  if not yaml_path or not paths.exists(yaml_path) then
    return nil, "code.yaml 不存在: " .. (yaml_path or "未配置 code_yaml_path")
  end

  local ok, data = pcall(lyaml.load, read_file(yaml_path))
  if not ok or type(data) ~= "table" then
    return nil, "code.yaml 解析失败: " .. tostring(data)
  end

  if type(data.codes) ~= "table" then
    return nil, "code.yaml 缺少 codes 字段"
  end

  return data.codes, nil
end

local function make_template(item)
  local code_root = paths.code_root()
  local code_abs = code_root and paths.join(code_root, item.path or "") or nil

  return {
    id = item.id,
    title = item.description or item.id,
    desc = item.path or "",
    language = item.language,
    tags = normalize_tags(item.tags),
    code_path = code_abs,
    source = "code_yaml",
  }
end

local function scan_templates(lyaml)
  local codes, err = parse_code_yaml(lyaml)
  if err then
    return nil, { err }
  end

  local templates = {}
  for _, item in ipairs(codes) do
    if type(item) == "table" and item.path then
      templates[#templates + 1] = make_template(item)
    end
  end

  return templates, {}
end

local function file_allowed(path)
  local ext = path:match("%.([%w_%-]+)$")
  if not ext then
    return false
  end
  return list_contains(config.get().files.extensions, ext)
end

local function scan_code_files()
  local code_root = paths.code_root()
  if not code_root then
    return {}
  end

  local files = iter_files(code_root, file_allowed)
  local result = {}

  for _, file in ipairs(files) do
    local rel = paths.relative(file, code_root)
    result[#result + 1] = {
      title = vim.fn.fnamemodify(file, ":t"),
      desc = rel,
      tags = {},
      code_path = file,
      source = "code_file",
      is_markdown = file:match("%.md$") ~= nil,
    }
  end

  return result
end

function M.scan()
  local lyaml = deps.lyaml()
  if not lyaml then
    return nil
  end

  local templates, errors = scan_templates(lyaml)
  if not templates then
    return nil
  end

  return {
    templates = templates,
    code_files = scan_code_files(),
    errors = errors,
    scanned_at = os.time(),
  }
end

return M
