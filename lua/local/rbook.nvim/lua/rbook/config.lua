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

    -- 是否按当前 buffer 的 filetype 收窄 RbookCodeFiles / RbookCode 的候选。
    -- 命令加 ! 可临时绕过（:RbookCodeFiles! / :RbookCode!）。
    filter_by_filetype = true,

    -- filetype -> 允许的扩展名。
    -- 没在这里登记的 filetype 一律不过滤 —— 所以在 markdown / text / 无 filetype
    -- 的 buffer（:enew）里执行命令仍然是“看全部”，这本身就是一个出口。
    -- c / h / hpp 与 cpp 归为一族（OI 单文件很少写头文件，但归在一起更符合直觉）。
    filetype_extensions = {
      cpp = { "cpp", "cc", "cxx" },
      c = { "cpp", "cc", "cxx" },
      h = { "cpp", "cc", "cxx" },
      hpp = { "cpp", "cc", "cxx" },
      python = { "py" },
    },
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
