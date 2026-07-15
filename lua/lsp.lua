-- help: https://neovim.io/doc/user/lsp.html
vim.lsp.config['clangd'] = require('lsp.clangd')
vim.lsp.enable("clangd")

vim.lsp.config["basedpyright"] = require("lsp.basedpyright")

if vim.fn.executable("basedpyright-langserver") == 1 then
  vim.lsp.enable("basedpyright")
else
  local group = vim.api.nvim_create_augroup("RainboyPythonLspMissing", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "python",
    once = true,
    callback = function()
      vim.notify(
        "Python LSP is unavailable. Run `uv tool install basedpyright`; "
          .. "see docs/how-to-use-in-python.md.",
        vim.log.levels.WARN,
        { title = "BasedPyright" }
      )
    end,
  })
end
