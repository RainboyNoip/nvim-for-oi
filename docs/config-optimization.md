# rainboyVim-for-oi 配置优化清单（只写 C++ / Python）

评估范围：`init.lua`、`lua/options.lua`、`lua/keymaps.lua`、`lua/lsp.lua`、`lua/lsp/*`、
`lua/plugins/*`、`lua/local/cpp-settings`、`lua/local/python-settings`、`lua/fileSnip.lua`。

前提：只用 C++ 和 Python 打 OI / OJ，单文件 `main.cpp` 为主，无 `compile_commands.json`，
不做跨文件重构，不要求自动格式化。

结论：**启动链路是健康的，不需要为了"快"去砍插件。真正该做的是修 3 个功能 bug +
清掉 clangd / cmp 里对本场景无用的开销。**

---

## 修复进度总览

图例：✅ 已修 · ⏸ 决定不修（保留现状，理由见对应节）· ⬜ 待修

| 编号 | 项 | 状态 | 落地位置 |
| --- | --- | --- | --- |
| 1.1 | `<leader>os/oe/of/;` 只在第一个 buffer 有效 | ✅ 已修 (`2026-09`) | `lua/fileSnip.lua`、`lua/local/cpp-settings/lua/cpp-settings.lua` |
| 1.2 | snippet 跳转键被 `keymaps.lua` 覆盖 | ⏸ 不修（保留 `<C-l>` 行尾） | —（分析见 §1.2） |
| 1.3 | nvim-cmp 引用未安装的 `lazydev` 源 | ✅ 已修 (`2026-09`) | `lua/plugins/nvim-cmp.lua` |
| 2.1 | clangd 参数（`--background-index` / `--clang-tidy` / `iwyu`） | ⬜ 待修 | `lua/lsp/clangd.lua:4-11` |
| 2.2 | `filetypes = { 'cpp' }` 太窄 | ⬜ 待修 | `lua/lsp/clangd.lua:13` |
| 2.3 | 字典补全源 → 内存 OI 词表源（方案 A） | ✅ 已重做 (`2026-09`) | `lua/plugins/nvim-cmp.lua`（自定义 cmp source） |
| 2.4 | `InsertLeave` 自动保存 | ⬜ 待修 | `lua/options.lua:60-70` |
| 2.5 | Minuet AI 默认自动触发 | ⬜ 待修 | `lua/plugins/minuet.lua` |
| 2.6 | cmp `<Tab>` 判定顺序 | ⬜ 待修 | `lua/plugins/nvim-cmp.lua:74-96` |
| 2.7 | LuaSnip 启动期 eager 加载 | ✅ 已修 (`2026-09`) | `lua/plugins/LuaSnip.lua` |
| 2.8 | `completeopt` 被设置两次 | ⬜ 待修 | `lua/options.lua:3` |
| 3 | P2 可删项（9 项，含两套模板入口） | ⬜ 待修 | 见 §3 表 |
| 4.1 | clangd 缺 `executable()` 保护 | ⬜ 待修 | `lua/lsp.lua` |

**已完成的改动合计 4 个 lua 文件 + 删 `dictionary/` + `lazy-lock.json`**。启动时间：空启动
42.8–55.2 ms → **23.0–24.4 ms**（2.7 的收益，只在不开 cpp/python 的场景体现），
`nvim x.cpp` 63.1–64.0 ms（基本不变，见 §2.7 的"诚实的代价"）。

---

## 0. 实测数据（本机 NVIM v0.12.5，`NVIM_APPNAME=rainboy-nvim-for-oi`）

| 场景 | 暖启动耗时 | 备注 |
| --- | --- | --- |
| 空启动 | 41–63 ms | 冷启动 122 ms |
| `nvim main.cpp` | 64–71 ms | clangd 异步挂载，不计入启动 |
| `nvim sol.py` | 107–124 ms | basedpyright 冷启动 |

启动期只加载 6 个插件：`Comment.nvim`、`LuaSnip`、`nvim-treesitter`、`nvim-web-devicons`、
`snacks.nvim`、`vim-nightfly-colors`。其余全部由 `ft` / `keys` / `event` 懒加载。

复现命令：

```sh
nvim --startuptime /tmp/st.log --headless +qa
sort -k2 -nr /tmp/st.log | head -20
```

**所以：任何"再砍几个插件让启动更快"的想法收益都在 10 ms 量级，优先级排到最后。**

---

## 1. P0 — 功能 bug（这几个比任何性能项都值得先修）

> **修复状态（2026-09）**：1.1 ✅ 已修、1.2 ⏸ 决定不修（保留 `<C-l>` 行尾跳转）、1.3 ✅ 已修。
> 改动只涉及 `lua/fileSnip.lua`、`lua/local/cpp-settings/lua/cpp-settings.lua`、
> `lua/plugins/nvim-cmp.lua` 三个文件，启动时间无退化（45–53 ms / cpp 73 ms）。

