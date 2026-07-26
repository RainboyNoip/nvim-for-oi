local function assert_equal(actual, expected, label)
  assert(vim.deep_equal(actual, expected), string.format(
    "%s: expected %s, got %s",
    label,
    vim.inspect(expected),
    vim.inspect(actual)
  ))
end

local function run()
  local calls = {}

  package.loaded["rbook.picker"] = {
    code = function()
      calls.code = (calls.code or 0) + 1
    end,
    code_files = function()
      calls.code_files = (calls.code_files or 0) + 1
    end,
  }
  package.loaded["rbook.catalog"] = {
    refresh = function()
      calls.refresh = (calls.refresh or 0) + 1
      return {}
    end,
  }
  package.loaded["rbook.doctor"] = {
    run = function()
      calls.doctor = (calls.doctor or 0) + 1
    end,
  }

  local plugin = assert(require("lazy.core.config").plugins["rbook.nvim"], "rbook.nvim plugin spec is missing")
  assert(not plugin._.loaded, "rbook.nvim must be lazy before its first command")

  vim.cmd("RbookCode")
  assert(plugin._.loaded, "RbookCode must load rbook.nvim")
  assert_equal(calls.code, 1, "RbookCode dispatch")

  vim.cmd("RbookCodeFiles")
  vim.cmd("RbookCodeRefresh")
  vim.cmd("RbookDoctor")

  assert_equal(calls.code_files, 1, "RbookCodeFiles dispatch")
  assert_equal(calls.refresh, 1, "RbookCodeRefresh dispatch")
  assert_equal(calls.doctor, 1, "RbookDoctor dispatch")

  local registered = vim.api.nvim_get_commands({})
  for _, name in ipairs({ "RbookCode", "RbookCodeFiles", "RbookCodeRefresh", "RbookDoctor" }) do
    assert(registered[name], name .. " must remain registered after lazy loading")
  end
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
  return
end

print("rbook: ok")
