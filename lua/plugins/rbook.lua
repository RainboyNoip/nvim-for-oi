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

  opts = {
    -- 路径来源：环境变量 RBOOK_CODE_YAML 优先；没设时回退到**本仓库自带的 mini 模板库**
    -- （rbook/code.yaml + rbook/code/，只有 cpp / python 各一个骨架）。
    -- 这样在没有配环境变量的机器上（GUI/sudo/新机器）功能仍然可用，不会静默失效。
    -- 要用完整的书籍模板库就设：
    --   export RBOOK_CODE_YAML=~/mycode/教程与书籍/rbook_nunjucks/book/code.yaml
    --
    -- 注：stdpath("config") 已经被解析成绝对路径，expand() 主要是为了处理
    -- 环境变量里写 ~ 或 $HOME 的情况。
    code_yaml_path = vim.fn.expand(
      vim.env.RBOOK_CODE_YAML or (vim.fn.stdpath("config") .. "/rbook/code.yaml")
    ),
  },

  config = function(_, opts)
    local luarocks = vim.fn.expand("~/.luarocks")
    package.path = package.path
      .. ";" .. luarocks .. "/share/lua/5.1/?.lua"
      .. ";" .. luarocks .. "/share/lua/5.1/?/init.lua"
    package.cpath = package.cpath
      .. ";" .. luarocks .. "/lib/lua/5.1/?.so"

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
    { "<leader>rc", "<cmd>RbookCode<cr>", desc = "Rbook 正式代码模板" },
    { "<leader>rf", "<cmd>RbookCodeFiles<cr>", desc = "Rbook 浏览全部代码文件" },
    { "<leader>rr", "<cmd>RbookCodeRefresh<cr>", desc = "Rbook 刷新索引" },
    { "<leader>rd", "<cmd>RbookDoctor<cr>", desc = "Rbook 检查模板索引" },
  },
}
