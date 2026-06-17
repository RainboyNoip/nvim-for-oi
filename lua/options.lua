-- 基础编辑行为
vim.opt.clipboard = 'unnamedplus' -- 使用系统剪贴板
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.mouse = 'a' -- 允许鼠标操作

-- 缩进：OJ/C++ 和 Python 都统一使用 4 空格。
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- 界面显示
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.showmode = false -- 状态栏已经显示模式，不需要默认的 "-- INSERT --"。
vim.opt.signcolumn = "auto:2-3" -- 固定 sign column 宽度，避免诊断标记推动代码。

-- 搜索
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 折叠：配合 oiSnippets 插入的 //oisnip_begin / //oisnip_end。
vim.opt.foldenable = true
vim.opt.foldmethod = "marker"
vim.opt.foldmarker = { "//oisnip_begin", "//oisnip_end" }
vim.opt.foldlevel = 99
-- opt.foldopen:append("all")
-- opt.foldopen:append("hor") -- open folds when opening a horizontal split

-- 文件状态
vim.opt.undofile = true
-- vim.opt.undodir = vim.fn.stdpath('config') .. '/undodir'
vim.opt.swapfile = false

-- 注释续行
vim.opt.formatoptions:remove({ 'r', 'o' })

-- 不知道那个插件设置了这个，导致在cpp文件中，按o会自动插入注释
local group = vim.api.nvim_create_augroup('MyFormatOptions', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'c,cpp',
    group = group,
    callback = function()
        vim.opt_local.formatoptions:remove({ 'r', 'o' })
    end,
})

-- 自动保存
vim.opt.autowrite = true        -- 在执行某些命令时自动保存
vim.opt.autowriteall = true     -- 在更多情况下自动保存
vim.opt.autoread = true         -- 文件被外部修改时自动重新加载

local autosave_group = vim.api.nvim_create_augroup('AutoSave', { clear = true })
vim.api.nvim_create_autocmd({ 'InsertLeave', 'FocusLost', 'BufLeave' }, {
    group = autosave_group,
    pattern = '*',
    callback = function()
        -- 只对有文件名的缓冲区进行自动保存
        if vim.fn.expand('%') ~= '' then
            vim.cmd('silent! write')
        end
    end,
})

-- LSP 诊断
vim.diagnostic.config({
    virtual_text = true,           -- 在代码行末尾显示诊断信息
    underline = true,              -- 在错误下方显示下划线
    update_in_insert = false,      -- 在插入模式下不更新诊断
    severity_sort = true,          -- 按严重程度排序诊断信息
    float = {
        source = "always",         -- 在悬浮窗口中显示诊断来源
        border = "rounded",        -- 悬浮窗口边框样式
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        },
        texthl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
    },
})
