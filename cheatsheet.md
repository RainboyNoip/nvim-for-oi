# Rainboy Cheat Sheet

这个文件是 `<Leader>oh` 浮动窗口的内容源，手工维护。

> `<Leader>` 菜单（which-key）的每个条目都带 Nerd Font 图标，字形名与码点逐个核对过本机字体。
> 本文件只列「你按得出来」的键；键位的真源是 `lua/keymaps.lua` 和各插件的 `keys`。

## 通用编辑

| 快捷键 | 说明 |
| --- | --- |
| `<C-s>` | 保存当前文件（Normal / Insert 模式；Visual / Select 模式是 `vim.lsp.buf.signature_help()`） |
| `<C-h/j/k/l>` | 在窗口间移动 |
| `<C-Up/Down>` | 调整窗口高度 |
| `<C-Left/Right>` | 调整窗口宽度 |
| `<A-Up/Down>` | 上下移动当前行 |
| `<` / `>` | Visual 模式缩进并保持选区 |
| `g;` / `g,` | 跳转到上/下一个编辑位置 |
| `<Leader>?` | 显示当前 buffer 的 which-key 快捷键 |
| `<Leader>oh` | 打开这个 cheat sheet |
| `<S-h>` / `<S-l>` | 上/下一个 buffer |
| `[b` / `]b` | 上/下一个 buffer |
| `[B` / `]B` | 向左/右移动 buffer |
| `<C-/>` | 行注释切换（Normal / Visual / Select 模式都可用） |
| `gcc` / `gbc` | 当前行行注释 / 块注释切换 |
| `gc` / `gb` + motion | 按 motion 注释，例如 `gcap` / `gbap` |
| Visual `gc` / `gb` | 选区行注释 / 块注释切换 |
| `<Leader>cc` / `<Leader>cb` | 行注释 / 块注释切换 |

> 注释键由 Comment.nvim 提供，注释符跟随 filetype：C++ 是 `//` 与 `/* */`，Python 是 `#`。
> 所以它们是**通用键**，不存在「Python 专属版本」。

## Buffer 管理

| 快捷键 | 说明 |
| --- | --- |
| `<Leader>bp` | 固定 / 取消固定 buffer |
| `<Leader>bP` | 关闭未固定 buffer |
| `<Leader>br` | 关闭右侧 buffer |
| `<Leader>bl` | 关闭左侧 buffer |

## OI / 模板入口

| 快捷键 | 说明 |
| --- | --- |
| `<Leader>os` | 选择 file snippet（`all_snippets/oi-snippets/files/`） |
| `<Leader>of` | Rbook 正式代码模板（按当前语言过滤） |
| `<Leader>oe` | Rbook 浏览代码文件（按当前语言过滤） |
| `<Leader>op` | 选择复制命令并复制当前 buffer |
| `<Leader>r` | Rbook 题解 / 模板分组 |
| `<Leader>rc` | Rbook 正式代码模板（按当前语言过滤） |
| `<Leader>rf` | Rbook 浏览代码文件（按当前语言过滤） |
| `<Leader>rr` | Rbook 刷新索引 |
| `<Leader>rd` | Rbook 检查模板索引 |

> Rbook 的两个浏览命令会按当前 buffer 的 filetype 过滤：`.cpp`（及 `c`/`h`/`hpp`）
> 只列 `.cpp/.cc/.cxx`，`.py` 只列 `.py`；`markdown`/`text`/无 filetype 不过滤。
> 想强制看全部用 `:RbookCodeFiles!` / `:RbookCode!`。

## AI 补全（Minuet）

需要设置 `DEEPSEEK_API_KEY`，详见 `docs/how-to-use-ai-completion.md`。

⚠ 下面前 5 个 `<M-*>` 键是**条件注册**的（`lua/plugins/minuet.lua` 里写成
`accept = has_deepseek_key and "<M-a>" or nil`）：**没设 `DEEPSEEK_API_KEY` 时这些键根本不存在**。
而 `<Leader>at` / `<Leader>af` / `<Leader>ac` 是无条件注册的。

