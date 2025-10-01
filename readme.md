# Neovim 配置

这是一个为 C++ 开发优化的 Neovim 配置，特别适用于算法竞赛和 Competitive Programming (CP)。

## 特性

- **插件管理**: 使用 lazy.nvim 管理插件
- **代码片段**: 自定义代码片段系统，特别为算法竞赛设计
- **LSP 支持**: 针对 C++ 的 clangd 语言服务器配置
- **调试支持**: 集成 nvim-dap 调试器
- **代码补全**: 使用 nvim-cmp 提供智能补全
- **主题**: 使用 gruvbox 主题
- **状态栏**: 使用 lualine 状态栏
- **文件浏览**: 使用 snacks.nvim 的 dashboard

## 安装

1. 克隆此仓库到你的 Neovim 配置目录:
   ```bash
   git clone https://github.com/RainboyNoip/nvim-for-oi ~/.config/nvim
   ```

或者

   ```bash
   git clone https://github.com/RainboyNoip/nvim-for-oi ~/.config/nvim-for-oi
   ```

   add to your .zshrc or .bashrc
   ```bash
   export NVIM_APPNAME=nvim-for-oi
   alias oivim="NVIM_APPNAME=nvim-for-oi nvim"
   alias oiv="NVIM_APPNAME=nvim-for-oi nvim"
   alias voi="NVIM_APPNAME=nvim-for-oi nvim"
   ```


2. 启动 Neovim，lazy.nvim 会自动安装所有插件:
   ```bash
   nvim
   ```

3. 确保你已安装以下依赖:
   - Neovim 0.9+
   - git
   - clangd (用于 C++ LSP 支持)
   - nodejs (某些插件可能需要)

## 使用

### 代码片段

此配置包含一个专门为算法竞赛设计的代码片段系统。你可以通过以下方式使用:

1. 在 Neovim 中按 `<Leader>s` (默认为空格键+s) 打开代码片段选择器
2. 选择你需要的代码片段，它将被插入到当前光标位置

代码片段位于 `oiSnippets/` 目录中，目前包含以下实用工具:
- `log.cpp`: 调试用的日志宏
- `random.cpp`: 随机数生成工具
- `random_dag1.cpp`, `random_dag2.cpp`: DAG 生成工具
- `random_graph.cpp`: 随机图生成工具

所有插入的代码片段都会自动包装在 `//oisnip_begin` 和 `//oisnip_end` 标记之间，便于折叠和管理。

### 快捷键

- `<Leader>` 键设置为空格键
- `<Leader>s`: 打开代码片段选择器
- `<C-h/j/k/l>`: 在窗口间切换
- `<C-Up/Down/Left/Right>`: 调整窗口大小
- `<C-s>`: 保存文件 (Normal 和 Insert 模式)

### 折叠

代码折叠已配置为使用标记折叠，标记为:
- 开始标记: `//oisnip_begin`
- 结束标记: `//oisnip_end`

### LSP

C++ LSP 支持通过 clangd 提供，支持以下功能:
- 代码补全
- 跳转到定义
- 查找引用
- 重命名符号
- 代码诊断

### 调试

使用 nvim-dap 进行调试，支持:
- 断点设置
- 变量检查
- 步进执行
- 调用栈查看

## 插件列表

- **folke/snacks.nvim**: 提供 dashboard、终端等实用功能
- **nvim-lualine/lualine.nvim**: 状态栏
- **folke/which-key.nvim**: 快捷键提示
- **nvim-telescope/telescope.nvim**: 模糊搜索
- **neovim/nvim-lspconfig**: LSP 配置
- **hrsh7th/nvim-cmp**: 代码补全
- **mfussenegger/nvim-dap**: 调试器
- **rcarriga/nvim-dap-ui**: 调试界面
- **numToStr/Comment.nvim**: 快速注释
- **ellisonleao/gruvbox.nvim**: 主题
- **nvim-tree/nvim-web-devicons**: 图标
- **nvim-lua/plenary.nvim**: Lua 函数库

## 自定义配置

你可以在 `lua/` 目录中找到所有自定义配置:
- `options.lua`: Neovim 选项设置
- `keymaps.lua`: 快捷键映射
- `lsp.lua`: LSP 配置
- `fileSnip.lua`: 代码片段系统
- `config/lazy.lua`: 插件管理配置
- `plugins/`: 各个插件的详细配置

## 贡献

欢迎提交 Issue 和 Pull Request 来改进此配置。