### 1.1 `<leader>os` / `<leader>oe` / `<leader>of` / `<leader>;` 只在第一个 buffer 有效 ✅ 已修

**位置**
- `lua/fileSnip.lua:81`、`:84`、`:86`
- `lua/local/cpp-settings/lua/cpp-settings.lua:51`

**现状**：这些 keymap 用 `{ buffer = true }` 注册，但注册时机是 `fileSnip.setup()`
（`init.lua` 里同步调用）和 `cpp-settings.setup()`（插件 `config()` 里一次性执行）。
`buffer = true` 绑的是**执行那一刻的 current buffer**，不是"所有 cpp buffer"。

**后果**：`nvim a.cpp` 再 `:e b.cpp`，b.cpp 里这四个键全部消失。实测
`maparg('<leader>os','n',false,true)` 在第二个 buffer 返回空表（`desc = nil`）。
也就是说从 dashboard 或 snacks picker 打开第二个文件之后，OI 模板入口就废了 —— 这
是本次审计里对"效率"伤害最大的一条。

**改法 A（推荐：全局键 + 命令自带上下文）**

```lua
-- lua/fileSnip.lua: M.setup() 内
vim.keymap.set('n', '<leader>os', "<cmd>OISnipChoose<cr>", { silent = true, desc = "oiSnippets" })
vim.keymap.set('n', '<leader>oe', "<cmd>RbookCodeFiles<cr>", { silent = true, desc = "Rbook 浏览全部代码文件" })
vim.keymap.set('n', '<leader>of', "<cmd>RbookCode<cr>", { silent = true, desc = "Rbook 正式代码模板" })
```

插入目标永远是当前 window 的 buffer（`insert_code_snippet` 已用
`nvim_get_current_buf()`），所以全局绑定是安全的。

**改法 B（如果确实想限定 cpp/python buffer）**

```lua
-- cpp-settings.lua: setup() 里换成 autocmd
local group = vim.api.nvim_create_augroup("RainboyCppKeys", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "cpp", "h", "hpp", "cc", "cxx" },
  callback = function(ev)
    vim.keymap.set('n', '<leader>;', conditional_add_semicolon_normal,
      { buffer = ev.buf, silent = true, desc = "在行尾添加分号" })
  end,
})
```

**验收**

```sh
nvim --headless a.cpp -c 'e b.cpp' \
  -c 'lua print("os:", vim.inspect(vim.fn.maparg("<leader>os","n"))) print(";:", vim.inspect(vim.fn.maparg("<leader>;","n")))' -c 'qa!'
```
两个键都要有 `desc`，不能是空串。

**实际改动（✅ 已完成）**

采用了两个不同的手法，因为两者语义不同：

1. `lua/fileSnip.lua:81,84,86` —— 三个键**改成全局**（删 `buffer = true`，`:cmd...<CR>` 换成
   `<cmd>...<cr>`）。`insert_code_snippet()` 内部用 `nvim_get_current_buf()`，所以全局安全；
   `:RbookCode*` 由 rbook 的 `cmd = {...}` 懒加载触发，全局绑定不会丢。
2. `lua/local/cpp-settings/lua/cpp-settings.lua` —— `<leader>;` **保持 buffer 局部**（它只对
   C/C++ 该生效），改成 `FileType` autocmd 逐 buffer 绑（`RainboyCppKeys` augroup，pattern
   `c/cpp/h/hpp/cc/cxx`）。

> ⚠ 这里有个容易遗漏的坑：lazy.nvim 是在 FileType 事件**之后**才加载插件的，所以触发
> 加载的那个 buffer 不会再过一遍新注册的 autocmd。因此 `setup()` 里除了建 autocmd，还
> 必须 `map_leader_semicolon()` 手动给当前 buffer 绑一次。只写 autocmd 会出现"第一个
> 文件反而没键"。

**验收结果**

| 场景 | `<leader>os/oe/of` | `<leader>;` |
| --- | --- | --- |
| buffer1 `a.cpp` | global ✓ | local ✓ |
| buffer2 `b.cpp` | global ✓ | local ✓（修复前 MISSING） |

命令存在性：`:OISnipChoose` / `:RbookCode` / `:RbookCodeFiles` 均为全局（`exists() == 2`）。

---

### 1.2 snippet 跳转键被 `keymaps.lua` 覆盖 ⏸ 决定不修

> **处理结果**：选择保留 `keymaps.lua:27-28` 的 i `<C-l>` / i `<C-h>` 行尾跳转（已形成
> 肌肉记忆），不动 LuaSnip 的键。接受的代价：片段内**正向**跳转只能靠 `<Tab>`（`<C-l>` 这条
> 路径作废），choice 只能靠 select 模式的 `<C-n>`/`<C-p>`（`keymaps.lua:46-47`）。
> 下面保留分析以备以后反悔。

