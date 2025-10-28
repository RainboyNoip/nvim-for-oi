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

        --  手动添加 dap 快捷键 提示
        -- TODO fix: 为什么写在这里, 因为dap/keys.lua 写,可能不会 有好的提示
        -- 和 wk 加载的实践有关系
        wk.add({
            { "<leader>d", group = "dap : debug", desc = "debug:nvim-dap short keys" },

            { "<leader>o", group = "oi相关", desc = "debug:nvim-dap short keys" },
        })
    end,
    keys = {
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
                -- items
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
            desc = "select server to paste",

        }
    },
}