| 快捷键 | 说明 |
| --- | --- |
| `<M-a>` | 接受当前建议的所有行 |
| `<M-l>` | 接受当前建议的一行 |
| `<M-]>` | 请求或切换到下一条建议 |
| `<M-[>` | 切换到上一条建议 |
| `<M-e>` | 取消当前建议 |
| `<Leader>at` | 切换当前 buffer 自动 AI 补全 |
| `<Leader>af` | 切换到 Fast 模式 |
| `<Leader>ac` | 切换到 Choice 模式 |

## C++ Buffer

只有一个是真正 C++ 专属的键（实现在 `lua/local/cpp-settings/`）：

| 快捷键 | 说明 |
| --- | --- |
| `<Leader>;` | 当前行末尾补分号（只在 C/C++ buffer 里存在） |

注释类键（`<C-/>` / `gcc` / `gbc` / `gc` / `gb`）已移到上面的「通用编辑」，
它们与语言无关，Python 里同样可用。

## LuaSnip 操作

| 快捷键 | 说明 |
| --- | --- |
| `<C-K>` | 展开 snippet |
| `<Tab>` | 跳到下一个节点 / 展开片段（补全菜单开着时优先选补全项） |
| `<S-Tab>` | 补全菜单开着时选上一项，否则跳上一个节点 |
| `<C-J>` | 跳到上一个节点 |
| `<C-n>` / `<C-p>`（**select 模式**） | 下/上一个 choice |

> 两个已知的键位冲突，**有意保留现状**（分析见 `docs/config-optimization.md` §1.2）：
>
> - `i <C-L>` 被 `lua/keymaps.lua` 覆盖成 `<C-o>$`（跳到行尾），所以 LuaSnip 原本绑在
>   `<C-L>` 的**正向跳节点用不了**，正向跳请用 `<Tab>`。
> - `i <C-E>` 被 nvim-cmp 的 `<C-e>`（关闭补全菜单）覆盖，所以**切 choice 用 select
>   模式的 `<C-n>` / `<C-p>`**，不是 `<C-E>`。

## Snacks / Picker

| 快捷键 | 说明 |
| --- | --- |
| `<Leader>e` | 打开 Snacks Explorer |
| `<Leader>t` | 终端分组 |
| `<Leader>tt` | 切换 Snacks Terminal |
| `<Leader>tc` | 选择已有 terminal 并切换 |
| `<Leader>tf` | 打开 bash terminal |
| `<Leader>s` | 搜索 / 跳转分组 |
| `<Leader>sf` | 当前文件符号，支持 C++ 和 Python |
| `<Leader>sj` | 跳转历史 |
| `<Leader>sb` | Buffer 列表 |
| `<Leader>sd` | 项目诊断 |
| `<Leader>sD` | 当前 buffer 诊断 |
| `<Leader>sc` | 当前文件更改位置 |
| `<Leader>sz` | 专注模式 |

`<Leader>sf` 依赖当前语言的 LSP symbols。C++ 使用 clangd，Python 使用 BasedPyright。

## C++ Snippets

Snippet 按用途拆在 `all_snippets/lua-snippets/` 下（C++ 入口 `cpp.lua`、Python 入口 `python.lua`，
实现模块在 `cpp/`，共享工具在 `utils.lua`）。三组 snippet 的术语与边界见 CONTEXT.md 与
`docs/adr/0001-snippet-asset-layout.md`。

| 触发 | 展开结果 |
| --- | --- |
| `main` | 最小 `main` 模板 |
| `magic` | `std::ios::sync_with_stdio(false);` 和 `std::cin.tie(nullptr);` |
| `f` | `for(int i = 1; i <= n; ++i)`，展开后可改循环变量名并同步 |
| `lf` | 单行 `for(int i = 1; i <= n; ++i)` |
| `f n` | `for(int i = 1; i <= n; ++i)`，上界来自输入，循环变量可改 |
| `f l r` | `for(int i = l; i <= r; ++i)`，循环变量可改 |
| `rf` | `for(int i = n; i >= 1; --i)`，展开后可改循环变量名并同步 |
| `rf n` | `for(int i = n; i >= 1; --i)`，起点来自输入 |
| `rf l r` | `for(int i = r; i >= l; --i)`，循环变量可改 |
| `2f` | 双层 `FF(i,n)` / `FF(j,m)` |