**位置冲突**

| 键 | `lua/plugins/LuaSnip.lua` | 覆盖者 | 生效者 |
| --- | --- | --- | --- |
| i `<C-l>` | `:15` `ls.jump(1)` | `lua/keymaps.lua:27` → `<C-o>$` | keymaps（`init.lua` 最后加载） |
| i `<C-j>` | `:16` `ls.jump(-1)` | 无冲突 | LuaSnip（仍生效） |
| i `<C-e>` | `:17` `ls.change_choice(1)` | `lua/plugins/nvim-cmp.lua:52` → `cmp.mapping.abort()` | cmp（InsertEnter 时注册，更晚） |

Ctrl 模式下 `L`/`l`、`E`/`e` 是同一个键码，所以这是真冲突，不是"优先级选择"。
实测 i `<C-l>` 的 rhs 为 `<C-o>$`。现在片段前进只剩 `<Tab>`（且被补全菜单抢，见 2.6），
片段内正向跳转实际不可用。

`change_choice` 目前另有两条通道，所以不算完全丢失：`lua/keymaps.lua:46-47` 在 **select
模式**（LuaSnip 激活 choice 节点时的模式）绑了 `<C-n>`/`<C-p>` → `<Plug>luasnip-next-choice`。
但 i `<C-e>` 那个绑定确实是死的。

**改法**：把行内跳转换成终端/NeoVim 里不冲突的键，choice 交给 `<C-e>` 之外的键。

```lua
-- LuaSnip.lua：正向跳转换键，避开 i <C-l>
vim.keymap.set("i", "<C-K>", function() ls.expand() end, { silent = true, desc = "Snippet expand" })
vim.keymap.set("i", "<C-G><C-N>", function() ls.jump(1) end, { silent = true })
vim.keymap.set("i", "<C-G><C-P>", function() ls.jump(-1) end, { silent = true })
```

如果不想动键位，就直接删掉 `keymaps.lua:27-28` 的 i `<C-l>` / i `<C-h>`（`<End>` /
`<Home>` / `0` / `$` 已经够用），并把 cmp 的 `<C-e>` abort 改成 `<C-[>`。二选一，别两个都留。

---

### 1.3 nvim-cmp 引用了未安装的 source ✅ 已修

**位置**：`lua/plugins/nvim-cmp.lua:102`（原 `{ name = "lazydev" }`，已删除）

`lazydev.nvim` 不在 `lazy-lock.json`，也不在 `~/.local/share/rainboy-nvim-for-oi/lazy/`。
`:CmpStatus` 输出把它列在 **unknown source names**。删掉这一行（本配置不编辑 Lua 插件，
lazydev 的收益本来就是 0）。

**实际改动（✅ 已完成）**：删除 `lua/plugins/nvim-cmp.lua:102` 的 `{ name = "lazydev" }`。
验收：在 cpp buffer 里 `startinsert` 触发 cmp 后，实际加载的 sources 为
`buffer, dictionary, luasnip, minuet, path, nvim_lsp`，`lazydev present = false`。

同文件 `:33-36` 的 `require("cmp_dictionary").setup(...)` 与 `:105` 的 dictionary 源见 2.2。

---

## 2. P1 — 对"只写 C++/Python OI"无用的开销（2.3 ✅、2.7 ✅，其余 ⬜ 待修）

### 2.1 clangd 参数（`lua/lsp/clangd.lua:4-11`）⬜ 待修

当前：

```lua
cmd = { "clangd",
  "--background-index", "--clang-tidy", "--header-insertion=iwyu",
  "--completion-style=detailed", "--function-arg-placeholders", "--fallback-style=llvm" },
```

| 参数 | 判定 | 理由 |
| --- | --- | --- |
| `--background-index` | **删** | 没有 `compile_commands.json`；且 `root_markers` 含 `.git`（`lua/lsp/clangd.lua:17`），仓库根目录会成为索引作用域。`~/mycode` 下 5771 个 `.cpp`，一旦某个仓库真出现 `compile_commands.json`，就是整树索引 |
| `--clang-tidy` | **删** | 每次改动跑 readability/modernize，产生你不想看的诊断，且和 `oiSnippets/clangd_config` 里刻意关掉检查的思路矛盾 |
| `--header-insertion=iwyu` | **改 `never`** | 你写 `bits/stdc++.h`；iwyu 模式会在接受补全时往文件头插 `#include <vector>` 之类，反而要手删 |
| `--completion-style=detailed` | 保留 | cmp 里签名可读性好 |
| `--function-arg-placeholders` | 保留 | 配合 snippet/Tab 填参 |
| `--fallback-style=llvm` | 保留 | 只影响格式化，而你没开 format-on-save |

