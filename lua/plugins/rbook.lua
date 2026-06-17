return {
  -- rbook.nvim 位于电子书仓库的 nvim/ 子目录。
  -- 插件本身完全离线读取 repo_root/book 下的文章和代码模板。
  dir = vim.fn.expand("~/mycode/rbook_nunjucks/nvim"),

  name = "rbook.nvim",

  lazy = true,
  cmd = {
    "RbookCode",
    "RbookCodeFiles",
    "RbookCodeRefresh",
    "RbookOpenArticle",
    "RbookDoctor",
  },

  dev = true,

  dependencies = {
    "folke/snacks.nvim",
  },

  opts = {
    repo_root = vim.fn.expand("~/mycode/rbook_nunjucks"),
  },

  config = function(_, opts)
    -- rbook.nvim 使用 lyaml。这里把用户级 luarocks 5.1 路径加入 Neovim，
    -- 这样 `luarocks --lua-version=5.1 --local install lyaml` 后可以直接被 require 到。
    local luarocks = vim.fn.expand("~/.luarocks")
    package.path = package.path
      .. ";" .. luarocks .. "/share/lua/5.1/?.lua"
      .. ";" .. luarocks .. "/share/lua/5.1/?/init.lua"
    package.cpath = package.cpath
      .. ";" .. luarocks .. "/lib/lua/5.1/?.so"

    require("rbook").setup(opts)
  end,

  keys = {
    { "<leader>rc", "<cmd>RbookCode<cr>", desc = "Rbook 正式代码模板" },
    { "<leader>rf", "<cmd>RbookCodeFiles<cr>", desc = "Rbook 浏览全部代码文件" },
    { "<leader>ra", "<cmd>RbookOpenArticle<cr>", desc = "Rbook 打开文章" },
    { "<leader>rr", "<cmd>RbookCodeRefresh<cr>", desc = "Rbook 刷新索引" },
    { "<leader>rd", "<cmd>RbookDoctor<cr>", desc = "Rbook 检查模板索引" },
  },
}
