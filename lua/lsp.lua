-- help: https://neovim.io/doc/user/lsp.html
-- LSP client capabilities 必须在 server 启动前注册。nvim-cmp 本身在 InsertEnter
-- 才加载，如果把这段留在 cmp 的 config 里，已经启动的 LSP 收不到完整能力。
local cmp_lsp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_lsp_ok then
  vim.lsp.config("*", { capabilities = cmp_lsp.default_capabilities() })
end

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