建议 cmd：

```lua
cmd = { "clangd",
  "--header-insertion=never",
  "--completion-style=detailed",
  "--function-arg-placeholders",
  "--fallback-style=llvm",
},
```

顺带把 `root_markers` 里的 `.git` 去掉，让 root 落回当前目录（或 `.clangd` 所在目录），
避免"一个仓库 = 一个 clangd 实例 + 一个巨大索引作用域"。跨仓库 `gd` 跳转本来就不需要。

### 2.2 `filetypes = { 'cpp' }`（`lua/lsp/clangd.lua:13`）⬜ 待修

这是功能缺口，不是性能问题：`.c` / `.h` / `.hpp` / `.cc` / `.cxx` 不挂 clangd，在
`oiSnippets/utils/*.cpp` 里 include 的头文件里没有补全和跳转。

```lua
filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "cc", "hh", "hpp", "hxx", "h" },
```

注意 `lua/plugins/treesitter.lua` 与 `lang-cpp.lua:5` 已经按 `{"cpp","h","hpp"}` 处理，
补齐后三处 filetype 集合应一致。

### 2.3 字典补全源 → 内存 OI 词表源 ✅ 已重做（方案 A）

**原始分析（已被推翻）**：原判断是"英文单词补全对 C++ 是纯噪音"，直接删。**这个判断错在
没先查词表内容**——用户实际上在用它，而且下面的查证表明"词表选错了"和"不需要补全"是两回事。

**查证（`git show 4380fb0`）**：commit message 写着 "Configured cmp_dictionary with a custom
word list file"，但实际文件就是**原版** `google-10000-english-no-swears.txt`（9894 行，频率序
`the/of/and/to/a...`），**一个 OI 词都没加过**。把它和 OI 常用 token 对一遍：

| 类别 | 命中 | 词表里**没有**的（关键部分） |
| --- | --- | --- |
| C++ 关键字 | 22/32 | `constexpr decltype noexcept override sizeof static_cast typedef typename volatile` |
| 容器/算法 | 15/36 | `priority_queue unordered_map unordered_set lower_bound upper_bound push_back emplace_back memset bitset tuple accumulate` |
| OI 变量名 | 15/36 | `INF ans cnt vis idx nxt cur dep deg sz fst snd lca dfs bfs` |
| Python | 39/47 | `None True False append dict tuple enumerate isinstance` |

规律：它只给**普通英文单词**（vector/queue/graph/edge/str/int/len/print），给不了**带下划线、
缩写、大写**的词；而后者恰恰是 OI 里最需要补全的。所以问题不是"该不该有补全源"，而是
**词表选错了**。

**决策（用户选方案 A）**：保留 OI 词表补全，但①词表放内存、不读文件；②约 20 个词；
③ `cpp` 与 `python` 都触发。

**实现（✅ 已完成）**

重要的实现偏差：**没有把 `cmp-dictionary` 装回来**。理由：`cmp_dictionary.setup()` 只接受
`paths`（文件路径），拿不到 Lua 内存表；为了满足"表格在内存里"，改成自己写一个约 50 行的
cmp source，效果一样但**零插件依赖、零文件 IO**。同时保留原来的激进参数（2 字符就提示、
大小写敏感）。

- `lua/plugins/nvim-cmp.lua` 顶部：`OI_WORDS` 内存表（20 词）、`OI_FILETYPES = {cpp, python}`、
  `oi_source`（实现 `is_available` / `get_keyword_length` / `complete`）。
- `opts` 里 `cmp.register_source("oi_words", oi_source.new())`，sources 里加 `{ name = "oi_words" }`，
  `source_mapping` 与 `menu` 各加 `oi_words = "[OI]"`。
- `buffer` 源的 `keyword_length` 从 `2` 提到 `3`（OI 单文件重复率高）。
- 原本删掉的部分保持不变：依赖、`dictionary/` 目录（`git rm -r`）、`lazy-lock.json` 条目均已移除。

**20 个词**（只放英文词典/LSP 给不了的）：
`priority_queue unordered_map unordered_set lower_bound upper_bound push_back
emplace_back memset sizeof` ｜ `INF dfs bfs lca ans cnt vis idx nxt` ｜ `defaultdict popleft`

**验收结果**

