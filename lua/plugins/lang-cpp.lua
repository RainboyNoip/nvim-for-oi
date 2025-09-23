return {
    dir = vim.fn.stdpath('config') .. '/lua/local/cpp-settings',
    -- 最关键的部分：只有在文件类型为 cpp 时才加载这个 "插件"
    dependencies = { "numToStr/Comment.nvim" },
    ft = { "cpp" ,"h","hpp"},
    config = function()
      require("cpp-settings").setup()
    end,
  }