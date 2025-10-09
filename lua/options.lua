-- Hint: use `:h <option>` to figure out the meaning if needed
vim.opt.clipboard = 'unnamedplus' -- use system clipboard
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.mouse = 'a' -- allow the mouse to be used in nvim

-- Tab
vim.opt.tabstop = 4 -- number of visual spaces per TAB
vim.opt.softtabstop = 4 -- number of spaces in tab when editing
vim.opt.shiftwidth = 4 -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of Python

-- UI config
vim.opt.number = true -- show absolute number
vim.opt.relativenumber = true -- add numbers to each line on the left side
vim.opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
vim.opt.splitbelow = true -- open new vertical split bottom
vim.opt.splitright = true -- open new horizontal splits right
-- vim.opt.termguicolors = true        -- enable 24-bit RGB color in the TUI
vim.opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint

-- Searching
vim.opt.incsearch = true -- search as characters are entered
vim.opt.hlsearch = false -- do not highlight matches
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered

-- enable fold
vim.opt.foldenable = true
vim.opt.foldmethod = "marker" -- use marker to fold code
vim.opt.foldmarker = { "//oisnip_begin", "//oisnip_end" }
vim.opt.foldlevel = 99
-- open all folds by default
-- opt.foldopen:append("all")
-- opt.foldopen:append("hor") -- open folds when opening a horizontal split

-- undofile
vim.opt.undofile = true -- save undo history
-- vim.opt.undodir = vim.fn.stdpath('config') .. '/undodir'
vim.opt.swapfile = false -- don't use swapfile


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

-- 设置 sign column 固定宽度，避免文字推动
vim.opt.signcolumn = "auto:2-3"  -- 自动调整，但最少2-3个字符宽度

-- LSP 诊断配置
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
