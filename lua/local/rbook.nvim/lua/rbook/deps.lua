local M = {}

function M.lyaml()
  -- lyaml 是运行时依赖：只有真的扫描目录时才需要它。
  -- 这样缺依赖不会拖垮 Neovim 启动，只在用户执行 Rbook 命令时提示。
  local ok, lyaml = pcall(require, "lyaml")
  if ok then
    return lyaml
  end

  vim.notify(
    "rbook.nvim 需要 lyaml 来解析 code.yaml。\n请执行：luarocks install lyaml",
    vim.log.levels.ERROR
  )
  return nil
end

function M.snacks()
  -- snacks.nvim 只负责 picker UI；核心索引逻辑不依赖它。
  local ok, snacks = pcall(require, "snacks")
  if ok then
    return snacks
  end

  vim.notify("rbook.nvim 需要 folke/snacks.nvim。", vim.log.levels.ERROR)
  return nil
end

return M
