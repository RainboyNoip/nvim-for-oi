# Python OJ 支持设计

## 背景

本项目目前面向 C++ 算法竞赛开发。Neovim 负责编辑、补全、LSP、snippet、模板插入和 DAP 调试；编译、运行、样例下载、输出比较与对拍保留在终端工作流中。

本次新增 Python OJ 支持，并保持这条职责边界不变。目标环境是当前 Arch Linux，不扩展 macOS 或 Windows 的 Python 支持。

## 目标

- 为 Python 文件提供语法高亮、补全、诊断、符号跳转、引用查找和重命名。
- 使用适合 OJ 动态代码的宽松诊断，保留真正影响运行的错误，减少类型噪声。
- 提供 Pythonic 的 OJ snippets 和基于 `sys.stdin.buffer.readline` 的完整模板。
- 复用现有 nvim-dap 快捷键和界面调试当前 Python 文件。
- 提供一份长期可查的 Python 使用文档，覆盖配置结构、安装、日常使用和排错。
- 保证现有 C++ LSP、snippets、模板和 DAP 行为不回归。

## 非目标

- 不在 Neovim 内加入一键运行、样例拉取、样例评测或输出 diff。
- 不加入 Python 虚拟环境选择和项目依赖管理。
- 不加入自动格式化、保存时修复或 import 排序。
- 不引入 Mason、nvim-dap-python 或其他 Python 专用管理插件。
- 不为 macOS 或 Windows 配置 Python 解释器和 debugpy 路径。

## 技术方案

采用与现有配置一致的轻量原生方案：

- 使用 Neovim 0.12 的 `vim.lsp.config` 和 `vim.lsp.enable` 配置 BasedPyright。
- 复用现有 `nvim-cmp` 的 LSP completion source。
- 复用现有 LuaSnip，新增 `python` filetype snippets。
- 复用现有 nvim-dap，直接启动 `python3 -m debugpy.adapter`。
- 继续手动安装外部工具，不增加插件层面的工具管理器。

## 配置结构

### LSP

新增 `lua/lsp/basedpyright.lua`，集中保存 BasedPyright 配置；修改 `lua/lsp.lua`，在 clangd 之外注册并启用 BasedPyright。

BasedPyright 配置遵循以下约定：

- `filetypes` 只包含 `python`。
- root marker 按 `pyproject.toml`、`basedpyrightconfig.json`、`pyrightconfig.json`、`.git` 查找。
- `diagnosticMode` 使用 `openFilesOnly`，避免竞赛目录中的其他题目产生诊断。
- `typeCheckingMode` 以 `basic` 为基础。
- 保留语法错误、未定义变量、无法解析的 import 和明显类型错误。
- 通过 `diagnosticSeverityOverrides` 把以下低价值提示设为 `none`：
  `reportMissingTypeStubs`、`reportUnusedCallResult`、`reportUnusedImport`、
  `reportUnusedVariable`、`reportUnknownArgumentType`、`reportUnknownLambdaType`、
  `reportUnknownMemberType`、`reportUnknownParameterType` 和
  `reportUnknownVariableType`。

如果找不到 `basedpyright-langserver`，Python buffer 只提示一次依赖缺失，并指向 `docs/how-to-use-in-python.md`，不影响普通编辑。

### Python Buffer 设置

新增 `lua/plugins/lang-python.lua` 和对应的本地模块 `lua/local/python-settings/lua/python-settings.lua`，结构与现有 C++ 本地设置保持一致，并只在 `python` filetype 加载。

该模块负责：

- 明确设置 4 空格缩进和 `expandtab`。
- 设置 Python comment string。
- 将 marker fold 注释改为 `#oisnip_begin` / `#oisnip_end`，避免继承 C++ 的 `//` marker。
- 作为以后添加 Python buffer 局部行为的唯一入口。

Python 文件不自动执行 `zM`，打开后默认保持可读状态。

### Treesitter

修改 `lua/plugins/treesitter.lua`，把 `python` 加入自动启动的 filetype 列表。启动 parser 时使用受保护调用；parser 未安装时跳过 Treesitter，不中断 buffer 加载。