| 探针 | 结果 |
| --- | --- |
| cpp `pri` | `priority_queue` ✓ |
| cpp `unor` | `unordered_map unordered_set` ✓ |
| cpp `me` | `memset` ✓ |
| cpp `p`（1 字符） | `[]`（未达 keyword_length=2）✓ |
| cpp `INF` / cpp `inf` | `[INF]` / `[]`（大小写敏感，符合设计）|
| py `pop` / `defa` / `df` | `popleft` / `defaultdict` / `dfs` ✓ |
| txt `pri` | `available=false`、`[]`（已按 filetype 门控）✓ |
| cmp 菜单端到端 | 出现 `source=oi_words` 的 `priority_queue` ✓ |
| 菜单标签 | `fmt(oi_words) -> menu=[OI]` ✓ |
| 启动 | 空 42.8 / 43.9 / 55.2 ms，`nvim oi.cpp` 64.0 ms（基线内）✓ |

**加词的代价**：`OI_WORDS` 加一行即可；要扩展语言就改 `OI_FILETYPES` 一行。若将来想要
上千词的大词表，再换回 `cmp-dictionary` + 文件才是对的工具（内存表不适合那个量级）。


### 2.4 自动保存：`InsertLeave`（`lua/options.lua:60-70`）⬜ 待修

每次 Esc 都真写盘 + 写 `undofile`。本地 SSD 上不是延迟问题，而是**行为问题**：文件在
`:1`/`:2` 切到终端跑对拍时永远是"刚被写过"的状态，且和
`lua/options.lua:55-56` 的 `autowrite` / `autowriteall` 与这三条 autocmd 功能重叠。

```lua
-- 去掉 InsertLeave，保留离焦/离 buffer
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, { ... })
```
`autowrite`/`autowriteall` 与这三条 autocmd 二选一即可（建议留 autocmd，语义更明确，
`autowriteall` 会在 `:!make`、`:next` 等一堆命令前隐式写文件）。

### 2.5 Minuet AI 自动触发 ⬜ 待修

`lua/plugins/minuet.lua:55`（`enabled` 在 `:6`）

`virtualtext.auto_trigger_ft = has_deepseek_key and completion_filetypes or {}` —— 只要
`DEEPSEEK_API_KEY` 存在，`c/cpp/python` 全部自动触发。`throttle=1500`/`debounce=600`/
`n_completions = 2` ⇒ 每次停顿最多 2 个 HTTPS 请求。这是有 key 时打字手感抖动的唯一
明显来源，也是断网/比赛环境里的失败点（OI 比赛一般也不允许）。

`OI_AI` 这个开关（`:6`）设计得好，但**默认是开的**。
建议默认关：`enabled = vim.env.OI_ENABLE_AI == "1"`，保留 `<M-a>` 手动请求。

另：`provider_options.openai_fim_compatible.model = "deepseek-v4-flash"`（`:71`）
看起来不是有效的 DeepSeek 模型名，请核对（FIM beta 端点通常不是这个名字）。模型名错误
会让所有请求静默失败，白付一次 round-trip。

### 2.6 cmp `<Tab>` 判定顺序（`lua/plugins/nvim-cmp.lua:74-96`）⬜ 待修

顺序是 `locally_jumpable(1)` → `expand_or_jumpable()` → `cmp.visible()`。
后果：**光标在活跃 snippet 的 tabstop 里、同时补全菜单开着**时，`<Tab>` 永远跳片段节点，
选不到下一个补全项；`expand_or_jumpable()` 排在 `visible()` 前面还会让"在 trigger 上
按 Tab"意外展开片段而不是选菜单项。

对 OI 来说补全优先级更高，建议：

```lua
["<Tab>"] = cmp.mapping(function(fallback)
  if cmp.visible() then
    cmp.select_next_item()
  elseif luasnip.expand_or_locally_jumpable() then
    luasnip.expand_or_jump()
  else
    fallback()
  end
end, { "i", "s" }),
```
`<S-Tab>` 对称改成 `select_prev_item()` 优先。展开动作由 `<C-K>`（1.2 保留）负责。

### 2.7 LuaSnip 在启动期 eager 加载（`lua/plugins/LuaSnip.lua`）✅ 已修

**原状**：spec 没有 `lazy` / `event` / `ft`，所以启动就 require。

**实际改动（✅ 已完成）**

```lua
ft = { "c", "cpp", "python", "markdown", "haskell" },
module = "luasnip",
```

两个点与本文最初的建议不同，都是查证后才发现的：

1. **原来的建议 `ft = { "cpp", "c", "python" }` 不完整。** `vscode-snippets/` 里除了
   `c/`、`cpp/`、`python.json`，还有 `markdown.json` 和 `haskell.json`；只写三个 ft 会
   静默丢掉这两类 snippet（不报错，就是没了）。实测这三种 ft 确实各自有 1 个 snippet。
   另外 `lua/snippets/` 里除了 `cpp.lua` / `python.lua`，还会被 `from_lua.load` 按**文件名**
   额外注册成 `io` / `for` / `stl` / `graph` / `debug` / `algo` / `oth` 这些不存在的 filetype
   （副作用，无害）。真正生效的入口只有 cpp / python。
