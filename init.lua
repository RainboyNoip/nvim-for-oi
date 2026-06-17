-- 插件管理必须最先加载：它会设置 leader 并导入 lua/plugins 下的插件。
require("config.lazy")

-- 编辑能力：LSP、代码片段、快捷键、基础选项。
require("lsp")
require("fileSnip").setup()
require("keymaps")
require("options")