## Python OJ Snippets

| 触发 | 展开结果 |
| --- | --- |
| `main` | buffered input、`solve()` 和 main guard |
| `solve` | `def solve():` |
| `fastin` | `input = sys.stdin.buffer.readline` |
| `ii` | `n = int(input())` |
| `ints` | `a, b = map(int, input().split())` |
| `listi` | `a = list(map(int, input().split()))` |
| `strin` | `s = input().strip().decode()` |
| `f` | `for i in range(1, n + 1):`（与 C++ 的 `f` 一致） |
| `lf` | 单行 `for i in range(1, n + 1):` |
| `f n` | 上界来自输入（`range(1, n + 1)`） |
| `f l r` | 指定闭区间（`range(1, 11)`，能算出数值就直接算） |
| `fabc l r` | 自定义循环变量 + 区间 |
| `fabc n` | 自定义循环变量 + 上界 |
| `fabc` | 自定义循环变量的默认循环 |
| `rf` | `for i in range(n, 0, -1):`（与 C++ 的 `rf` 一致） |
| `rf n` | 倒序，起点来自输入 |
| `rf l r` | 指定区间的倒序 |
| `enum` | `for index, value in enumerate(items):` |
| `tests` | 读取测试组数并重复调用 `solve()` |
| `heap` | 导入 `heapq` 并初始化最小堆 |
| `bisect` | 导入 `bisect_left` / `bisect_right` |
| `deque` | 导入并初始化 `deque` |
| `dbg` | `print(value, file=sys.stderr)` |

## Python: C++ Snippet 对应版

以下 snippet 触发词与 C++ 版保持一致，展开结果改成 Python 惯用写法，方便在两种语言间切换。
没有 Python 对应物的 C++ snippet（`scanf` / `magic` / `linklist` / `logdef` / `pii` / `all` / `in` / `ln` / `2f` 等）不迁移；与既有 Python snippet 冲突的 `f` / `rf` / `sc` / `main` / `dbg` 保留既有版本。

for 循环现在与 C++ 的 `for.lua` 一一对应（触发词、正则捕获、循环变量规则都对齐）：

| C++ | Python | 展开 |
| --- | --- | --- |
| `f` | `f` | `for i in range(1, n + 1):` |
| `f n` | `f n` | 上界来自输入 |
| `f l r` | `f l r` | 指定闭区间 |
| `fabc l r` | `fabc l r` | 自定义循环变量 + 区间 |
| `fabc n` | `fabc n` | 自定义循环变量 + 上界 |
| `fabc` | `fabc` | 自定义循环变量 |
| `lf` | `lf` | 单行 |
| `rf` / `rf n` / `rf l r` | 同 | 倒序版本 |

> 原来的 `fr` / `fri` 已删：它们的触发词长度和 `f([%a_]+)` 完全相同，LuaSnip 取最长匹配、
> 平局时先定义的赢，于是单打 `fr` 永远拿不到 `for r in ...`。`f l r` 已覆盖同功能。
> `2f` 不迁移：C++ 版依赖模板里的 `FF` 宏，Python 无对应物。

| 触发 | 展开结果 |
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

图相关 snippet 使用邻接表 `g`（与 C++ 的链式前向星 `e` 不同）：使用前先建
`g = [[] for _ in range(n + 1)]`。`ee` 系列写入 `g[u].append(v)`（带权时 append `(v, w)`），
`ef u` 展开为 `for v, w in g[u]:`。

## Python 通用 Snippets

这些 snippets 同时由 Neovim 和 VSCode 从 `all_snippets/vscode-snippets/python.json` 加载。

| 触发 | 展开结果 |
| --- | --- |
| `df` | 定义无类型注解函数 |
| `dft` | 定义带类型注解函数 |
| `adf` | 定义异步函数 |
| `lm` | 命名 lambda 表达式 |
| `cls` | 最小 class 骨架 |
| `init` | 构造函数和属性初始化 |
| `dcls` | 普通 `@dataclass` |
| `prop` | property getter + setter |
| `deco` | 使用 `wraps` 的装饰器 |
| `ifm` | Python main guard |
| `ife` | `if / else` |
| `mt` | `match / case / _` |
| `fe` | `enumerate` 循环 |
| `wh` | `while` 循环 |
| `tr` | `try / except` |
| `trf` | `try / except / finally` |
| `wth` | `with ... as ...` |
| `ctx` | 函数式 context manager |
| `flow` | 按顺序执行多个函数转换 |
| `lc` | 列表推导式，可选过滤条件 |
| `sc` | 集合推导式，可选过滤条件 |
| `dictc` | 字典推导式，可选过滤条件 |
| `gen` | 生成器表达式，可选过滤条件 |
| `ta` | Python 3.10 类型别名 |
| `opt` | 可选变量声明 |

