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
| `<Leader>of` | Rbook 正式代码模板 |
| `<Leader>oe` | Rbook 浏览全部代码文件 |
| `<Leader>op` | 选择复制命令并复制当前 buffer |
| `<Leader>r` | Rbook 题解 / 模板分组 |
| `<Leader>rc` | Rbook 正式代码模板 |
| `<Leader>rf` | Rbook 浏览全部代码文件 |
| `<Leader>ra` | Rbook 打开文章 |
| `<Leader>rr` | Rbook 刷新索引 |
| `<Leader>rd` | Rbook 检查模板索引 |

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
| `<Leader>sf` | 当前文件符号，C++ 中可用于函数/方法跳转 |
| `<Leader>sj` | 跳转历史 |
| `<Leader>sb` | Buffer 列表 |
| `<Leader>sd` | 项目诊断 |
| `<Leader>sD` | 当前 buffer 诊断 |
| `<Leader>sc` | 当前文件更改位置 |
| `<Leader>sz` | 专注模式 |

`<Leader>sf` 依赖 clangd 的 LSP symbols。当前 C++ 文件存在严重语法错误时，列表可能为空。

## C++ Snippets

Snippet 按用途拆在 `lua/snippets/` 下；公共捕获和转换工具在 `lua/snippets/utils.lua`。

| 触发 | 展开结果 |
| --- | --- |
| `main` | 最小 `main` 模板 |
| `magic` | `std::ios::sync_with_stdio(false);` 和 `std::cin.tie(nullptr);` |
| `f` | `for(int i = 1; i <= n; ++i)` |
| `lf` | 单行 `for(int i = 1; i <= n; ++i)` |
| `f n` | `for(int i = 1; i <= n; ++i)`，上界来自输入 |
| `f l r` | `for(int i = l; i <= r; ++i)` |
| `fi` | `for(int i = 1; i <= n; ++i)`，变量名来自 `f` 后面的字符 |
| `fi n` | `for(int i = 1; i <= n; ++i)`，变量名和上界来自输入 |
| `fi l r` | `for(int i = l; i <= r; ++i)`，变量名和区间来自输入 |
| `fj` / `fk` | `for(int j/k = 1; j/k <= n; ++j/k)` |
| `rf` | `for(int i = n; i >= 1; --i)` |
| `rf n` | `for(int i = n; i >= 1; --i)`，起点来自输入 |
| `rfi n` | `for(int i = n; i >= 1; --i)`，变量名和起点来自输入 |
| `rfi l r` | `for(int i = r; i >= l; --i)`，变量名和区间来自输入 |
| `2f` | 双层 `FF(i,n)` / `FF(j,m)` |

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
