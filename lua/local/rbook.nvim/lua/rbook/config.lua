local M = {}

-- 插件只保存轻量配置；真正扫描 book/code 的动作延迟到第一次命令执行。
M.defaults = {
  code_yaml_path = nil,
  code_root = nil,
  insert = {
    fold_markers = false,
  },
  files = {
    extensions = { "cpp", "cc", "cxx", "c", "h", "hpp", "py", "sh", "md", "hs" },
  },
  picker = {
    preview = true,
  },
}

M.options = vim.deepcopy(M.defaults)

local function merge(defaults, opts)
  return vim.tbl_deep_extend("force", defaults, opts or {})
end

function M.setup(opts)
  M.options = merge(vim.deepcopy(M.defaults), opts)
  return M.options
end

function M.get()
  return M.options
end

return M