2. **`module = "luasnip"` 是必需的保险，不是可选项。** `nvim-cmp` 的 config 在 InsertEnter
   会显式 `require("luasnip")`。如果当前 buffer 的 filetype 不在 `ft` 列表里（`.txt` 临时
   buffer、gitcommit、`:enew` 空白 buffer），没有 `module` 时这个 require 会失败，cmp 的
   整个 config 报错 —— 补全在该 buffer 里彻底失效，而不是"没 snippet"而已。lazy.nvim 的
   `ft` 触发器不会拦 `require()`，只有 `module` 会。

**验收结果**

| 检查 | 改动前 | 改动后 |
| --- | --- | --- |
| 空启动（5 次） | 42.8 / 43.9 / 55.2 ms | **23.0 / 23.3 / 23.3 / 23.4 / 24.4 ms** |
| `nvim x.cpp`（3 次） | 64.0 ms | 63.1 / 63.5 / 64.0 ms |
| 启动期 `package.loaded["luasnip"]` | `true` | **`false`** |
| 启动期 `...["luasnip.util.jsregexp"]` | 已加载 | **`false`** |
| snippets：cpp / python / markdown / haskell / text | 86 / 61 / 1 / 1 / 0 | **完全一致** |
| `.txt` buffer 进 InsertEnter 后 | — | luasnip 被 `module` 触发加载，`pcall(require,"cmp")` 正常 |
| cpp buffer 下 `<C-K>/<C-L>/<C-J>/<C-E>` | 均在 | 均在（lua callback）|

**诚实的代价**：这不是"凭空省 20 ms"，而是**把 LuaSnip 的加载从启动期搬到了第一个
cpp/python buffer 的 FileType 事件**。`--startuptime` 里能直接看到 `require('luasnip')`
(2.5 ms) / `from_vscode` (2.2 ms) / `util.parser` (1.8 ms) 这些现在挂在
`FileType Autocommands for "cpp"` 下面。所以“打开第一个 cpp 文件”的总耗时几乎没变
（64.0 → 63.1 ms），真正变快的是**不开 cpp/python 的场景**（dashbaord、临时 buffer、
.md/.txt、git commit）：那才是 20 ms 的真收益。

**顺带查清的一件事**：`<Tab>` 的 `desc` 是 `vim.snippet.jump if active, otherwise <Tab>`，
这**不是**任何插件写的，而是 **Neovim 0.12 自带默认映射**
（`runtime/lua/vim/_core/defaults.lua:248`，内置 snippet 引擎）。与本次改动无关；
cmp 加载后会用自己 i/s 的 `<Tab>` 覆盖它（见 2.6）。

### 2.8 `completeopt` 被设置两次 ⬜ 待修

`lua/options.lua:3` 设 `menu,menuone,noselect`，`nvim-cmp.lua:43` 设
`menu,menuone,noinsert`（`auto_select = true`）。cmp 在 InsertEnter 后注册，会赢，所以现在
没有 bug，但 `init.lua` 的加载顺序（`options` 在 `config.lazy` 之后）让它看起来很脆。
把 `options.lua:3` 改成注释掉或直接写 `menu,menuone,noinsert`，明确"cmp 是唯一真源"。

---

## 3. P2 — 只写这两门语言可以彻底删掉的（全部 ⬜ 待修）

优先级最低（都是 `VeryLazy`/`keys` 加载，不占启动），删它的理由是**减少漂移面**，
不是提速。下表中每一项都还没动。

