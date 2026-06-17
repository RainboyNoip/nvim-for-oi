local picker_keys = require("plugins.snacks.picker").keys()

return {
    "folke/snacks.nvim",
    ---@type snacks.Config
    lazy = false,
    priority = 1001,
    opts = {
        dashboard = require("plugins.snacks.dashboard"),
        explorer = {},
        zen = {},
        notifier = { timeout = 5000 },
        terminal = {
            win = {
                position = "float",
                width = 0.8,
                height = 0.7,
                border = "rounded",
                wo = {
                    winblend = 10,
                }
            },
            interactive = true,
            auto_insert = true,
            auto_close = false,
        },
        styles = {
            zen = {
                backdrop = {
                    transparent = false,
                    blend = 90,
                }
            }
        }
    },
    keys = vim.list_extend({
        {
            "<leader>e",
            function()
                require("snacks").explorer()
            end,
            desc = "Toggle Snacks Explorer",
        },
        {
            "<leader>t",
            group = "Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>tt",
            function()
                require("snacks.terminal").toggle()
            end,
            desc = "Toggle Snacks Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>tc",
            function()
                require("plugins.snacks.terminal").select_toggle()
            end,
            desc = "Select Snacks Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>tf",
            function()
                require("snacks.terminal").get("bash", { auto_close = false })
            end,
            desc = "Open Snacks Terminal",
            mode = { "n", "t" },
        },
    }, picker_keys)
}
