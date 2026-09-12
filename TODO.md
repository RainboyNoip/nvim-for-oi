- [ ] nvim-dap 重启的问题,快速重新启动调试,最好能保持原来的端点

## 配置优化（详见 [docs/config-optimization.md](docs/config-optimization.md)）

- [x] P0-1.1 `<leader>os` / `<leader>oe` / `<leader>of` / `<leader>;` 只在第一个 buffer 有效
- [ ] P0-1.2 snippet 跳转键被 `keymaps.lua` 覆盖 —— **决定不修**（保留 `<C-l>` 行尾跳转）
- [x] P0-1.3 删除 nvim-cmp 里未安装的 `lazydev` 源
- [x] P1-2.1 clangd 参数：删 `--background-index` / `--clang-tidy`，`iwyu` → `never`，去 `root_markers` 的 `.git`
- [ ] P1-2.2 clangd `filetypes = { 'cpp' }` 补齐 `.c/.h/.hpp/.cc/.cxx`
- [x] P1-2.3 字典补全 → 内存 OI 词表源（方案 A：自定义 cmp source，20 词，cpp+py）
- [ ] P1-2.4 去掉 `InsertLeave` 自动保存（保留 `FocusLost` / `BufLeave`）
- [ ] P1-2.5 Minuet 默认不再自动触发（只留 `<M-a>` 手动）
- [ ] P1-2.6 cmp `<Tab>` 判定顺序改成「补全优先」
- [x] P1-2.7 LuaSnip 加 `ft` + `module` 懒加载（空启动 42→23 ms）
- [ ] P1-2.8 `completeopt` 只让 cmp 一处设
- [ ] P2 删 marks.nvim / render-markdown.nvim / DAP 全套 / 多余配色 / 空目录等
- [ ] P2-4.1 `lua/lsp.lua` 给 clangd 补 `executable()` 保护