| 项 | 位置 | 说明 |
| --- | --- | --- |
| marks.nvim | `lua/plugins/marks.lua` | 位置书签，OI 单文件用不上；`opts` 里只有从默认模板拄贝的 `bookmark_0`（`virt_text = "hello world"`），实际上从未被重新配置过 |
| render-markdown.nvim | `lua/plugins/render-markdown.lua` | `enabled = false` + `file_types = { "markdown" }` —— 已完全禁用且与 cpp/python 无关，可直接删依赖 |
| DAP 全套 | `lua/plugins/dap.lua`、`nvim-dap-ui.lua`、`lua/plugins/dap/` | 已在 `c65b475` 整块注释禁用，readme 改推终端 gdb。既然不启用就删文件，别让 `docs/how-to-use-in-python.md` 和 `tests/headless/python_dap.lua` 长期描述一个不存在的功能 |
| 两套模板入口并存 | `lua/plugins/rbook.lua` + `lua/fileSnip.lua` | rbook.nvim 是带 SQLite 索引的本地插件，`<leader>of`/`<leader>oe` 与 `<leader>rf`/`<leader>rc` 功能重叠。留一套。<br>**2026-09 补充**：该插件目前处于**失效状态**，且是两层独立的故障：① `code_yaml_path` 写的是仓库移动前的旧路径（`~/mycode/rbook_nunjucks/...`，已修正为 `~/mycode/教程与书籍/rbook_nunjucks/...`）；② `lyaml` 与 `luarocks` 都未安装（`deps.lua:11` 要求 `luarocks install lyaml`）。选 P2 时请先想清：是花力气装依赖，还是直接删掉这个入口 |
| 多余配色 | `lua/plugins/colortheme.lua:15-23` | tokyonight / kanagawa / kanagawa-paper / moonfly / everviolet **都没安装**（`lazy-lock.json` 里只有 `vim-nightfly-colors` 和 `themify.nvim`），因为它们在 `config` 表里而不是 `dependencies` —— 属失效配置。而 `loader` 的兜底 `vim.cmd.colorscheme("moonfly")`（`:30`）在 moonfly 未安装时会直接报错 —— 潜在 bug |
| 空目录 | `after/ftplugin/`、`plugin/`、`tmp/` | 直接 `git rm -r --cached` + 删 |
| `checker` 反复包裹 | `lua/config/lazy.lua:28` | 已 `checker = { enabled = false }`，lazy 自身有 `:CheckHealth`，不需要额外包一层 |
| 重复的 buffer 导航键 | `lua/plugins/buffline.lua:43-46` | `<S-h>`/`<S-l>` 与 `[b`/`]b` 指向同一个 `BufferLineCyclePrev/Next`（cheatsheet 里四条都列了）。留一组就够 |
| `oiSnippets/clangd_config` | `oiSnippets/clangd_config:4` | 里面 `Add: [-std=c++17, -DDEBUG]` 与 `lua/lsp/clangd.lua` 的 `fallbackFlags = { '--std=c++17' }` 重复；而且首行写着 "rename file to .clangd" —— **它当前是个从未生效的模板**，不要误以为已经关掉了索引/诊断。真要用就拷到项目根目录改名 `.clangd`，并把 `-std` 交给 `fallbackFlags` 单边管理 |

---

## 4. 做得对、明确不要动的地方

- `lua/lsp.lua` 用 `vim.lsp.config` + `vim.lsp.enable`，不依赖 `nvim-lspconfig` 插件
  （readme 里还写着 `nvim-lspconfig`，属文档漂移）。少一个必装插件 = 少一层启动开销。
- `lua/plugins/treesitter.lua`：只 `setup({ install_dir = ... })`，不用 main-module 的
  `highlight`/`indent` 表，而是 FileType autocmd + `pcall(vim.treesitter.start, ...)`
  （`:13-21`，pattern 正好是 c/cpp/markdown/python）。0.12 main 分支上这是更省、更可预测
  的写法，`lazy = false` + `build = ":TSUpdate"` 也合理。
- `lua/lsp/basedpyright.lua:13-27`：`diagnosticMode = "openFilesOnly"`（不扫全项目）、
  `typeCheckingMode = "basic"`（不 strict）、unknown*/unused* 一类噪音统一关成 `none`。
  OI Python 的正确取舍。
- `lua/keymaps.lua:46-47` 用 select 模式的 `<C-n>`/`<C-p>` 处理 snippet choice，避开与 cmp
  的 insert 模式 `<C-n>`/`<C-p>`（`nvim-cmp.lua:49-50`）抢键 —— 这是上一次 commit
  （"stop hijacking `<C-n>`/`<C-p>`"）的正确做法，保留。
- 没有 format-on-save、没有 gitsigns、没有 telescope+plenary（用 snacks picker）。
  这是暖启动能压在 45 ms 的直接原因。
- 语言设置隔离成 `lua/local/cpp-settings` + `lua/local/python-settings` 两个本地插件，靠
  `ft` 触发，不互相污染 buffer。结构是对的（只需按 1.1 改法 B 修绑定方式）。
- `lua/config/lazy.lua:28` `checker = { enabled = false }` + lockfile：比赛机器上不会被
  突然的插件更新背刺。
- `lua/fileSnip.lua:36-46` 对 `simaple_template.cpp` 的日期占位替换 + 光标定位 + `zM`
  折叠，是对 OI 模板工作流的有效优化，保留。

### 4.1 一处需要补的健壮性缺口（顺手）⬜ 待修

`lua/lsp.lua:3` 无条件 `vim.lsp.enable("clangd")`，而 basedpyright 有
`if vim.fn.executable("basedpyright-langserver") == 1` 保护（`:7`）。换到没装 clangd 的机器上，
clangd 会直接报启动失败而不是给出安装提示。把 clangd 也包成同样的 executable 检查 +
缺依赖 warn，两条语言的失败模式就一致了。

---

## 5. 执行顺序建议