parser 不在启动时自动下载。用户按文档执行 `:TSInstall python`，保持当前项目不自动管理外部/生成依赖的习惯。

### LuaSnip

新增 `lua/snippets/python.lua`。Python snippets 与 C++ snippets 按 filetype 隔离，因此允许复用短 trigger，不改变 C++ 展开结果。

首批 snippets 固定覆盖以下能力：

| Trigger | Python 展开意图 |
| --- | --- |
| `main` | `solve()` 和 main guard 的完整骨架 |
| `solve` | `def solve():` 函数骨架 |
| `fastin` | 导入 `sys` 并把 `input` 绑定到 `sys.stdin.buffer.readline` |
| `ii` | 读取一个整数 |
| `ints` | `map(int, input().split())` |
| `listi` | `list(map(int, input().split()))` |
| `strin` | 从 buffer input 读取并 decode 字符串 |
| `f` | `for i in range(n):` |
| `fr` | Python 半开区间 `range(left, right)` |
| `fri` | OJ 常用闭区间 `range(left, right + 1)` |
| `rf` | 从 `n - 1` 到 `0` 的倒序循环 |
| `enum` | `enumerate(sequence)` 循环 |
| `tests` | 读取测试组数并重复调用 `solve()` |
| `heap` | `heapq` 导入和最小堆初始化 |
| `bisect` | `bisect_left` / `bisect_right` 导入 |
| `deque` | `collections.deque` 导入和初始化 |
| `dbg` | 输出到 `sys.stderr` 的临时调试语句 |

带变量名或范围的 snippets 使用 LuaSnip insert node 和 mirror node，展开后可以跳转和同步修改。Cheat sheet 必须逐项记录实际 trigger 和展开结果，避免隐藏约定。

### 完整模板

新增 `oiSnippets/template/simple_template.py`，通过现有 `<Leader>os` / `:OISnipChoose` 选择并插入。模板包含：

```python
import sys

input = sys.stdin.buffer.readline


def solve():
    pass


if __name__ == "__main__":
    solve()
```

模板不预设多测逻辑，避免单测题产生无用结构；多测通过 `tests` snippet 添加。模板只使用标准库，可直接作为 Codeforces 或洛谷提交文件。

### DAP

新增 `lua/plugins/dap/python.lua` 作为 Python adapter/configuration 模块，并由当前 Linux DAP 配置调用。它不单独声明新的插件。

adapter 使用当前 PATH 中的 `python3` 启动：

```text
python3 -m debugpy.adapter
```

提供一个明确的 launch configuration：

- 名称为 `Launch current Python file`。
- `request` 为 `launch`，`program` 为当前文件。
- working directory 使用 Neovim 当前工作目录。
- console 使用集成终端，OJ 标准输入由用户在终端中输入。
- 默认只调试用户代码，避免无意进入标准库。

继续使用现有 `<F4>` 到 `<F9>` 和 `<Leader>d...` 快捷键，不增加第二套 Python 调试按键。

启动调试前检查 `python3` 是否可执行，并检查该解释器能否 import `debugpy`。检查失败时不创建 DAP session，而是显示 Arch Linux 安装命令和文档路径。

## 外部依赖

目标系统为 Arch Linux，文档使用以下安装方式：

```bash
uv tool install basedpyright
sudo pacman -S python-debugpy
```

安装后应能执行 `basedpyright-langserver --version`，并且 `python3 -c 'import debugpy'` 成功。Python Treesitter parser 通过 Neovim 的 `:TSInstall python` 安装。

## 使用文档

新增 `docs/how-to-use-in-python.md`，作为用户忘记配置和操作时的总入口。文档至少包含：

