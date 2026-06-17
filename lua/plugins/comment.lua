return {
  'numToStr/Comment.nvim',
  opts = {
    -- 在这里可以添加插件选项
  },
  lazy = false,
  config = function(_, opts)
    require('Comment').setup(opts)

    local api = require('Comment.api')
    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)

    local function toggle_linewise_visual()
      vim.api.nvim_feedkeys(esc, 'nx', false)
      api.toggle.linewise(vim.fn.visualmode())
    end

    local function toggle_blockwise_visual()
      vim.api.nvim_feedkeys(esc, 'nx', false)
      api.toggle.blockwise(vim.fn.visualmode())
    end

    -- 终端里 Ctrl+/ 常常会被发送成 <C-_>，两个都绑定到行注释。
    vim.keymap.set('n', '<C-/>', api.toggle.linewise.current, { desc = '切换行注释' })
    vim.keymap.set('n', '<C-_>', api.toggle.linewise.current, { desc = '切换行注释' })
    vim.keymap.set('x', '<C-/>', toggle_linewise_visual, { desc = '切换行注释' })
    vim.keymap.set('x', '<C-_>', toggle_linewise_visual, { desc = '切换行注释' })

    vim.keymap.set('n', '<leader>cc', api.toggle.linewise.current, { desc = '切换行注释' })
    vim.keymap.set('x', '<leader>cc', toggle_linewise_visual, { desc = '切换行注释' })
    vim.keymap.set('n', '<leader>cb', api.toggle.blockwise.current, { desc = '切换块注释' })
    vim.keymap.set('x', '<leader>cb', toggle_blockwise_visual, { desc = '切换块注释' })
  end,
}
