return {

    -- Gruvbox theme
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        enabled = true,
        config = function()
            vim.cmd.colorscheme("gruvbox")
        end,
    },

    -- "rebelot/kanagawa.nvim"
    {
        "rebelot/kanagawa.nvim",
        enabled = false,
        priority = 1000,
        opts = {
            -- transparent = true,
            theme = "wave",      -- Load "wave" theme when 'background' option is not set
            background = {       -- map the value of 'background' option to a theme
                dark = "dragon", -- try "dragon" !
                light = "lotus"
            },
        },
        config = function()
            -- vim.cmd.colorscheme("kanagawa")
            vim.cmd("colorscheme kanagawa-dragon")
        end,
    },
    -- "bluz71/vim-moonfly-colors"
    {
        "bluz71/vim-moonfly-colors",
        name = "moonfly",
        enabled = false,
        lazy = false,
        priority = 1000,
        config = function()
            -- vim.g.nightflyTransparent = false
            vim.cmd.colorscheme("moonfly")
        end,
    },
    -- "bluz71/vim-nightfly-colors"
    {
        "bluz71/vim-nightfly-colors",
        name = "nightfly",
        enabled = false,
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("nightfly")
        end,
    },

}