1. ~~**P0**：1.1（buffer 键失效）、1.2（`<C-l>` 冲突）、1.3（删 lazydev 行）~~ —— **已完成
   （1.2 决定不修）**。验收结果：
   - `maparg` 在 buffer1/buffer2 两个 cpp buffer 上 `<leader>os`/`oe`/`of` = global、
     `<leader>;` = local 且存在；`:OISnipChoose`/`:RbookCode`/`:RbookCodeFiles` 均为全局命令。
   - cmp 实际加载的 sources = `buffer, dictionary, luasnip, minuet, path, nvim_lsp`，
     `lazydev present = false`。（**注**：2.3 修复后 `dictionary` 已不在其中，见 §2.3）
   - 启动：空 45.7 / 47.5 / 53.2 ms，`nvim a.cpp` 72.3 ms（与 §0 基线同一量级）。
2. **P1**：~~2.3~~✅（已改为内存 OI 词表源）、2.1 clangd cmd、2.2 clangd filetypes、
   2.4 去 InsertLeave，其余见 §2。
3. 每步后跑一次 §0 的 `--startuptime` 和 §1.1 的 `maparg` 验收；再开一个 `.cpp` 敲
   `:CmpStatus`，确认 unknown source 里没有 `lazydev`，且 `nvim_lsp` 出现在 ready 里。
4. **P2** 单独一个 commit，方便回退。

**不要期望这些改动能让启动更快**（收益 < 10 ms）。P0/P1 的价值在于：模板键在所有 buffer
可用、片段能正向跳、clangd 不在题库大仓库里烧 CPU、补全菜单不被 snippet 抢走。

---

## 6. 审计过程中被撤回的说法（记录以免照抄错）

- ~~"英文单词补全写 C++ 时是纯噪音，可以直接删"~~ —— **判断错误**，已按方案 A 重做（§2.3）。
  错在两步：①把"词表选得不对"误判成"这个功能没用"；②没问用户实际用法就动手删。
  正确的事实链是：那份词表是**原版** google-10000（commit message 里的 "custom word list"
  是假的），它给不了任何带下划线/缩写/大写的 OI token，但用户确实在用"打两字母弹候选"
  这个交互 —— 所以解法是**换词表**（且按用户要求放内存），不是删功能。

- ~~`lua/lsp/clangd.lua` 里有 `--enable-autocomplete`，会导致 clangd 启动失败~~ ——
  **不成立**。该文件实际 cmd 只有 6 项，没有这个参数（见 2.1 的"当前"引用块）。
- ~~`init.lua:19` 有 `pcall(require, 'checker')`~~ —— **不存在**。`init.lua` 只有 9 行，
  没有任何 pcall；现在只保留"`checker.enabled = false` 已足够"这一条事实。
- ~~`keymaps.lua:39-40` 重复了 bufferline 自带的 `<S-h>`/`<S-l>`~~ —— **不成立**。
  这两行在 `lua/plugins/buffline.lua:43-46`，而且与 `[b`/`]b` 是同一命令的**双绑定**
  （见 §3 的 buffer 导航键一行），不是"与插件默认键重复"。
- ~~配置里还有 hlslens / habamax / material 主题~~ —— **不存在**，`grep` 无匹配。真实的
  多余项是 `colortheme.lua:15-23` 里那几个**没进 `dependencies`、因此根本没装**的主题
  （见 §3）。
- ~~`oiSnippets/clangd_config` 里写着 `Index: Background: Skip`，说明已经考虑过索引问题~~
  —— **不存在**。`grep -rn "Background: Skip\|Index:"` 全仓只命中本文件。该配置实际只有
  `CompileFlags.Add` 和 `Diagnostics.UnusedIncludes`，且文件名意味着它未生效（见 §3）。
- ~~`lua/lsp/basedpyright.lua` 里有 `enable = false`~~ —— **不存在**。真实的降噪手段是
  `diagnosticMode = "openFilesOnly"` + `typeCheckingMode = "basic"` + 一堆
  `report* = "none"`（见 §4）。
- ~~`clangd` 的 `cmd` 在 `lua/lsp.lua` 里被二次覆盖~~ —— 不存在，`lua/lsp.lua` 只做
  `vim.lsp.config['clangd'] = require('lsp.clangd')` + `enable`。
- ~~实测 clangd 在无 `compile_commands.json` 时 0% CPU、不生成索引分片~~ ——
  **不足以作为依据**。`ps` 的 `pcpu` 是进程启动以来的平均值，200 个微型文件的索引可能在
  第一次采样（6 s）前就跑完了；同时全盘找不到 `.idx` 分片，两种解释（没索引 / 索引早已完成
  并清理）都与该测量兼容。所以 2.1 的结论只按配置语义推导，不依赖那次测量。