## Python 调试

> **注意**：DAP 已暂时禁用 (2026-08-22)，改用终端 cgdb/gdbgui。恢复方法见 readme.md。
>
> 原来的 `<F4>`–`<F9>`、`<Leader>dw`、`<Leader>dr` 共 8 个键**当前全部不存在**，
> 所以这里不再列出来 —— 具体原因：`lua/plugins/dap.lua` 整块被注释，而
> `lua/plugins/dap/keys.lua` 虽然是个 spec 文件，却没有任何地方 `import` 它
> （`import = "plugins"` 只匹配顶层 `lua/plugins/*.lua`，不递归子目录）。

调试前先保存当前文件。标准输入在 debugpy 打开的集成终端中输入。

## STL / OJ Snippets

| 触发 | 展开结果 |
| --- | --- |
| `all a` | `a.begin(), a.end()` |
| `so a` | `sort(a.begin(), a.end());` |
| `rs a` | `reverse(a.begin(), a.end());` |
| `uq a` | `a.erase(unique(a.begin(), a.end()), a.end());` |
| `lb a x` | `lower_bound(a.begin(), a.end(), x) - a.begin()` |
| `ub a x` | `upper_bound(a.begin(), a.end(), x) - a.begin()` |
| `vi a n` | `vector<int> a(n + 1);` |
| `vl a n` | `vector<long long> a(n + 1);` |
| `pii` | `pair<int,int>` |
| `pq q` | `priority_queue<int> q;` |
| `pqg q` | `priority_queue<int, vector<int>, greater<int>> q;` |

## Graph / Linklist Snippets

这些 snippet 面向 `linklist` 图存储，默认图对象名是 `e`。

| 触发 | 展开结果 |
| --- | --- |
| `ef u` | 遍历 `e.h[u]`，自动取 `v = e[i].v` 和 `w = e[i].w` |
| `ee m` | 读 `m` 条有向无权边并 `e.add(u,v);` |
| `eew m` | 读 `m` 条有向带权边并 `e.add(u,v,w);` |
| `ee2 m` | 读 `m` 条无向无权边并 `e.add2(u,v);` |
| `ee2w m` | 读 `m` 条无向带权边并 `e.add2(u,v,w);` |

## Debug Snippets

这些 snippet 使用模板里的 `log(...)` / `fenc` 调试宏；`logdef` 可在临时代码里补完整宏定义。

| 触发 | 展开结果 |
| --- | --- |
| `lg a b c` | `log(a,b,c);` |
| `logdef` | 插入 `log/fenc/err` 调试宏定义，OJ / `NO_DEBUG` 下自动关闭 |

## IO Snippets

| 触发 | 展开结果 |
| --- | --- |
| `ln` | `out.ln();` |
| `i a b c` | `int a,b,c;` |
| `i0 a b c` | `int a=0,b=0,c=0;` |
| `ci a b c` | `std::cin >> a >> b >> c;` |
| `ci a[1] a[2]` | `std::cin >> a[1] >> a[2];` |
| `co a b c` | `std::cout << a << b << c;` |
| `in a b c` | `in.read(a,b,c);` |
| `sc a b` | `scanf("%d%d",&a,&b);` |
| `scc ch` | `scanf("%c",&ch);` |
| `scl x y` | `scanf("%lld%lld",&x,&y);` |
| `re x` | `return x;` |
| `linklist` | `linklist<maxn> e;` 并自动补 `#include "graph/linklist.hpp"` |

## 关闭

| 快捷键 | 说明 |
| --- | --- |
| `q` / `<Esc>` | 关闭 cheat sheet 浮窗 |
