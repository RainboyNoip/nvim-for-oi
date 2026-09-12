-- 解析 code.yaml 的位置。两级：
--   1. 环境变量 RBOOK_CODE_YAML（仅当文件确实存在时采用）
--   2. 本仓库自带的 mini 模板库 mini_rbook_code_template/code.yaml
-- 放在 config() 里而不是 opts 里，有两个原因：
--   ① opts 在启动期就会被求值，而告警只应该在真的用到 rbook 时才出现；
--   ② 环境变量写了但文件不在（换了机器、书库又搬家）时能退到 mini 库，而不是
--      把插件直接搞坏 —— 这一点很实际，因为 ~/.zshrc 的 alias v 里就是绝对路径。
local function resolve_code_yaml_path()
  local from_env = vim.env.RBOOK_CODE_YAML
  if from_env and from_env ~= "" then
    from_env = vim.fn.expand(from_env)
    if vim.uv.fs_stat(from_env) then
      return from_env
    end
    vim.notify(
      ("rbook: RBOOK_CODE_YAML 指向的 code.yaml 不存在，已回退到仓库自带模板库\n  %s"):format(from_env),
      vim.log.levels.WARN
    )
  end
  return vim.fn.stdpath("config") .. "/mini_rbook_code_template/code.yaml"
end

return {
  dir = vim.fn.stdpath("config") .. "/lua/local/rbook.nvim",
  name = "rbook.nvim",

  lazy = true,
  cmd = {
    "RbookCode",
    "RbookCodeFiles",
    "RbookCodeRefresh",
    "RbookDoctor",
  },

  dependencies = {
    "folke/snacks.nvim",
  },

  -- 路径在 config() 里由 resolve_code_yaml_path() 填入，见文件顶部。
  opts = {},

  config = function(_, opts)
    local luarocks = vim.fn.expand("~/.luarocks")
    package.path = package.path
      .. ";" .. luarocks .. "/share/lua/5.1/?.lua"
      .. ";" .. luarocks .. "/share/lua/5.1/?/init.lua"
    package.cpath = package.cpath
      .. ";" .. luarocks .. "/lib/lua/5.1/?.so"

    opts.code_yaml_path = resolve_code_yaml_path()
    require("rbook").setup(opts)

    -- 路径不对时插件是静默失效的（catalog 拿不到数据，只有 :RbookDoctor 会提），
    -- 所以加载时主动告警一次，避免再次出现"模板怎么没了"这种无声故障。
    local paths = require("rbook.paths")
    local yaml = paths.code_yaml_path()
    if not paths.exists(yaml) then
      vim.notify(
        ("rbook: code.yaml 不存在：%s\n可设环境变量 RBOOK_CODE_YAML 覆盖，或改 lua/plugins/rbook.lua"):format(
          tostring(yaml)
        ),
        vim.log.levels.WARN
      )
    end
  end,

  keys = {
    { "<leader>rc", "<cmd>RbookCode<cr>", desc = "Rbook 正式代码模板（按当前语言）" },
    { "<leader>rf", "<cmd>RbookCodeFiles<cr>", desc = "Rbook 浏览代码文件（按当前语言）" },
    { "<leader>rr", "<cmd>RbookCodeRefresh<cr>", desc = "Rbook 刷新索引" },
    { "<leader>rd", "<cmd>RbookDoctor<cr>", desc = "Rbook 检查模板索引" },
  },
}
