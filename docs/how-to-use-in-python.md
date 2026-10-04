# 在本配置中使用 Python 写 OJ

Python 的 DAP/debugpy 调试已启用；C/C++ DAP 仍然关闭。

这份文档是 Python OJ 配置的长期使用入口。忘记依赖、模板、snippet、
LSP 或调试方法时，从这里开始检查。

## 功能边界

Neovim 负责：

- Python Treesitter 高亮。
- BasedPyright 补全、诊断、定义跳转、引用、重命名和文件符号。
- Pythonic LuaSnip 和完整 OJ 模板。
- debugpy 断点、单步、变量、调用栈和 REPL。
- `<Leader>cf` 手动调 ruff format 格式化当前 Python 文件。

Neovim 不负责：

- 普通运行的一键入口（调试支持选择输入文件）。
- Codeforces、洛谷样例下载。
- 样例评测、输出 diff 和对拍。
- 虚拟环境、第三方依赖、保存前自动格式化和 import 排序。
  （格式化只做手动触发：ruff format 会拆开 `if x: f()` 这类一行复合语句，
  自动跑会反复改掉一行流写法。）

这些工作继续在终端完成。

## 配置文件地图

| 文件 | 职责 |
| --- | --- |
| `lua/lsp.lua` | 注册并启用 clangd 与 BasedPyright；LSP 缺失时提示安装 |
| `lua/lsp/basedpyright.lua` | Python 3.15 目标版本、LSP root、宽松诊断和分析范围 |
| `lua/plugins/lang-python.lua` | 只在 Python buffer 加载本地设置 |
| `lua/local/python-settings/lua/python-settings.lua` | 4 空格、Python 注释、fold marker 和 `<Leader>cf` ruff 格式化 |
| `lua/plugins/treesitter.lua` | 为 Python filetype 安全启动 Treesitter |
| `lua/plugins/LuaSnip.lua` | 显式注册 `all-snippets/lua-snippets/` 的 cpp / python 入口 |
| `all-snippets/lua-snippets/python.lua` | 45 个 Python OJ snippets（含从 C++ 迁移的对应版） |
| `all-snippets/vscode-snippets/python.json` | 29 个 Neovim / VSCode 共用的通用 Python snippets |
| `all-snippets/vscode-snippets/package.json` | 向 VSCode 和 LuaSnip 注册 `python.json` |
| `lua/fileSnip.lua` | `<Leader>os` / `:OISnipChoose` 模板选择器 |
| `all-snippets/oi-snippets/files/mainline.py` | 逐行读取的完整 OJ 模板 |
| `all-snippets/oi-snippets/files/mainread.py` | 一次性读取整数的完整 OJ 模板 |
| `lua/plugins/dap/python.lua` | debugpy adapter、launch 配置和启动前检查 |
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

Neovim **不自带** `python` parser，需要手动安装：

```vim
:TSInstall python
```

`:TSInstall` 是异步的，要等它打印 `Language installed` 才算装完。

如果直连 GitHub 出现 TLS 下载错误，改用 API 并显式等待：

```vim
:lua require("nvim-treesitter.install").install({ "python" }, { summary = true })
```

验证：

```vim
:lua print(pcall(vim.treesitter.language.inspect, "python"))
```

第一项输出 `true` 表示 parser 可用。

> `python` parser 缺失时不只是没有高亮：在 `.py` 里按 `gcc` 会报
> `Comment.nvim/lua/Comment/ft.lua:280: attempt to index local 'tree' (a nil value)`。
> 原因与其余 parser 的安装说明见
> [Treesitter parser 安装指南](how-to-install-treesitter-parsers.md)。

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

BasedPyright 按 Python 3.15 检查语法和标准库。它只控制静态分析；实际运行
仍使用 PATH 中的 `python3`，提交前还要确认 OJ 的解释器版本。

### 插入完整模板

1. 按 `<Leader>os`，或执行 `:OISnipChoose`。
2. 搜索 `mainline.py`（逐行输入）或 `mainread.py`（一次性读取整数）。
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

也可以直接输入 `main` 或 `mainread` 后按 `<Tab>`。`main` 与 `ii`、`ints`、
`listi`、`tests` 配套；`mainread` 与 `next a b c`、`testsdata` 配套。不要在同一份
程序里混用 `input()` 和已经消耗 stdin 的 `data` 迭代器。

## Python snippets

输入 trigger 后按 `<Tab>` 或 `<C-K>` 展开。展开后用 `<Tab>` 跳到下一个字段，
用 `<S-Tab>` 返回上一个字段；这两个键在补全菜单可见时也优先跳字段。
`<C-K>` 在 Insert / Select 模式都可主动展开片段，包括占位符内的嵌套片段。

例如输入 `enum a<Tab>`，把 `idx` 改为 `f` 后，再按 `<Tab>` 会跳到 `val`，
不会触发 `f` 的循环片段。确实需要展开 `f` 时按 `<C-K>`，不弹出选择窗口。

