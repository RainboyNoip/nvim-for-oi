-- help doc: https://neovim.io/doc/user/lsp.html
vim.lsp.config['clangd'] = require('lsp.clangd')
vim.lsp.enable( "clangd" )


-- vim.lsp.config['haskell'] = require('lsp.haskell')
-- vim.lsp.enable( "haskell" )
