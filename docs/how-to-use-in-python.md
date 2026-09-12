# 在本配置中使用 Python 写 OJ

> **注意**：DAP/debugpy 调试已暂时禁用 (2026-08-22)，改用终端 cgdb/gdbgui。
> 文中调试相关章节保留作为将来恢复的参考（恢复方法：解开 `lua/plugins/dap.lua`
> 和 `lua/plugins/nvim-dap-ui.lua` 中的块注释）。

这份文档是 Python OJ 配置的长期使用入口。忘记依赖、模板、snippet、
LSP 或调试方法时，从这里开始检查。

## 功能边界

Neovim 负责：

- Python Treesitter 高亮。
- BasedPyright 补全、诊断、定义跳转、引用、重命名和文件符号。
- Pythonic LuaSnip 和完整 OJ 模板。
- debugpy 断点、单步、变量、调用栈和 REPL。

Neovim 不负责：

- 一键运行和输入文件重定向。
- Codeforces、洛谷样例下载。
- 样例评测、输出 diff 和对拍。
- 虚拟环境、第三方依赖、自动格式化和 import 排序。

这些工作继续在终端完成。

## 配置文件地图

| 文件 | 职责 |
| --- | --- |
| `lua/lsp.lua` | 注册并启用 clangd 与 BasedPyright；LSP 缺失时提示安装 |
| `lua/lsp/basedpyright.lua` | Python LSP root、宽松诊断和分析范围 |
| `lua/plugins/lang-python.lua` | 只在 Python buffer 加载本地设置 |
| `lua/local/python-settings/lua/python-settings.lua` | 4 空格、Python 注释和 fold marker |
| `lua/plugins/treesitter.lua` | 为 Python filetype 安全启动 Treesitter |
| `lua/plugins/LuaSnip.lua` | 加载 `lua/snippets/` |
| `lua/snippets/python.lua` | 17 个 Python OJ snippets |
| `vscode-snippets/python.json` | 25 个 Neovim / VSCode 共用的通用 Python snippets |
| `vscode-snippets/package.json` | 向 VSCode 和 LuaSnip 注册 `python.json` |
| `lua/fileSnip.lua` | `<Leader>os` / `:OISnipChoose` 模板选择器 |
| `oiSnippets/template/simple_template.py` | Python 完整 OJ 模板 |
| `lua/plugins/dap/python.lua` | debugpy adapter、launch 配置和启动前检查 |
| `lua/plugins/dap/linux.lua` | 在 Linux DAP 中接入 C++ 与 Python |
| `tests/headless/python_support.lua` | LSP、buffer、snippet 和 DAP 结构检查 |
| `tests/headless/python_lsp.lua` | BasedPyright 真实诊断检查 |
| `tests/headless/python_dap.lua` | debugpy 真实断点和变量求值检查 |

## 首次安装

当前目标环境是 Arch Linux，Python 命令统一使用 `python3`。

### BasedPyright

```bash
uv tool install basedpyright
uv tool update-shell
```

`uv tool update-shell` 后重新打开终端。验证：

```bash
basedpyright --version
command -v basedpyright-langserver
```

如果终端能找到命令但 Neovim 找不到，确认 `~/.local/bin` 在启动 Neovim
的 shell PATH 中。

### debugpy

推荐安装 Arch 软件包：

```bash
sudo pacman -S --needed python-debugpy
```

没有 sudo 权限时，可以安装到当前 `python3` 的 user site：

```bash
uv pip install \
  --python "$(command -v python3)" \
  --target "$(python3 -m site --user-site)" \
  debugpy
```

验证 debugpy 与 DAP 使用的是同一个解释器：

```bash
python3 -c 'import debugpy; print(debugpy.__version__)'
```

### Python Treesitter parser

在 Neovim 中执行：

```vim
:TSInstall python
```

如果直连 GitHub 出现 TLS 下载错误，执行下面的代理安装命令：

