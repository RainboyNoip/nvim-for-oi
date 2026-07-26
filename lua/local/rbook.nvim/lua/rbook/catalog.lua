local scanner = require("rbook.scanner")

local M = {
  -- 内存缓存。文章数量不少，避免每次打开 picker 都重新扫全仓库。
  current = nil,
}

function M.refresh()
  M.current = scanner.scan()
  return M.current
end

function M.get()
  if not M.current then
    return M.refresh()
  end
  return M.current
end

return M
