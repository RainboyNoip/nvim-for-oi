-- 我写的rbook 作为插件
-- return {
--     'rainboyOJ/rbook_nunjucks',
--     lazy = false,
--     config = function()
--         require('rbook').setup()
--         print("rbook loaded")
--     end,
-- }

-- 在你的 lazy.nvim 配置中的某个文件里

return {
  -- 插件的本地路径
  -- 我们使用 vim.fn.expand 来正确处理 "~"
  dir = vim.fn.expand("~/mycode/rbook_nunjucks"),

  -- 强制指定一个名字，这样在其他地方引用会很方便
  -- 如果不指定，lazy.nvim 会根据目录名 'my_plugin' 来推断
  name = "rbook",
  
  -- 确保插件不会被懒加载
  -- 因为我正在开发这个插件，所以需要立即加载
  lazy = false,

  -- ！！！这是最关键的一步！！！
  -- 启用开发模式，这使得 :Lazy reload <插件名> 命令可用
  dev = true,

  -- 如果你的插件有其他依赖，也在这里列出
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    require('rbook').setup()
    local TemplateEngine = require("rbook.template_engine")
    TemplateEngine.setup({
      vars = {
        name = "rainboy",
        blog = "https://blog.roj.ac.cn",
        github = 'https://github.com/rainboylvx',
      }
    })
  end,
  -- 如果你的插件有配置项，在这里设置

  -- 插件的配置项
  keys = {
    { "<leader>ot", "<cmd>ApplyTempCpp<cr>", desc = "使用Rbook template.cpp" },
  }
}