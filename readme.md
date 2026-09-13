# Neovim 配置

这是一个为 C++ 和 Python 开发优化的 Neovim 配置，特别适用于算法竞赛和 Competitive Programming (CP)。
Neovim 在这个配置里只负责写代码体验：编辑、补全、LSP、snippet、模板插入和调试配置；编译、运行、拉样例、对拍等命令行工作流不接入 Neovim。

## 特性

- **插件管理**: 使用 lazy.nvim 管理插件
- **代码片段**: 自定义代码片段系统，特别为算法竞赛设计
- **LSP 支持**: C++ 使用 clangd，Python 使用宽松诊断的 BasedPyright
- **调试支持**: nvim-dap **已暂时禁用**（2026-08-22），改用终端 cgdb / gdbgui
- **代码补全**: 使用 nvim-cmp 提供智能补全
- **AI 补全**: minuet-ai.nvim 接 DeepSeek FIM，默认**关闭**（`OI_AI=0`），见 [AI 补全指南](docs/how-to-use-ai-completion.md)
- **主题**: 默认使用 nightfly 主题，并通过 themify 管理可切换主题
- **状态栏**: 使用 lualine 状态栏
- **文件浏览 / Picker**: 使用 snacks.nvim 的 explorer、picker 和 dashboard
- **Markdown 渲染**: render-markdown.nvim 在 buffer 内渲染标题、表格与公式

## 安装

1. 克隆此仓库到你的 Neovim 配置目录。

   作为**主配置**（替换默认的 `~/.config/nvim`，之后直接用 `nvim` / `vi`）：
   ```bash
   git clone https://github.com/RainboyNoip/nvim-for-oi ~/.config/nvim
   ```

   或者作为**独立配置**安装。这种方式通过 `NVIM_APPNAME` 与其它 Neovim 配置
   隔离，**目录名必须与下面第 3 步的 appname 一致**：
   ```bash
   git clone https://github.com/RainboyNoip/nvim-for-oi ~/.config/rainboy-nvim-for-oi
   ```

