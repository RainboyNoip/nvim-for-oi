-- snippet 资源的归档根目录。
--
-- 四组资产都归档在 all-snippets/ 下，但加载机制各不相同（见 CONTEXT.md 与
-- docs/adr/0001-snippet-asset-layout.md）：
--   lua-snippets/     LuaSnip 的 Lua 片段（LuaSnip.lua 显式注册入口）
--   vscode-snippets/  VSCode 格式 JSON（from_vscode.lazy_load）
--   oi-snippets/files/   file snippet（fileSnip.lua 的 picker）
--   oi-snippets/rbook/   rbook 模板（rbook.lua 的 code.yaml 兜底）
--
-- 这个路径原先分别硬编码在 LuaSnip.lua / fileSnip.lua / rbook.lua / 测试里，
-- 再调整归档结构时要四处同步（Shotgun Surgery）。改这里一处即可。
local M = {}

M.root = vim.fn.stdpath("config") .. "/all-snippets"
M.luaSnippets = M.root .. "/lua-snippets"
M.vscodeSnippets = M.root .. "/vscode-snippets"
M.fileSnippets = M.root .. "/oi-snippets/files"
M.rbook = M.root .. "/oi-snippets/rbook"

return M
