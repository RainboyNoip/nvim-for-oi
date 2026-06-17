-- help: https://neovim.io/doc/user/lsp.html
vim.lsp.config['clangd'] = require('lsp.clangd')
vim.lsp.enable( "clangd" )
