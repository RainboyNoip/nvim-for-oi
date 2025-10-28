return {
  'numToStr/Comment.nvim',
  opts = {
    -- 在这里可以添加插件选项
  },
  lazy = false,
  keys = {
    {
      '<c-/>',
      function()
        require('Comment.api').toggle.linewise(vim.fn.visualmode())
      end,
      mode = { 'n', 'v' },
      desc = 'Toggle comment'
    }
  }
}
