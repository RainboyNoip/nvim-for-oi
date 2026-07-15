local function run()
  local attached = vim.wait(10000, function()
    return #vim.lsp.get_clients({ bufnr = 0, name = "basedpyright" }) > 0
  end, 50)
  assert(attached, "basedpyright did not attach within 10 seconds")

  local received = vim.wait(10000, function()
    return #vim.diagnostic.get(0) > 0
  end, 50)
  assert(received, "basedpyright did not publish diagnostics within 10 seconds")

  local messages = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(0)) do
    table.insert(messages, diagnostic.message:lower())
  end

  local joined = table.concat(messages, "\n")
  assert(joined:find("not_defined", 1, true), "missing diagnostic for not_defined")
  assert(joined:find("not defined", 1, true), "not_defined diagnostic has unexpected wording")
  assert(not joined:find("not accessed", 1, true), "unused import diagnostic should be disabled")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
  return
end

print("python_lsp: ok")
