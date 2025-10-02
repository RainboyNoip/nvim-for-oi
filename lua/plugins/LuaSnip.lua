return {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    config = function ()
        local ls = require("luasnip")
        -- Load VSCode snippets
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/vscode-snippets" } })
        require("luasnip.loaders.from_lua").load({ paths =  vim.fn.stdpath("config") .. "/lua-snippets"  })
        
        -- Set up keymaps
        vim.keymap.set({ "i" }, "<C-K>", function() ls.expand() end, { silent = true })
        vim.keymap.set({ "i" }, "<C-L>", function() ls.jump(1) end, { silent = true })
        vim.keymap.set({ "i" }, "<C-J>", function() ls.jump(-1) end, { silent = true })
        vim.keymap.set({ "i" }, "<C-E>", function() if ls.choice_active() then ls.change_choice(1) end end, { silent = true })
    end
}
