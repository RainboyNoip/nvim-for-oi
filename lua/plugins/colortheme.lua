return {

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
                Themify.set_current("folke/tokyonight.nvim","tokyonight-night")
            end
        }
    },

}
