-- 定义通用选项
local opts = {
    noremap = true,      -- 非递归
    silent = true,       -- 不显示消息
}

-----------------
-- Normal mode --
-----------------

-- 提示：查看 `:h vim.map.set()`
-- 更好的窗口跳转
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- 使用箭头调整大小
-- 增量：2行
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
-- vim.keymap.set('v', '>', '>gv', opts)：
    -- 这个设置覆盖了默认的 > 行为。在可视模式下选中一些代码后，
    -- 按 > 会将它们向右缩进。紧接着 gv 会重新选中你刚才选中的区域。
    -- 这样一来，你就可以连续多次按 > 来增加缩进，而不需要每次都重新手动选择代码块。
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)


-- 保存快捷键
vim.keymap.set('n', '<C-s>', ':w<CR>', opts)
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', opts)