没有可跳转字段时，`<Tab>` 依次尝试展开匹配的片段、选择下一补全项、执行默认 Tab；
`<S-Tab>` 则选择上一补全项或执行默认 Shift-Tab。
在 Insert 模式用 `<C-n>` / `<C-p>` 选择补全项，在 Select 模式用这两个键切换 choice node。
`<C-J>` 也可返回上一个字段；`<C-L>` 用于跳到行尾，`<C-E>` 用于关闭补全菜单。
补全菜单默认不预选：`Enter` 只接受你已选中的项目，否则正常换行；`<C-Y>`
明确接受当前候选（尚未选择时接受第一项）。

### OJ snippets

| Trigger | 默认展开结果 |
| --- | --- |
| `solve` | `def solve():` |
| `fastin` | 导入 `sys` 并设置 `input = sys.stdin.buffer.readline` |
| `ii` | `n = int(input())` |
| `ints` | `a, b = map(int, input().split())` |
| `listi` | `a = list(map(int, input().split()))` |
| `strin` | `s = input().strip().decode()` |
| `next a b c` | `a, b, c = next(data), next(data), next(data)`，`data` 展开后直接选中、三处同步 |
| `f` | `for i in range(n):`（0-based 半开） |
| `lf` | 单行 `for i in range(n):` |
| `f n` | `for i in range(n):`，循环 n 次（0..n-1） |
| `f l r` | `for i in range(l, r + 1):`（保留闭区间，能算出数值就直接算） |
| `rf` | `for i in range(n, 0, -1):`（仍 1-based 含端点） |
| `enum` / `enum a` | `for idx, val in enumerate(a):` |
| `enum2 a` | `for idx, val in enumerate(a, 2):`；数字后缀指定起始索引，如 `enum10 a` |
| `tests` | 读取测试组数并重复调用 `solve()` |
| `testsdata` | 从 `data` 读取测试组数并重复调用 `solve(data)` |
| `heap` | 导入 `heapq` 并创建 `heap = []` |
| `bisect` | 导入 `bisect_left`、`bisect_right` |
| `deque` | 导入 `deque` 并创建 `queue = deque()` |
| `dbg` | `print(value, file=sys.stderr)` |

`enum a` / `enum2 a` 的遍历对象可以替换为 `values`、`a[1:]` 等不含空格的表达式。
数字后缀支持非负整数，包括 `enum0 a`、`enum10 a`；前导零会去掉，
例如 `enum002 a` 展开为 `enumerate(a, 2)`。
遍历对象作为固定文本插入；按 `<Tab>` 依次跳过 `idx`、`val`、起始索引（如有），最后进入循环体。

`f` / `lf` / `f n` / `fabc` 现在是 0-based 半开（`range(n)`），不再从 1 开始；
需要指定上下界时用 `f l r`，它仍保留闭区间 `range(l, r + 1)`。原来的 `fr` /
`fri` 已删：它们和 `f([%a_]+)` 触发词长度相同，LuaSnip 取最长匹配、平局先定义的
赢，单打 `fr` 永远拿不到；`f l r` 已覆盖同功能。
`strin` 包含 `.decode()`，因为 buffered input 返回 bytes。`dbg` 依赖已经
导入 `sys`，使用完整模板或 `fastin` 时会满足这一条件。

### C++ Snippet 对应版（19 个）

这些 snippet 的触发词与 C++ 版保持一致，展开结果改成 Python 惯用写法，
方便在两种语言间切换。没有 Python 对应物的 C++ snippet（`scanf` / `magic` /
`linklist` / `logdef` / `pii` / `all` / `in` / `ln` / `2f` 等）不迁移；与既有
Python snippet 冲突的 `f` / `rf` / `sc` / `main` / `dbg` 保留既有版本。

| Trigger | 默认展开结果 |
| --- | --- |
| `i0 a b c` | `a = b = c = 0` |
| `ci a b` | `a, b = map(int, input().split())` |
| `co a b c` | `print(a, b, c)` |
| `lg a b` | `print(a, b, file=sys.stderr)` |
| `so a` | `a.sort()` |
| `rs a` | `a.reverse()` |
| `uq a` | `a = sorted(set(a))` |
| `pq q` | `q = []`（配合 `heapq`） |
| `pqg q` | `q = []`（配合 `heapq`） |
| `lb a x` | `bisect_left(a, x)` |
| `ub a x` | `bisect_right(a, x)` |
| `vi a n` | `a = [0] * (n + 1)` |
| `vl a n` | `a = [0] * (n + 1)` |
| `re x` | `return x` |
| `ef u` | `for v, w in g[u]:` 遍历邻接表 |
| `ee m` | 读 m 条有向无权边到 `g` |
| `eew m` | 读 m 条有向带权边到 `g` |
| `ee2 m` | 读 m 条无向无权边到 `g` |
| `ee2w m` | 读 m 条无向带权边到 `g` |

