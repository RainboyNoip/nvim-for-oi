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

            { "<leader>o", group = "oi snip", desc = "debug:nvim-dap short keys" },
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
    },
}
