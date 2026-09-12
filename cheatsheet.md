# Rainboy Cheat Sheet

这个文件是 `<Leader>oh` 浮动窗口的内容源，手工维护。

## 通用编辑

| 快捷键 | 说明 |
| --- | --- |
| `<C-s>` | 保存当前文件 |
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
| `<Leader>os` | 选择 `oiSnippets/` 代码片段 |
| `<Leader>of` | Rbook 正式代码模板（按当前语言过滤） |
| `<Leader>oe` | Rbook 浏览代码文件（按当前语言过滤） |
| `<Leader>op` | 选择复制命令并复制当前 buffer |
| `<Leader>r` | Rbook 题解 / 模板分组 |
| `<Leader>rc` | Rbook 正式代码模板（按当前语言过滤） |
| `<Leader>rf` | Rbook 浏览代码文件（按当前语言过滤） |
| `<Leader>ra` | Rbook 打开文章 |
| `<Leader>rr` | Rbook 刷新索引 |
| `<Leader>rd` | Rbook 检查模板索引 |

> Rbook 的两个浏览命令会按当前 buffer 的 filetype 过滤：`.cpp`（及 `c`/`h`/`hpp`）
> 只列 `.cpp/.cc/.cxx`，`.py` 只列 `.py`；`markdown`/`text`/无 filetype 不过滤。
> 想强制看全部用 `:RbookCodeFiles!` / `:RbookCode!`。

## AI 补全（Minuet）

需要设置 `DEEPSEEK_API_KEY`，详见 `docs/how-to-use-ai-completion.md`。

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

| 快捷键 | 说明 |
| --- | --- |
| `<Leader>;` | 当前行末尾补分号 |
| `<C-/>` | 行注释切换 `//`，等价于 `gcc` / Visual `gc` |
| `<Leader>cc` | 行注释切换 `//`，等价于 `gcc` / Visual `gc` |
| `<Leader>cb` | 块注释切换 `/* */`，等价于 `gbc` / Visual `gb` |
| `gcc` | 当前行行注释切换 `//` |
| `gc` + motion | 按 motion 行注释切换，例如 `gcap` |
| Visual `gc` | 选区行注释切换 `//` |
| `gbc` | 当前行块注释切换 `/* */` |
| `gb` + motion | 按 motion 块注释切换 |
| Visual `gb` | 选区块注释切换 `/* */` |

## Python Buffer

| 快捷键 | 说明 |
| --- | --- |
| `<C-/>` | 行注释切换 `#`，等价于 `gcc` / Visual `gc` |
| `<Leader>cc` | 行注释切换 `#` |
| `<Leader>sf` | 当前 Python 文件符号 |
| `<Leader>sD` | 当前 Python buffer 诊断 |

## LuaSnip 操作

| 快捷键 | 说明 |
| --- | --- |
| `<C-K>` | 展开 snippet |
| `<C-L>` / `<C-J>` | 跳到下/上一个 snippet 节点 |
| `<C-E>` | 切换 choice 节点 |
| `<C-n>` / `<C-p>` | 下/上一个 choice |

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

Snippet 按用途拆在 `lua/snippets/` 下；公共捕获和转换工具在 `lua/snippets/utils.lua`。

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
| `f` | `for i in range(n):` |
| `fr` | `for i in range(left, right):`，半开区间 |
| `fri` | `for i in range(left, right + 1):`，闭区间 |
| `rf` | `for i in range(n - 1, -1, -1):` |
| `enum` | `for index, value in enumerate(items):` |
| `tests` | 读取测试组数并重复调用 `solve()` |
| `heap` | 导入 `heapq` 并初始化最小堆 |
| `bisect` | 导入 `bisect_left` / `bisect_right` |
| `deque` | 导入并初始化 `deque` |
| `dbg` | `print(value, file=sys.stderr)` |

## Python: C++ Snippet 对应版

以下 snippet 触发词与 C++ 版保持一致，展开结果改成 Python 惯用写法，方便在两种语言间切换。
没有 Python 对应物的 C++ snippet（`scanf` / `magic` / `linklist` / `logdef` / `pii` / `all` / `in` / `ln` / `2f` 等）不迁移；与既有 Python snippet 冲突的 `f` / `rf` / `sc` / `main` / `dbg` 保留既有版本。

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

这些 snippets 同时由 Neovim 和 VSCode 从 `vscode-snippets/python.json` 加载。

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

> **注意**：DAP 已暂时禁用 (2026-08-22)，改用终端 cgdb/gdbgui。以下快捷键当前无效，恢复方法见 readme.md。

调试前先保存当前文件。标准输入在 debugpy 打开的集成终端中输入。

| 快捷键 | 说明 |
| --- | --- |
| `<F4>` | 结束调试 |
| `<F5>` | 启动 / 继续 |
| `<F6>` | 切换断点 |
| `<F7>` | Step Into |
| `<F8>` | Step Over |
| `<F9>` | Run to Cursor |
| `<Leader>dw` | 查看光标处变量 |
| `<Leader>dr` | 切换 DAP REPL |

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
