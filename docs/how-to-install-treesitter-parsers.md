# 安装 Treesitter parser

本配置依赖若干 Treesitter parser。Neovim 只自带一部分，其余必须手动安装。
**漏装的后果是静默的**，所以这份文档单独说明。

## Neovim 自带哪些

Neovim 0.12.5 自带 7 个：

```
c  lua  markdown  markdown_inline  query  vim  vimdoc
```

注意**没有 `cpp`、没有 `python`** —— 而这两个正是本配置最常用的语言。

## 本配置需要哪些

`lua/plugins/treesitter.lua:14` 为这些 filetype 启动 Treesitter：

```lua
pattern = { "c", "cpp", "markdown", "python" },
```

| parser | 用途 | 是否自带 |
| --- | --- | --- |
| `c` | C 高亮 | ✅ 自带 |
| `cpp` | C++ 高亮；`Comment.nvim` 在 .cpp 里算注释符 | ❌ 需安装 |
| `markdown` | Markdown 渲染 | ✅ 自带 |
| `markdown_inline` | 行内 Markdown（`render-markdown` 依赖） | ✅ 自带 |
| `python` | Python 高亮；`Comment.nvim` 在 .py 里算注释符 | ❌ 需安装 |
| `latex` | `render-markdown` 的公式渲染，见 [公式渲染指南](how-to-render-math.md) | ❌ 需安装 |

安装目录在 `lua/plugins/treesitter.lua:10` 指定，即
`~/.local/share/rainboy-nvim-for-oi/site/`。Neovim 会自动把这个目录加进
runtimepath，不需要额外配置。

## 安装

```vim
:TSInstall cpp python latex
```

`:TSInstall` 是**异步**的。命令返回后安装仍在后台进行，必须等它打印出
`Language installed` 才算完成。在 headless 脚本里尤其要注意 —— 紧接着
`qa!` 会把异步任务杀掉，表现为"命令不报错但什么都没装"。

等它输出类似：

```
[nvim-treesitter/install/cpp]: Downloading tree-sitter-cpp...
[nvim-treesitter/install/cpp]: Compiling parser
[nvim-treesitter/install/cpp]: Installing parser
[nvim-treesitter/install/cpp]: Language installed
```

也可以用 Lua API（同样异步，需要用 `:wait()` 或等待）：

```vim
:lua require("nvim-treesitter.install").install({ "cpp", "python", "latex" }, { summary = true })
```

`cpp` 依赖 `c`，安装时会连带处理 `c`。`latex` 需要现场生成 `parser.c`
（上游仓库不含预生成文件），安装日志里会出现
`Generating parser.c from grammar.json...`，这是正常的，多花几十秒。

## 验证

确认 parser 文件确实落地：

```sh
ls ~/.local/share/rainboy-nvim-for-oi/site/parser/
```

应看到 `cpp.so`、`c.so`、`python.so`、`latex.so`。

确认 Neovim 能加载：

```vim
:lua print(vim.inspect(vim.treesitter.language.inspect("python")))
```

或在打开 `.cpp` / `.py` 后确认高亮真的生效：

```vim
:lua print(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil)
```

输出 `true` 才算成功。

## 为什么漏装很难发现

本配置用 `pcall` 启动 Treesitter：

```lua
-- lua/plugins/treesitter.lua
pcall(vim.treesitter.start, args.buf, lang)
```

parser 缺失时 `vim.treesitter.start` 失败，但被 `pcall` 吃掉 —— **不报错、
不提示**，只是高亮悄悄没了。所以 `cpp` / `python` 的 parser 长时间没装，
表面上完全看不出来。

真正暴露问题的是 `Comment.nvim`。它在 `ft.lua` 里这样取 parser：

```lua
local ok, parser = pcall(vim.treesitter.get_parser, buf)
if not ok then
    return ft.get(vim.bo.filetype, ctx.ctype)   -- 只处理「抛异常」的情况
end
local lang = ft.contains(parser, {...}):lang()  -- parser 为 nil 时在这里崩
```

Neovim 0.12 在 parser 缺失时**返回 `nil` 而不抛异常**，`pcall` 判定为成功，
于是 `nil` 被传进 `ft.contains`，报出这个和注释毫无关系的错：

```
Comment.nvim/lua/Comment/ft.lua:280: attempt to index local 'tree' (a nil value)
```

所以：**在 `.py` 或 `.cpp` 里 `gcc` 报 `nil` 错误，先检查 parser 是否装了。**

## 新增语言时

如果给 `lua/plugins/treesitter.lua:14` 的 `pattern` 加了新的 filetype，
记得同时安装对应的 parser，否则同样会静默失败。Neovim 自带的那 7 个之外
的语言都需要单独装。