图相关 snippet 使用邻接表 `g`，与 C++ 的链式前向星接口不同：
`ee` 系列把边读入 `g[u].append(v)`（带权时 append `(v, w)`），`ef u`
遍历 `for v, w in g[u]:`。使用前需先建立 `g = [[] for _ in range(n + 1)]`。

### 通用 snippets（29 个）

这些 snippets 来自 `all-snippets/vscode-snippets/python.json`，Neovim 和 VSCode 使用
相同的 trigger 和 placeholder。`main`（buffered input、`solve()` 和 main guard）
原先定义在 `all-snippets/lua-snippets/python.lua`，现已迁移到这里，触发词不变。

| Trigger | 默认展开结果 |
| --- | --- |
| `main` | `readline` 输入、`solve()` 和 main guard |
| `mainread` | 一次性读取整数、`solve(data)` 和 main guard |
| `input` | 用迭代器一次性读完 `sys.stdin.buffer`，构造 `tokens` / `n` / `a` |
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
| `ta` | Python 3.10 `TypeAlias`（旧式写法） |
| `type` | PEP 695 `type` 语句定义类型别名（Python 3.12+，如 `type PrevMap = dict[int, int]`；泛型把 `Name` 写成 `Name[T]`） |
| `opt` | `name: Type | None = None` |

`lc`、`sc`、`dictc` 和 `gen` 默认不带过滤条件；展开后按 `<C-E>` 可
切换为 `if condition`。

检查 snippets 是否加载：

```vim
:lua print(#require("luasnip").get_snippets("python"))
```

应输出 `74`：45 个 OJ snippets 加 29 个通用 snippets。

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
| `<Leader>dw` | 将光标处变量加入 disp（Watches）窗口 |
| `<Leader>de` | 输入要持续监视的表达式 |
| `<Leader>dr` | 切换右栏（REPL+disp） |
| `<Leader>dt` | 结束调试 |

典型流程：

1. 把光标放在目标行，按 `<F6>` 设置断点。
2. 按 `<F5>`，在弹出的窗口中选择输入文件，回车启动；Esc 取消。
3. 程序停下后使用 `<F7>`、`<F8>`、`<F9>`。
4. 右侧一栏分上下两格：上= DAP（REPL），下= disp（Watches）；`<Leader>dr`
   切换整栏。光标放在变量上按 `<Leader>dw`
   添加持续监视；用 `<Leader>de` 添加 `len(prev)`、`people[0]` 等表达式。
5. 按 `<F4>` 结束。

### 调试时输入数据

启动选择器查找源码目录及三层子目录中的 `in`、`*.in`、`*.txt`、`in1` 等文件。
输入名称可过滤，回车选择；无需输入的程序选“空输入”。输入文件通过启动辅助脚本
接到标准输入，兼容 `input()`、`readline()` 和 `sys.stdin.buffer.read()`，不修改题解源码，
也不需要手动发送 EOF。调试工作目录为源码所在目录。

stdout/stderr 显示在 REPL 中。暂停后可在 REPL 输入 Python 表达式求值。
disp 中的表达式会在暂停、单步时刷新；在 Watches 窗口按 `i` 可新增表达式，
`d` 删除当前监视项，`e` 编辑，回车展开字典、列表等对象。

### REPL 的 gdb 风格命令

右侧 DAP（REPL）窗口同时是命令行，支持 cgdb/gdb 命令（实现见
`lua/plugins/dap/repl_commands.lua`）：

| 命令 | 作用 |
| --- | --- |
| `n` / `next` | Step Over（同 `<F8>`） |
| `s` / `step` | Step Into（同 `<F7>`） |
| `fin` / `finish` | Step Out（同 `<Leader>do`） |
| `c` / `continue` | 继续（同 `<F5>`） |
| `until [N]` | 跑到光标行；`until 36` 先跳到 36 行再跑过去（≈ `<F9>`） |
| `b` | 当前行设断点 |
| `b if 条件` | 当前行条件断点 |
| `b 文件:行号 [if 条件]` | 指定位置断点，如 `b 3.py:36 if x > 3` |
| `b 函数名` | 断在函数体首行（装饰器不计入；单行函数不准） |
| `p 表达式` | 求值，如 `p n`、`p len(prev)` |
| `bt` / `where` | 打印调用栈 |
| `locals` / `info locals` | 打印局部变量 |
| `display 表达式` / `undisplay 表达式` | 加入 / 移出 disp（Watches） |

注意：命令分发优先于表达式求值，所以 `n`/`s`/`b`/`c` 不再是变量名；
看这些变量请用 `p n`，或直接看行内 virtual-text、disp。
`d`/`kill`/`q`/`run` 故意不注册为命令（避免误清断点/误杀会话），
这些词仍可作为变量求值；结束会话用 `<F4>`，重启用 `<Leader>dn`。

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
2. 用前面的 Lua 命令确认数量是 74。
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
