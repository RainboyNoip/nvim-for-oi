# nvim-cmp 类型图标去重实施计划

## Task 1：建立 formatter 回归检查

**文件：**

- Create: `tests/headless/completion_format.lua`

检查实际 nvim-cmp formatter 对 `Class` 和 `Text` completion item 的输出：

- `icon` 等于对应的 `lspkind.symbol_map` 图标。
- `kind` 只等于类型文本，不包含图标。
- `menu` 保持 `[LSP]`。

先运行测试，确认当前 `symbol_text` 配置因 `kind` 含图标而失败。

## Task 2：修复 kind formatter

**文件：**

- Modify: `lua/plugins/nvim-cmp.lua`

把 `lspkind.cmp_format` 的 `mode` 从 `symbol_text` 改为 `text`。不修改
formatting fields、source menu、宽度、排序、补全源或按键。

## Task 3：验证并提交

运行 formatter 测试和完整 headless 配置加载，确认 `Class`、`Text` 只显示
一个独立图标且工作区无空白错误，然后提交修复。