2. （可选）安装算法代码模板库 [rbook_nunjucks](https://github.com/rainboyOJ/rbook_nunjucks):
   配置中的 `<Leader>of`（插入模板）与 `<Leader>oe`（浏览模板文件）支持 150+ 常用算法与数据结构模板，模板索引来自 `rbook_nunjucks` 仓库：
   ```bash
   mkdir -p ~/mycode
   git clone https://github.com/rainboyOJ/rbook_nunjucks.git ~/mycode/rbook_nunjucks
   ```
   > **说明**：如果不克隆或未设置环境变量，nvim-for-oi 会自动回退到仓库自带的 mini 模板库（`all-snippets/oi-snippets/rbook/code.yaml`），开箱即用。

3. 在你的 `~/.zshrc` 或 `~/.bashrc` 中添加以下内容:
   ```bash
   # 关闭 minuet AI 补全，避免在禁用 AI 的比赛中误发请求。
   # 需要 AI 时临时覆盖：OI_AI=1 vi main.cpp
   export OI_AI=0
   # rbook 模板库索引，<Leader>of / <Leader>oe 的数据源
   export RBOOK_CODE_YAML=~/mycode/rbook_nunjucks/book/code.yaml
   # 用独立 appname 启动，避免与其他 Neovim 配置互相覆盖。
   # 目录名必须与它一致，即上面第 1 步的独立安装方式。
   # 若把仓库克隆成了主配置 ~/.config/nvim，请删掉这两行 alias。
   alias vi="NVIM_APPNAME=rainboy-nvim-for-oi nvim"
   alias vim=vi
   ```

   > `OI_AI` 是**字符串比较**（`vim.env.OI_AI ~= "0"`），只有正好等于 `0` 才关闭；
   > `false`、`no`、空串都不会生效。详见 [AI 补全指南](docs/how-to-use-ai-completion.md)。

4. 安装系统依赖:
   ```bash
   # macOS:
   brew install gum find fd luarocks
   # rbook 插件解析 YAML 需依赖 lyaml（针对 LuaJIT 的 5.1 ABI 编译）：
   luarocks --lua-version=5.1 --lua-dir=/opt/homebrew/opt/luajit install lyaml
   ```

5. 启动 Neovim，lazy.nvim 会自动安装所有插件:
   ```bash
   nvim
   # 或使用别名
   vi
   ```

6. 确保你已安装以下依赖:
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

4. 安装调试器(for nvim-dap) —— **当前已禁用，以下仅为将来恢复时的参考**
   - `vscode-cpptools` 扩展(linux): https://codeberg.org/mfussenegger/nvim-dap/wiki/C-C---Rust-(gdb-via--vscode-cpptools)
   - `CodeLLDB` 扩展 (macos): https://codeberg.org/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb)

## 目录结构

```
rainboyVim-for-oi/
├── .gitignore
├── CONTEXT.md                   # 领域术语：四类 snippet 资产的边界
├── init.lua                     # 入口：按顺序 require 下面这些模块
├── lazy-lock.json               # 插件版本锁（比赛机器上不会被更新背刺）
├── readme.md
├── cheatsheet.md                # <Leader>oh 浮窗的内容源（手工维护）
├── TODO.md
│
├── lua/
│   ├── options.lua              # vim.opt 设置
│   ├── keymaps.lua              # 全局键位
│   ├── lsp.lua                  # vim.lsp.config + vim.lsp.enable
│   ├── fileSnip.lua             # file snippet 选择器（<Leader>os）
│   ├── cheatsheet.lua           # <Leader>oh 浮窗实现
│   │
│   ├── config/
│   │   └── lazy.lua             # lazy.nvim 引导（checker 已关，import = "plugins"）
│   │
│   ├── lsp/
│   │   ├── clangd.lua           # C++ LSP（参数与 root_markers）
│   │   └── basedpyright.lua     # Python LSP（宽松诊断）
│   │
│   ├── plugins/                 # 每个插件一个 spec 文件
│   │   ├── LuaSnip.lua          # 片段引擎（ft 懒加载）
│   │   ├── nvim-cmp.lua         # 补全（含内存版 OI 词表源 oi_words）
│   │   ├── which-key.lua        # <Leader> 菜单 + Nerd Font 图标
│   │   ├── snacks.lua           # dashboard / picker / terminal
│   │   ├── snacks/
│   │   │   ├── dashboard.lua
│   │   │   ├── picker.lua
│   │   │   └── terminal.lua
│   │   ├── treesitter.lua
│   │   ├── lualine.lua
│   │   ├── buffline.lua         # bufferline.nvim
│   │   ├── comment.lua
│   │   ├── autopairs.lua
│   │   ├── colortheme.lua
│   │   ├── marks.lua
│   │   ├── minuet.lua           # AI 补全（需 DEEPSEEK_API_KEY；OI_AI=0 时整个不加载）
│   │   ├── render-markdown.lua  # Markdown 渲染（<Leader>mm 切换）
│   │   ├── lang-cpp.lua         # 挂载下面的本地插件
│   │   ├── lang-python.lua
│   │   ├── rbook.lua
│   │   ├── dap.lua              # 整块被注释（已禁用）
│   │   ├── nvim-dap-ui.lua      # 整块被注释（已禁用）
│   │   └── dap/                 # 未被 import，当前不生效
│   │       ├── keys.lua         # <Leader>d* 键位（因此也不存在）
│   │       ├── macos.lua  linux.lua  python.lua
│   │       └── lldbinit  lldb_scripts/
│   │
│   ├── local/                   # 本地插件：lazy 用 dir = 直接挂载
│   │   ├── cpp-settings/lua/cpp-settings.lua      # <Leader>; 与折叠标记
│   │   ├── python-settings/lua/python-settings.lua
│   │   └── rbook.nvim/lua/rbook/
│   │       ├── init.lua         # 命令注册（RbookCode 等）
│   │       ├── config.lua       # 默认选项 + filetype 过滤白名单
│   │       ├── scanner.lua      # 扫 code.yaml 与 code/ 目录
│   │       ├── catalog.lua      # 内存缓存
│   │       ├── picker.lua       # snacks picker 组装
│   │       ├── actions.lua      # 插入 / 打开 / 复制
│   │       └── paths.lua  deps.lua  doctor.lua
│   │
│   └── （lua/ 下只放 Neovim 配置代码；snippet 资源见下面的 all-snippets/）
│
├── all-snippets/                # 所有 snippet 资源归档（三组加载机制各不相同）
│   ├── lua-snippets/            # LuaSnip 的 Lua 片段
│   │   ├── cpp.lua              # C++ 入口：list_extend 下面的 cpp/*.lua
│   │   ├── python.lua           # Python 入口（触发词与 C++ 对齐）
│   │   ├── utils.lua            # 两个入口共用的捕获 / 转换工具
│   │   └── cpp/
│   │       ├── for.lua          # f / f n / f l r / fabc ... / rf / 2f
│   │       └── io.lua  stl.lua  graph.lua  debug.lua  algo.lua  oth.lua
│   │
│   ├── vscode-snippets/         # VSCode 格式 JSON（Neovim 与 VSCode 共用）
│   │   ├── c/c.json  c/cdoc.json
│   │   ├── cpp/cpp.json  cpp/cppdoc.json
│   │   ├── python.json  haskell.json  markdown.json
│   │   └── package.json         # 向 VSCode 注册上面的 json
│   │
│   └── oi-snippets/             # OI 专用资源
│       ├── files/               # file snippet（<Leader>os 选文件插入内容）
│       │   ├── simple_template.cpp  rnd_tree.cpp
│       │   ├── config/clangd_config   # 需手动改名 .clangd 才生效
│       │   └── utils/
│       │       ├── log.cpp  random.cpp  random_graph.cpp
│       │       └── random_dag1.cpp  random_dag2.cpp
│       └── rbook/               # rbook 模板库（<Leader>of / <Leader>oe）
│           ├── code.yaml        # 兜底模板索引（可被 RBOOK_CODE_YAML 覆盖）
│           └── code/cpp/main.cpp  code/python/main.py
│
├── docs/
│   ├── adr/
│   │   └── 0001-snippet-asset-layout.md   # 为什么归档到 all-snippets/、为何显式注册入口
│   ├── config-optimization.md   # 配置审计清单（带修复状态）
│   ├── how-to-use-in-python.md
│   ├── how-to-use-ai-completion.md
│   └── superpowers/             # 历史计划与设计稿
│
├── tests/                       # headless 检查脚本（assert 驱动）
│   ├── headless/
│   │   ├── python_support.lua
│   │   ├── python_lsp.lua
│   │   ├── python_dap.lua
│   │   ├── completion_format.lua
│   │   ├── minuet_completion.lua
│   │   └── rbook.lua
│   └── fixtures/
│       └── python_lsp.py
│
├── dotfiles/                    # 与 Neovim 无关的终端/脚本配置
│   ├── install.sh  readme.md  tmux.conf
│   └── scripts/                 # duipai.py  luogu.py  randint.py ...
│
├── after/
│   └── ftplugin/                # 空目录（预留）
├── tmp/                         # 空目录（预留）
├── doc/                         # 解决插件 debug 热重载问题.md
├── .opencode/                   # 工具产物（与 Neovim 无关）
└── codex_resume                 # 工具产物
```

加载链路（谁先谁后）：

```
init.lua
  └─ config.lazy          启 lazy.nvim，按 import = "plugins" 读所有 spec
  └─ lsp                  vim.lsp.config{ clangd, basedpyright } + enable
  └─ fileSnip.setup()     全局注册 <Leader>os / oe / of
  └─ cheatsheet.setup()   <Leader>oh 浮窗
  └─ keymaps              全局键位
  └─ options              最后设 vim.opt
```

两个 snippet 体系靠不同机制加载：

```
all-snippets/lua-snippets/    ls.add_snippets()  显式注册 cpp / python 两个入口模块
   cpp.lua / python.lua       → 不递归扫目录：入口已 list_extend 了实现模块，
                                递归扫会把它们重复加载一遍（见 docs/adr/0001）
all-snippets/vscode-snippets/ from_vscode.lazy_load()  按 filetype 懒加载
```

启动期只加载 8 个插件（实测 `lazy.core.config`）：`Comment.nvim`、`lazy.nvim`、
`lualine.nvim`、`nvim-treesitter`、`nvim-web-devicons`、`snacks.nvim`、`themify.nvim`、
`vim-nightfly-colors`。其余全部延迟：

```
ft     → lua/local/*（cpp / python 设置）、LuaSnip、treesitter 的高亮
keys   → bufferline、rbook
cmd    → rbook.nvim
module → luasnip（nvim-cmp 在 InsertEnter 会 require 它）
event  → which-key(VeryLazy)、marks(VeryLazy)、cmp(InsertEnter)
```

## 使用

### 代码片段

此配置包含一个专门为算法竞赛设计的代码片段系统。当前按职责分成三类:

- `all-snippets/lua-snippets/`: LuaSnip 短触发片段，例如 for 循环、输入输出、main、return。
- `all-snippets/oi-snippets/files/`: file snippet，例如模板、随机数据、log、图生成工具。
- `all-snippets/vscode-snippets/`: VSCode snippet 格式的通用片段，同时供 LuaSnip 加载。

三组都归档在 `all-snippets/` 下，但**加载机制各不相同**（Lua 模块注册 / JSON 懒加载 /
picker 选文件插入 / rbook 索引），归档只是目录组织，不代表统一格式。术语与边界见
[CONTEXT.md](CONTEXT.md) 与 [ADR 0001](docs/adr/0001-snippet-asset-layout.md)。

在 Neovim 中按 `<Leader>os` 打开 file snippet 选择器，选择后会插入到当前光标位置。

`all-snippets/oi-snippets/files/` 目前包含以下实用工具:
- `utils/log.cpp`: 调试用的日志宏
- `utils/random.cpp`: 随机数生成工具
- `utils/random_dag1.cpp`, `utils/random_dag2.cpp`: DAG 生成工具
- `utils/random_graph.cpp`: 随机图生成工具
- `simple_template.cpp` / `simple_template.py` / `rnd_tree.cpp`: 完整模板（直接放在 `files/` 根下）
- `config/clangd_config`: 需手动改名 `.clangd` 才生效

`all-snippets/oi-snippets/files/` 中的工具（在 `utils/` 等子目录里）会自动包装在
`//oisnip_begin` 和 `//oisnip_end` 标记之间；直接放在 `files/` 根下的模板不添加标记。
Python 模板同样不添加 marker。

### 快捷键

> `<Leader>` 菜单（which-key）的每个条目都带 Nerd Font 图标，图标字形名与码点逐个
> 核对过本机字体，详见 `lua/plugins/which-key.lua` 的注释。

- `<Leader>` 键设置为空格键
- `<Leader>oh`: 打开 `cheatsheet.md` 浮动窗口，查看自定义快捷键和 snippet 触发
- `<Leader>os`: 打开 file snippet 选择器
- `<Leader>of`: 打开 rbook 正式代码模板（按当前文件类型过滤）
- `<Leader>oe`: 浏览 rbook 代码文件（按当前文件类型过滤）
- `<Leader>rr` / `<Leader>rd`: 刷新 rbook 索引 / 检查模板索引（`RbookDoctor`）
- `<Leader>sf`: 查看当前文件 LSP 符号，支持 C++ 和 Python
- `<Leader>mm` / `<Leader>me` / `<Leader>md`: 切换 / 开启 / 关闭 Markdown 渲染。
  公式以 Unicode 近似显示（非 KaTeX），依赖见 [公式渲染指南](docs/how-to-render-math.md)
- `<C-h/j/k/l>`: 在窗口间切换
- `<C-Up/Down/Left/Right>`: 调整窗口大小
- `<C-s>`: 保存文件 (Normal 和 Insert 模式)
- AI 补全的 `<Leader>a*` 与 `<M-*>` 键默认**不存在**（`OI_AI=0`），需要时见 [AI 补全指南](docs/how-to-use-ai-completion.md)

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
2. 本仓库自带的模板库 `all-snippets/oi-snippets/rbook/code.yaml`（只有 C++ / Python 各一个骨架）

所以克隆本仓库后开箱可用。要使用包含 150+ 算法与数据结构代码模板的完整书库：

1. 克隆 [rbook_nunjucks](https://github.com/rainboyOJ/rbook_nunjucks) 仓库：
   ```bash
   mkdir -p ~/mycode
   git clone https://github.com/rainboyOJ/rbook_nunjucks.git ~/mycode/rbook_nunjucks
   ```
2. 在 shell 配置里指向该索引：
   ```sh
   export RBOOK_CODE_YAML=~/mycode/rbook_nunjucks/book/code.yaml
   ```

   该仓库还自带 `dotfiles/`，提供对拍、随机数据生成、画图等 OI 脚本
   （`duipai.py`、`one-duipai.py`、`randint.py`、`dot2png.py`、`luogu.py` 等）。
   运行 `./install.sh` 会把 `dotfiles/scripts` 加入 shell 的 `PATH` 并安装 tmux 配置；
   也可以只手动加一行：
   ```sh
   export PATH="$PATH:$HOME/mycode/rbook_nunjucks/dotfiles/scripts"
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
OJ snippets、通用 snippets、DAP 和故障排查见
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

- **folke/lazy.nvim**: 插件管理
- **folke/snacks.nvim**: dashboard、explorer、picker、终端
- **nvim-lualine/lualine.nvim**: 状态栏
- **folke/which-key.nvim**: `<Leader>` 菜单提示（带 Nerd Font 图标）
- **hrsh7th/nvim-cmp**: 代码补全（`cmp-nvim-lsp` / `cmp-buffer` / `cmp-path` / `cmp_luasnip`）
- **L3MON4D3/LuaSnip**: 片段引擎（`ft` 懒加载）
- **nvim-treesitter/nvim-treesitter**: 语法高亮
- **numToStr/Comment.nvim**: 快速注释
- **windwp/nvim-autopairs**: 括号自动配对
- **onsails/lspkind.nvim**: 补全菜单图标
- **nvim-tree/nvim-web-devicons**: 文件图标
- **akinsho/bufferline.nvim**: buffer 标签栏
- **bluz71/vim-nightfly-colors**: 默认主题
- **LmanTW/themify.nvim**: 主题管理，使用 `:Themify`、`<I>` 安装主题
- **milanglacier/minuet-ai.nvim**: AI 补全（需 `DEEPSEEK_API_KEY`）；`OI_AI=0` 时整个插件不加载
- **chentoast/marks.nvim**: 位置书签
- **MeanderingProgrammer/render-markdown.nvim**: 在 buffer 内渲染 Markdown（`<Leader>mm` 切换）；
  公式渲染需要额外的 `latex` parser 与 `utftex`/`latex2text`，见 [公式渲染指南](docs/how-to-render-math.md)

已禁用但仍留在仓库（将来可能恢复）：

- **mfussenegger/nvim-dap**、**rcarriga/nvim-dap-ui**：`lua/plugins/dap.lua` 与
  `lua/plugins/nvim-dap-ui.lua` 整块被注释；`lua/plugins/dap/` 目录也没有被 import
- **bluz71/vim-moonfly-colors**: 已不在 `lazy-lock.json`（`colortheme.lua` 里作为兜底主题名引用，但未安装）

> 这份列表以 `lazy-lock.json`（共 21 个插件）为准逐个核对过；`nvim-lspconfig` 与
> `plenary.nvim` 并不需要（LSP 直接用 `vim.lsp.config` 配置）。

## 自定义配置

你可以在 `lua/` 目录中找到所有自定义配置（完整目录树见上面的「目录结构」）：
- `options.lua`: Neovim 选项设置
- `keymaps.lua`: 快捷键映射
- `lsp.lua`: LSP 配置
- `fileSnip.lua`: file snippet 选择器（默认目录 `all-snippets/oi-snippets/files/`）
- `config/lazy.lua`: 插件管理配置
- `plugins/`: 各个插件的详细配置
- `all-snippets/`: 全部 snippet 资源（三组加载机制不同，见上）。
  `lua-snippets/` 不在 Neovim 的 `lua/` 搜索路径里，`lua/plugins/LuaSnip.lua` 会把它注入 `package.path`。
- `local/`: 本地插件（cpp-settings / python-settings / rbook.nvim）

## 贡献

欢迎提交 Issue 和 Pull Request 来改进此配置。