```vim
:lua vim.api.nvim_create_autocmd("User", { pattern = "TSUpdate", once = true, callback = function() require("nvim-treesitter.parsers").python.install_info.url = "https://github.com/tree-sitter/tree-sitter-python" end }); require("nvim-treesitter").install({ "python" }):wait(300000)
```

验证：

```vim
:lua print(pcall(vim.treesitter.language.inspect, "python"))
```

第一项输出 `true` 表示 parser 可用。

## 开始写题

在题目目录创建并打开文件：

```bash
oiv solution.py
```

如果使用的别名不同，只要确保 `NVIM_APPNAME` 指向本配置即可。

确认 filetype：

```vim
:set filetype?
```

应显示 `filetype=python`。

确认 BasedPyright 已附加：

```vim
:lua vim.print(vim.lsp.get_clients({ bufnr = 0 }))
```

输出中应出现 `basedpyright`。`<Leader>sf` 打开当前文件符号；
`<Leader>sD` 打开当前 buffer 诊断。

### 插入完整模板

1. 按 `<Leader>os`，或执行 `:OISnipChoose`。
2. 搜索 `simple_template.py`。
3. 确认后模板插入当前光标位置。

模板默认使用：

```python
import sys

input = sys.stdin.buffer.readline


def solve():
    pass


if __name__ == "__main__":
    solve()
```

模板不默认加入多测。需要多测时在合适位置展开 `tests`。

## Python snippets

输入 trigger 后按 `<C-K>` 展开。使用 `<C-L>` / `<C-J>` 跳到下一个或
上一个字段，`<C-E>` 切换 choice node。

### OJ snippets（17 个）

| Trigger | 默认展开结果 |
| --- | --- |
| `main` | buffered input、`solve()` 和 main guard |
| `solve` | `def solve():` |
| `fastin` | 导入 `sys` 并设置 `input = sys.stdin.buffer.readline` |
| `ii` | `n = int(input())` |
| `ints` | `a, b = map(int, input().split())` |
| `listi` | `a = list(map(int, input().split()))` |
| `strin` | `s = input().strip().decode()` |
| `f` | `for i in range(n):` |
| `fr` | 半开区间 `for i in range(left, right):` |
| `fri` | 闭区间 `for i in range(left, right + 1):` |
| `rf` | `for i in range(n - 1, -1, -1):` |
| `enum` | `for index, value in enumerate(items):` |
| `tests` | 读取测试组数并重复调用 `solve()` |
| `heap` | 导入 `heapq` 并创建 `heap = []` |
| `bisect` | 导入 `bisect_left`、`bisect_right` |
| `deque` | 导入 `deque` 并创建 `queue = deque()` |
| `dbg` | `print(value, file=sys.stderr)` |

`fr` 遵循 Python 的半开区间语义；需要包含右端点时使用 `fri`。
`strin` 包含 `.decode()`，因为 buffered input 返回 bytes。`dbg` 依赖已经
导入 `sys`，使用完整模板或 `fastin` 时会满足这一条件。

### 通用 snippets（25 个）

这些 snippets 来自 `vscode-snippets/python.json`，Neovim 和 VSCode 使用
相同的 trigger 和 placeholder。

| Trigger | 默认展开结果 |
| --- | --- |
| `df` | 无类型注解的 `def function_name(...):` |
| `dft` | 带参数和返回值类型注解的函数 |
| `adf` | 无类型注解的 `async def` |
| `lm` | 命名 lambda 表达式 |
| `cls` | 最小 class 骨架 |
| `init` | 带类型参数和属性赋值的 `__init__` |
| `dcls` | 导入并定义普通 `@dataclass` |
| `prop` | property getter、setter 和同步的底层属性名 |
| `deco` | 使用 `functools.wraps` 的函数装饰器 |
| `ifm` | `if __name__ == "__main__":` |
| `ife` | `if / else` 分支 |
| `mt` | 一个 case 和 `_` fallback 的 `match` |
| `fe` | 使用 `enumerate` 遍历索引和值 |
| `wh` | `while` 循环 |
| `tr` | `try / except` |
| `trf` | `try / except / finally` |
| `wth` | `with expression as value` |
| `ctx` | 获取、yield、释放资源的 context manager |
| `flow` | 按顺序执行多个函数转换 |
| `lc` | 带可选过滤条件的列表推导式 |
| `sc` | 带可选过滤条件的集合推导式 |
| `dictc` | 带可选过滤条件的字典推导式 |
| `gen` | 带可选过滤条件的生成器表达式 |
| `ta` | Python 3.10 `TypeAlias` |
| `opt` | `name: Type | None = None` |

