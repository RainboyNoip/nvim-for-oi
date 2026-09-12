return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        -- 图标本来是默认开着的（icons.mappings = true），但 which-key 内置的
        -- icons.rules 只匹配英文（terminal / find / search / git / test …），
        -- 而本配置的 desc 全是中文，所以一条都命中不了 —— 这才是"看不到图标"的原因，
        -- 不是功能没开。下面直接给每个菜单项显式指定图标，不依赖规则匹配。
        --
        -- 图标用的是 Nerd Font 的规范字形名（cod-*/fa-*），每一个都拿本机字体
        -- JetBrainsLxgwNerdMono 的 post 字形名表 + cmap 逐个核对过，不是猜的。
        -- ⚠ 该字体里这些图标的 advance 是 1200/1000em，即**双宽**（和中文一样宽），
        --   而 Neovim 把 PUA 码点算作 1 格。因为每个菜单项都恰好有一个图标，
        --   整列会一起右移 1 格，行与行仍然对齐；只有"有的项有图标、有的没有"
        --   的菜单才会错开 1 格。
        -- 颜色只能取 which-key 内置的 9 种：
        --   azure blue cyan green grey orange purple red yellow
        -- 组名前面那个 "+" 是 which-key 默认的 icons.group，想去掉就设 icons.group = ""。
    },
    config = function()
        local wk = require("which-key")

        wk.add({
            -- ── 顶层：8 个组 / 独立键 ──────────────────────────────────
            { "<leader>?", icon = { icon = "", color = "cyan" } }, -- 当前 buffer 快捷键 (cod-question U+EB32)
            { "<leader>b", group = "buffer", icon = { icon = "", color = "azure" } }, -- group: buffer (cod-multiple_windows U+EB23)
            { "<leader>c", group = "注释", icon = { icon = "", color = "green" } }, -- group: 注释 (cod-comment U+EA6B)
            { "<leader>e", icon = { icon = "", color = "orange" } }, -- 切换文件浏览器 (cod-folder_opened U+EAF7)
            { "<leader>o", group = "OI / 模板", icon = { icon = "", color = "purple" } }, -- group: OI / 模板 (fa-code U+F121)
            { "<leader>r", group = "Rbook 题解 / 模板", icon = { icon = "", color = "blue" } }, -- group: Rbook (cod-book U+EAA4)
            { "<leader>s", group = "搜索 / 跳转", icon = { icon = "", color = "yellow" } }, -- group: 搜索 / 跳转 (cod-search U+EA6D)
            { "<leader>t", group = "终端", icon = { icon = "", color = "red" } }, -- group: 终端 (cod-terminal U+EA85)
            { "<leader>bP", icon = "" }, -- 关闭未固定 buffer (cod-close_all U+EAC1)
            { "<leader>bl", icon = "" }, -- 关闭左侧 buffer (cod-arrow_left U+EA9B)
            { "<leader>bp", icon = "" }, -- 固定 / 取消固定 buffer (cod-pin U+EB2B)
            { "<leader>br", icon = "" }, -- 关闭右侧 buffer (cod-arrow_right U+EA9C)
            { "<leader>cb", icon = "" }, -- 切换块注释 (cod-comment_discussion U+EAC7)
            { "<leader>cc", icon = "" }, -- 切换行注释 (cod-comment U+EA6B)
            { "<leader>oe", icon = "" }, -- Rbook 浏览代码文件 (cod-list_tree U+EB86)
            { "<leader>of", icon = "" }, -- Rbook 正式代码模板 (cod-notebook_template U+EBBF)
            { "<leader>oh", icon = "" }, -- Rainboy 速查表 (fa-question U+F128)
            { "<leader>op", icon = "" }, -- 复制当前 buffer (cod-copy U+EBCC)
            { "<leader>os", icon = "" }, -- file snippets (cod-symbol_snippet U+EB66)
            { "<leader>rc", icon = "" }, -- Rbook 正式代码模板 (cod-notebook_template U+EBBF)
            { "<leader>rd", icon = "" }, -- Rbook 检查模板索引 (cod-checklist U+EAB3)
            { "<leader>rf", icon = "" }, -- Rbook 浏览代码文件 (cod-list_tree U+EB86)
            { "<leader>rr", icon = "" }, -- Rbook 刷新索引 (cod-refresh U+EB37)
            { "<leader>sD", icon = "" }, -- 当前 buffer 诊断 (cod-error U+EA87)
            { "<leader>sb", icon = "" }, -- Buffer 列表 (cod-multiple_windows U+EB23)
            { "<leader>sc", icon = "" }, -- 当前文件更改位置 (cod-git_commit U+EAFC)
            { "<leader>sd", icon = "" }, -- 项目诊断 (cod-warning U+EA6C)
            { "<leader>sf", icon = "" }, -- 当前文件符号 (cod-symbol_class U+EB5B)
            { "<leader>sj", icon = "" }, -- 跳转历史 (cod-history U+EA82)
            { "<leader>sz", icon = "" }, -- 专注模式 (cod-screen_full U+EB4C)
            { "<leader>tc", icon = "" }, -- 选择已有终端 (cod-terminal_bash U+EBCA)
            { "<leader>tf", icon = "" }, -- 打开 Bash 终端 (cod-terminal U+EA85)
            { "<leader>tt", icon = "" }, -- 切换终端 (cod-terminal U+EA85)
        })
    end,
    keys = {
        {'g;', 'g;', desc = '跳转到 [上] 一个编辑点 (Change List)'},
        {'g,', 'g,', desc = '跳转到 [下] 一个编辑点 (Change List)'},
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "当前 buffer 快捷键",
        },
        {
            "<leader>op",
            function()
                Snacks.picker.select(
                { "pbcopy","pcopy copy","wl-copy" },
                {
                    prompt = "Select Server to Paste:",
                },
                function(item)
                    if not item then return end
                    local output = vim.trim(vim.api.nvim_command_output("%w !" .. item))
                    if output ~= "" then
                        vim.notify(output, vim.log.levels.INFO, { title = "Command Output" })
                    else
                        vim.notify("Buffer content copied via " .. item, vim.log.levels.INFO, { title = "Success" })
                    end
                end
            )
            end,
            desc = "复制当前 buffer",

        },
        {
            "<leader>oh",
            function()
                require("cheatsheet").show()
            end,
            desc = "Rainboy 速查表",
        }
    },
}
