# Neovim 配置

这是一个为 C++ 和 Python 开发优化的 Neovim 配置，特别适用于算法竞赛和 Competitive Programming (CP)。
Neovim 在这个配置里只负责写代码体验：编辑、补全、LSP、snippet、模板插入和调试配置；编译、运行、拉样例、对拍等命令行工作流不接入 Neovim。

## 特性

- **插件管理**: 使用 lazy.nvim 管理插件
- **代码片段**: 自定义代码片段系统，特别为算法竞赛设计
- **LSP 支持**: C++ 使用 clangd，Python 使用宽松诊断的 BasedPyright
- **调试支持**: 通过 nvim-dap 调试 C++，通过 debugpy 调试 Python
- **代码补全**: 使用 nvim-cmp 提供智能补全
- **主题**: 默认使用 nightfly 主题，并通过 themify 管理可切换主题
- **状态栏**: 使用 lualine 状态栏
- **文件浏览 / Picker**: 使用 snacks.nvim 的 explorer、picker 和 dashboard

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

安装依赖的项目
```bash
brew install gum find fd
```

2. 启动 Neovim，lazy.nvim 会自动安装所有插件:
   ```bash
   nvim
   ```

3. 确保你已安装以下依赖:
   - Neovim 0.12+
   - git
   - clangd (用于 C++ LSP 支持)
   - nodejs (某些插件可能需要)

   Arch Linux 上的 Python OJ 依赖:

   ```bash
   uv tool install basedpyright
   uv tool update-shell
   sudo pacman -S --needed python-debugpy
   ```

   在 Neovim 中执行 `:TSInstall python` 安装 Python parser。完整安装、使用和
   排错说明见 [Python OJ 使用指南](docs/how-to-use-in-python.md)。

4. 安装调试器(for nvim-dap)
   5. `vscode-cpptools` 扩展(linux): https://codeberg.org/mfussenegger/nvim-dap/wiki/C-C---Rust-(gdb-via--vscode-cpptools)
   6. `CodeLLDB` 扩展 (macos): https://codeberg.org/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb)

## 使用

### 代码片段

此配置包含一个专门为算法竞赛设计的代码片段系统。当前按职责分成三类:

- `lua/snippets/`: LuaSnip 短触发片段，例如 for 循环、输入输出、main、return。
- `oiSnippets/`: 本地整块代码片段，例如模板、随机数据、log、图生成工具。
- `vscode-snippets/`: VSCode snippet 格式的通用片段，同时供 LuaSnip 加载。

在 Neovim 中按 `<Leader>os` 打开 `oiSnippets/` 选择器，选择后会插入到当前光标位置。

`oiSnippets/` 目前包含以下实用工具:
- `log.cpp`: 调试用的日志宏
- `random.cpp`: 随机数生成工具
- `random_dag1.cpp`, `random_dag2.cpp`: DAG 生成工具
- `random_graph.cpp`: 随机图生成工具

`oiSnippets/` 中的非模板 C++ 工具会自动包装在 `//oisnip_begin` 和
`//oisnip_end` 标记之间。Python 模板不添加 marker。

### 快捷键

- `<Leader>` 键设置为空格键
- `<Leader>oh`: 打开 `cheatsheet.md` 浮动窗口，查看自定义快捷键和 snippet 触发
- `<Leader>os`: 打开 `oiSnippets/` 代码片段选择器
- `<Leader>of`: 打开 rbook 正式代码模板（按当前文件类型过滤）
- `<Leader>oe`: 浏览 rbook 代码文件（按当前文件类型过滤）
- `<Leader>rr` / `<Leader>rd`: 刷新 rbook 索引 / 检查模板索引（`RbookDoctor`）
- `<Leader>sf`: 查看当前文件 LSP 符号，支持 C++ 和 Python
- `<C-h/j/k/l>`: 在窗口间切换
- `<C-Up/Down/Left/Right>`: 调整窗口大小
- `<C-s>`: 保存文件 (Normal 和 Insert 模式)

#### rbook：按文件类型过滤

