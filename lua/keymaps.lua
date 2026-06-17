local opts = {
    noremap = true,      -- 非递归
    silent = true,       -- 不显示消息
}

-- Normal: 窗口移动
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Normal: 调整窗口大小，增量为 2 行/列。
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Visual: 缩进后保持选区，方便连续调整缩进。
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- 保存
vim.keymap.set('n', '<C-s>', ':w<CR>', opts)
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', opts)

-- Insert: 行内快速跳转
vim.keymap.set('i', '<C-l>', '<C-o>$',  { noremap = true, silent = true, desc = 'Move to end of line' })
vim.keymap.set('i', '<C-h>', '<C-o>^', { noremap = true, silent = true, desc = 'Move to beginning of line' })

-- 移动当前行
vim.keymap.set('n', '<A-Down>', ':m .+1<CR>==', opts)
vim.keymap.set('i', '<A-Down>', '<Esc>:m .+1<CR>==gi', opts)
vim.keymap.set('n', '<A-Up>', ':m .-2<CR>==', opts)
vim.keymap.set('i', '<A-Up>', '<Esc>:m .-2<CR>==gi', opts)

-- 下面的快捷键 不一定 有用, 因为终端的问题
-- ctrl-enter 在当前行下方插入新行
-- vim.keymap.set('n', '<C-CR>', 'o<Esc>', opts)
-- vim.keymap.set('i', '<C-CR>', '<Esc>o', opts)

-- ctrl-shift-enter 在当前行上方插入新行
-- vim.keymap.set('n', '<C-S-CR>', 'O<Esc>', opts)
-- vim.keymap.set('i', '<C-S-CR>', '<Esc>O', opts)

-- LuaSnip: choice 节点切换
vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})