`lc`、`sc`、`dictc` 和 `gen` 默认不带过滤条件；展开后按 `<C-E>` 可
切换为 `if condition`。

检查 snippets 是否加载：

```vim
:lua print(#require("luasnip").get_snippets("python"))
```

应输出 `42`：17 个 OJ snippets 加 25 个通用 snippets。

## 调试

先用 `<C-s>` 保存文件。未保存或有未保存修改时，Python DAP 会拒绝启动，
避免调试旧代码。

| 快捷键 | 操作 |
| --- | --- |
| `<F4>` | 结束调试 |
| `<F5>` | 启动 / 继续 |
| `<F6>` | 切换断点 |
| `<F7>` | Step Into |
| `<F8>` | Step Over |
| `<F9>` | Run to Cursor |
| `<Leader>dB` | 条件断点 |
| `<Leader>do` | Step Out |
| `<Leader>dw` | 查看光标处变量 |
| `<Leader>dr` | 切换 DAP REPL |
| `<Leader>dt` | 结束调试 |

典型流程：

1. 把光标放在目标行，按 `<F6>` 设置断点。
2. 按 `<F5>`，选择或直接启动 `Launch current Python file`。
3. 程序停下后使用 `<F7>`、`<F8>`、`<F9>`。
4. 用 DAP UI 查看 scopes、watches 和调用栈。
5. 按 `<F4>` 结束。

### 调试时输入数据

debugpy 使用 integrated terminal。程序执行到 `input()` 时，在新打开的终端
中输入数据并回车。当前 DAP 配置不把 `in` 文件自动重定向到 stdin。

需要输入文件时，在普通终端运行：

```bash
python3 solution.py < in
```

## 故障排查

### 没有 LSP 补全或诊断

```bash
command -v basedpyright-langserver
basedpyright --version
```

在 Neovim 中：

```vim
:checkhealth vim.lsp
:lua vim.print(vim.lsp.get_clients({ bufnr = 0 }))
```

如果刚安装 BasedPyright，重启终端和 Neovim，让新的 PATH 生效。

### 没有 Treesitter 高亮

```vim
:lua print(pcall(vim.treesitter.language.inspect, "python"))
:TSInstall python
```

第一条输出 `false` 时 parser 尚不可用；直连失败时使用前面的代理安装命令。

### Snippet 不展开

1. 用 `:set filetype?` 确认是 `python`。
2. 用前面的 Lua 命令确认数量是 42。
3. 在 Insert 模式输入完整 trigger，再按 `<C-K>`。
4. 执行 `:Lazy`，确认 LuaSnip 已加载。

### DAP 无法启动

```bash
command -v python3
python3 -c 'import debugpy; print(debugpy.__version__)'
```

然后确认当前 `.py` 文件已保存。查看 DAP 注册状态：

```vim
:lua vim.print(require("dap").configurations.python)
```

仍然失败时，先执行 `:lua require("dap")` 加载 nvim-dap，再执行
`:DapShowLog` 查看 adapter 日志。

## 仍在终端完成的工作

- 直接运行：`python3 solution.py`
- 输入重定向：`python3 solution.py < in`
- 保存输出：`python3 solution.py < in > out`
- 样例 diff：`diff --strip-trailing-cr out expected`
- 拉题目样例和对拍：继续使用仓库 `dotfiles/scripts/` 下的命令行工具

Neovim 内的 Snacks terminal 可用 `<Leader>tt` 打开；这些命令不需要额外
接入编辑器快捷键。