在 `.cpp` buffer（含 `c` / `h` / `hpp`）里执行 `<Leader>of` / `<Leader>oe`，只列出
`.cpp` / `.cc` / `.cxx`；在 `.py` buffer 里只列出 `.py`。`markdown` / `text` /
没有 filetype 的 buffer（`:enew`）不做过滤，等于看全部。

要在这类 buffer 里强制看全部，命令加 `!`：

```vim
:RbookCodeFiles!   " 不过滤
:RbookCode!        " 不过滤
```

白名单在 `lua/local/rbook.nvim/lua/rbook/config.lua` 的 `files.filetype_extensions`，
可以用 `lua/plugins/rbook.lua` 的 `opts` 覆盖。没有 `language` 字段的模板视为通用，始终显示。

#### rbook：模板库位置

`code.yaml` 按这个顺序解析：

1. 环境变量 `RBOOK_CODE_YAML`（仅当文件确实存在时采用）
2. 本仓库自带的 mini 模板库 `mini_rbook_code_template/code.yaml`（只有 C++ / Python 各一个骨架）

所以克隆本仓库后开箱可用。要用完整书库就在 shell 配置里指过去（本仓库的 `alias v` 就是这么做的）：

```sh
export RBOOK_CODE_YAML=~/mycode/教程与书籍/rbook_nunjucks/book/code.yaml
```

解析规则：模板条目的 `path` 相对于 `code.yaml` 同级的 `code/` 目录。
依赖：`lyaml`（用 `luarocks --lua-version=5.1 --lua-dir=/opt/homebrew/opt/luajit install lyaml`
安装，必须针对 LuaJIT 的 5.1 ABI 编译）。

### Cheat Sheet

`cheatsheet.md` 是快捷键和 snippet 触发的手工维护清单。`<Leader>oh` 会读取这个 Markdown 文件并显示在浮动窗口里；更新提示内容时只需要修改 `cheatsheet.md`。

### 折叠

代码折叠已配置为使用标记折叠，标记为:
- C++: `//oisnip_begin` / `//oisnip_end`
- Python: `#oisnip_begin` / `#oisnip_end`

### LSP

C++ LSP 支持通过 clangd 提供，支持以下功能:
- 代码补全
- 跳转到定义
- 查找引用
- 重命名符号
- 代码诊断
- 当前文件符号列表 (`<Leader>sf`)

`<Leader>sf` 依赖 clangd 返回的 document symbols。如果当前 C++ 文件存在严重语法错误，符号列表可能为空；先修正语法错误后再使用。

Python LSP 由 BasedPyright 提供，使用适合 OJ 的宽松诊断。Python 的模板、
36 个 OJ snippets、25 个通用 snippets、DAP 和故障排查见
[Python OJ 使用指南](docs/how-to-use-in-python.md)。


使用`clangd`,在项目的根目录下创建`.clangd`文件，内容如下:

```
CompileFlags:
  Add: [-std=c++17]
```

### 调试

> **注意**：nvim-dap 已暂时禁用 (2026-08-22)，改用终端 cgdb/gdbgui [gdb-frontend](https://github.com/rohanrhu/gdb-frontend)。恢复方法：解开 `lua/plugins/dap.lua` 和 `lua/plugins/nvim-dap-ui.lua` 中的块注释。

使用 nvim-dap 进行调试，支持:
- 断点设置
- 变量检查
- 步进执行
- 调用栈查看

## 插件列表

- **folke/snacks.nvim**: 提供 dashboard、explorer、picker、终端等实用功能
- **nvim-lualine/lualine.nvim**: 状态栏
- **folke/which-key.nvim**: 快捷键提示
- **neovim/nvim-lspconfig**: LSP 配置
- **hrsh7th/nvim-cmp**: 代码补全
- **mfussenegger/nvim-dap**: 调试器
- **rcarriga/nvim-dap-ui**: 调试界面
- **numToStr/Comment.nvim**: 快速注释
- **bluz71/vim-nightfly-colors**: 默认主题
- **bluz71/vim-moonfly-colors**: 备用主题
- **nvim-tree/nvim-web-devicons**: 图标
- **nvim-lua/plenary.nvim**: Lua 函数库
- **LmanTW/themify.nvim**: Theme管理, 使用 `:Themify`, `<I>` 来安装主题

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
