return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
    config = function()
        local wk = require("which-key")

        -- 这里补充按键组名称，让 which-key 的第一层提示更清楚。
        wk.add({
            { "<leader>c", group = "comment", desc = "注释" },
            { "<leader>d", group = "dap", desc = "调试" },
            { "<leader>o", group = "oi", desc = "OI / 模板" },
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
            desc = "Buffer Local Keymaps (which-key)",
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
            desc = "Rainboy Cheat Sheet",
        }
    },
}
