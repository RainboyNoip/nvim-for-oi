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
    -- 路径来源：环境变量 RBOOK_CODE_YAML 优先，没设时回退到默认位置。
    -- 故意不写成“纯环境变量”：vim.env.X 未设置时是 nil，如果在 GUI / sudo /
    -- 另一个 shell 起的 tmux / 新机器上启动 nvim，路径会静默变 nil，插件不报错
    -- 但模板功能直接没了（只能靠 :RbookDoctor 发现）。
    -- 末尾再走一次 expand()：这样环境变量里写 ~ 或 $HOME 也能展开。
    --
    -- 保底路径请跟着仓库真实位置走：它之前是 ~/mycode/rbook_nunjucks/book/code.yaml，
    -- 仓库被移进“教程与书籍/”之后那个路径就不存在了，而插件是不报错的。
    code_yaml_path = vim.fn.expand(
      vim.env.RBOOK_CODE_YAML or "~/mycode/教程与书籍/rbook_nunjucks/book/code.yaml"
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
