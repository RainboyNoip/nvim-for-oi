return {
    {
        "bluz71/vim-nightfly-colors",
        lazy = false,
        priority = 1000,
    },

    {
        'lmantw/themify.nvim',
        lazy = false,
        priority = 999,

        -- 主题统一交给 themify 管理，需要切换时使用 :Themify。
        config = {
            'folke/tokyonight.nvim',
            'sho-87/kanagawa-paper.nvim',
            "ellisonleao/gruvbox.nvim",
            "rebelot/kanagawa.nvim",
            "bluz71/vim-nightfly-colors",
            "bluz71/vim-moonfly-colors",
            {
                'everviolet/nvim',
            },

            loader = function ()
                local Themify = require('themify.api')
                local ok = pcall(Themify.set_current, "bluz71/vim-nightfly-colors", "nightfly")

                if not ok then
                    vim.cmd.colorscheme("moonfly")
                end
            end
        }
    },

}