1. 本项目对 Python 提供什么、不提供什么。
2. 每个 Python 相关配置文件的路径和职责。
3. Arch Linux 外部依赖及 Treesitter parser 安装命令。
4. 创建 `.py` 文件、确认 filetype 和检查 LSP 状态的方法。
5. 插入完整模板的方法。
6. 全部 Python snippet trigger、展开结果和 LuaSnip 操作键。
7. 设置断点、启动、继续、单步、查看变量和结束 DAP 的步骤。
8. 标准输入在集成终端中的使用方式。
9. BasedPyright、debugpy、Treesitter 和 snippet 不工作时的逐项排查命令。
10. 哪些工作仍需在终端完成，包括直接运行、输入重定向、样例测试和对拍。

`readme.md` 只增加功能概览、依赖入口和该文档链接；详细步骤不在 README 重复维护。`cheatsheet.md` 增加 Python buffer、snippets 和调试速查内容。

## 运行链路

1. 用户打开 `.py` 文件，Neovim 识别为 `python` filetype。
2. Python buffer 设置加载，Treesitter 在 parser 可用时启动。
3. BasedPyright 自动附加，诊断与 completion capabilities 进入现有 LSP 和 nvim-cmp 流程。
4. LuaSnip 根据 `python` filetype 提供 Python snippets。
5. 用户可以用 `<Leader>os` 插入完整模板。
6. 用户用现有 DAP 快捷键启动当前文件，debugpy 在集成终端中处理标准输入。
7. 普通运行、样例输入重定向和评测继续在 Neovim 终端或外部 shell 中执行。

## 错误处理

- BasedPyright 缺失：提示安装命令和文档路径；不阻止 buffer 编辑。
- `python3` 缺失：拒绝启动 Python DAP，显示明确错误。
- debugpy 缺失：拒绝启动 Python DAP，显示 `sudo pacman -S python-debugpy`。
- Python Treesitter parser 缺失：跳过 Treesitter 高亮；保留其他编辑、LSP 和 snippet 功能。
- 当前 buffer 未保存：启动 DAP 前提示先保存文件，不传递空 `program`。
- 模板和 snippet：只生成语法完整、只依赖标准库的代码；动态字段保留明确的首个编辑位置。

## 验证方案

### 静态与启动验证

- 使用 headless Neovim 加载完整配置，退出码必须为 0。
- 打开临时 `.py` 文件，确认 filetype 为 `python` 且 Python snippets 数量大于 0。
- 检查 BasedPyright 和 Python DAP configuration 已注册。
- 打开临时 `.cpp` 文件，确认 clangd 配置和 C++ snippets 仍存在。

### LSP 验证

- 在临时 Python 文件中写入未定义变量，确认 BasedPyright 附加并报告错误。
- 写入未使用 import，确认宽松模式不报告该噪声。
- 确认 completion、definition、rename 和 document symbols 可用。

### 模板与 snippets 验证

- 对 Python 模板执行 `python3 -m py_compile`。
- 让模板读取整数列表并输出结果，使用一组标准输入验证执行结果。
- 逐项确认 snippets 只出现在 Python filetype，关键 trigger 展开为预期结构。

### DAP 验证

- 确认 `python3 -c 'import debugpy'` 成功。
- 对临时程序设置断点并启动，确认会话停在断点。
- 验证 continue、step over、变量查看和 terminate。
- 删除或临时隐藏 debugpy 后验证错误提示，不应创建失败的 session。

### 文档验证

- 在只具备基础 Neovim、Python 和 Arch 包管理器的环境假设下，逐条执行 `docs/how-to-use-in-python.md`。
- 文档中的路径、命令、快捷键和 snippet trigger 必须与最终配置一致。

## 验收标准

- 新建并打开 Python OJ 文件后，能够得到高亮、补全、宽松诊断和符号跳转。
- 能通过模板和 snippets 快速写出基于 `sys.stdin.buffer.readline` 的题解。
- 能用现有 DAP 快捷键调试当前 Python 文件并在集成终端输入数据。
- 外部依赖缺失时有可执行的错误提示，普通编辑不受影响。
- `docs/how-to-use-in-python.md` 足以在遗忘配置细节后独立恢复使用。
- C++ 工作流通过回归检查，原有快捷键和 snippets 不改变。
