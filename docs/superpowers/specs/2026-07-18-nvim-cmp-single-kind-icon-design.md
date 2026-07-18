# nvim-cmp 类型图标去重设计

## 问题

当前补全菜单中的类型列会显示两个相同图标，例如 `Class` 和 `Text` 前各有
两个图标。

新版 nvim-cmp 默认使用 `abbr`、`icon`、`kind`、`menu` 四列，并在独立的
`icon` 列中自动读取 lspkind 图标。现有配置又使用
`lspkind.cmp_format({ mode = "symbol_text" })`，把相同图标加入 `kind` 文本，
因此最终显示为“独立图标 + kind 内图标 + 类型文本”。

## 修复

把 `lua/plugins/nvim-cmp.lua` 中 lspkind formatter 的 `mode` 从
`symbol_text` 改为 `text`：

- nvim-cmp 的独立 `icon` 列继续显示一个 lspkind 图标。
- `kind` 列只显示 `Class`、`Text`、`Function` 等类型文本。
- `menu` 来源标签、补全排序、最大宽度和省略号行为保持不变。
- 不移除 lspkind 依赖，因为新版 nvim-cmp 的独立图标列仍从
  `lspkind.symbol_map` 获取图标。

## 验证

- 用模拟 `Class` 和 `Text` completion item 调用实际 formatter。
- 断言 `icon` 字段非空且只包含图标。
- 断言 `kind` 字段分别等于 `Class` 和 `Text`，不再包含图标。
- 断言 `menu` 仍显示 `[LSP]`。
- headless 加载完整 Neovim 配置，确认退出码为 0。
