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
    code_yaml_path = vim.fn.expand("~/mycode/rbook_nunjucks/book/code.yaml"),
  },

  config = function(_, opts)
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
    { "<leader>rr", "<cmd>RbookCodeRefresh<cr>", desc = "Rbook 刷新索引" },
    { "<leader>rd", "<cmd>RbookDoctor<cr>", desc = "Rbook 检查模板索引" },
  },
}
