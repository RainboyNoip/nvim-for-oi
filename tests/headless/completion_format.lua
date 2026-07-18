local function run()
  local cmp = require("cmp")
  local lspkind = require("lspkind")
  local format = cmp.get_config().formatting.format

  assert(type(format) == "function", "nvim-cmp formatter is not configured")

  for _, kind in ipairs({ "Class", "Text" }) do
    local icon = assert(lspkind.symbol_map[kind], "missing lspkind icon for " .. kind)
    local item = format({ source = { name = "nvim_lsp" } }, {
      abbr = "Example" .. kind,
      icon = icon,
      kind = kind,
      menu = "",
    })

    assert(item.icon == icon, kind .. " must keep exactly one icon in the icon field")
    assert(item.kind == kind, kind .. " kind field must contain text only: " .. vim.inspect(item.kind))
    assert(item.menu == "[LSP]", kind .. " source label changed: " .. vim.inspect(item.menu))
  end
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
  return
end

print("completion_format: ok")
