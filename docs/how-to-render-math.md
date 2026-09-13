# 在 Markdown 里渲染公式

`render-markdown.nvim` 能把 Markdown 里的 `$...$` 和 `$$...$$` 画成 Unicode
文本，直接显示在 buffer 里（`<Leader>mm` 可整体开关）。

## 这不是 KaTeX

先明确边界，避免期望错位：

- **不是 KaTeX**。KaTeX 是 JS 库，在 buffer 里跑不了。
- **也不是 LaTeX 排版**。它不生成 PDF 或图片，不调用 `pdflatex`。
- 它是**字符替换**：调用一个外部命令，把公式源码经 stdin 传进去，再把
  stdout 当作文本行显示（`render-markdown/handler/latex.lua` 的
  `Handler.convert`）。所以分式会变成 `a/b` 或堆叠的 `─`，不会变成真正
  排版的分数。

需要真排版或真 KaTeX 时，走图片或浏览器路线（见文末）。

## 依赖

三样东西，缺一不可：

| 依赖 | 作用 | 现状 |
| --- | --- | --- |
| `markdown` / `markdown_inline` parser | 解析 Markdown 语法树 | Neovim 自带，无需安装 |
| `latex` parser | 让 `latex_block` 注入成 `latex` 语言树 | 需手动安装 |
| `utftex` 或 `latex2text` | 把 LaTeX 转成 Unicode 文本 | 需手动安装 |

`render-markdown` 在 `latex.converter` 里按顺序找转换器，取**第一个存在**的。
两个都没装时，整个 latex 模块静默跳过 —— 不报错，只在 debug 日志里记一条
`ConverterNotFound`。这就是"配置里 enabled = true 却什么都不显示"的原因。

## 安装 latex parser

Neovim 自带 `markdown` 和 `markdown_inline`，但**不带** `latex`。而这个模块
依赖 Neovim 自带的注入查询：

```scheme
; /usr/share/nvim/runtime/queries/markdown_inline/injections.scm
((latex_block) @injection.content
  (#set! injection.language "latex"))
```

`tree-sitter-latex` 仓库没有预生成的 `parser.c`，所以 `:TSInstall latex` 需要
`tree-sitter` CLI 现场生成。直接手工构建更可靠：

```sh
cd /tmp
git clone --depth 1 https://github.com/latex-lsp/tree-sitter-latex
cd tree-sitter-latex
tree-sitter generate
tree-sitter build -o latex.so .

# install_dir 来自 lua/plugins/treesitter.lua：stdpath("data") .. "/site"
cp latex.so ~/.local/share/rainboy-nvim-for-oi/site/parser/latex.so
```

Neovim 会把 `stdpath("data")/site` 自动加进 runtimepath，不需要改配置。

验证：

```vim
:lua print(vim.inspect(vim.api.nvim_get_runtime_file("parser/latex.so", true)))
:lua print(vim.treesitter.language.add("latex"))
```

## 安装转换器

两个都不在 Arch 官方仓库（`pacman -Ss utftex` 无结果），也都没有 AUR 的必要
（`libtexprintf` 有 AUR 包，但 `yay -S` 需要 sudo 密码，这里走免 sudo 路线）。

### utftex（推荐）

来自 [libtexprintf](https://github.com/bartp5/libtexprintf)，能把分式、积分、
求和等叠成多行，效果最好：

```sh
cd ~/.cache
git clone --depth 1 https://github.com/bartp5/libtexprintf
cd libtexprintf
sh autogen.sh
./configure --prefix="$HOME/.local"
make -j"$(nproc)"
make install
```

依赖：`gcc`、`make`、`autoconf`、`automake`、`libtool`。装完在
`~/.local/bin/utftex`，该目录默认已在 `PATH` 里。

### latex2text（兜底）

来自 `pylatexenc`，输出单行近似。用 venv 装，不污染系统 Python（Arch 的
Python 是 externally-managed，直接 pip 会被拒绝）：

```sh
python3 -m venv ~/.local/share/latex2text-venv
~/.local/share/latex2text-venv/bin/pip install pylatexenc
ln -sfn ~/.local/share/latex2text-venv/bin/latex2text ~/.local/bin/latex2text
```

## 效果对比

同一批公式，两个转换器的实际输出（`printf '%s' "$f" | utftex`）：

| 输入 | utftex | latex2text |
| --- | --- | --- |
| `x^2+\alpha` | `x²+α` | `x^2+α` |
| `\frac{a}{b}` | `a` / `─` / `b`（三行堆叠） | `a/b` |
| `\sum_{i=0}^{n} i` | 求和号带上下限，多行 | `∑_i=0^n i` |
| `\int_0^\infty e^{-x^2}\,dx` | 积分号带上下限，多行 | `∫_0^∞e^-x^2 dx` |

`utftex` 明显更像数学，这也是它排在 converter 列表第一位的原因。

## 验证

```vim
:checkhealth render-markdown
```

health 检查会报 `converter` 是否找到。或在 Shell 里单独确认 stdin 契约：

```sh
printf '%s' '\frac{a}{b}' | utftex
```

注意 render-markdown 在**无 UI 的 headless 会话里不渲染**（连标题也不渲染），
所以不要用 `nvim --headless` 验证这个功能，要在真实的 kitty 窗口里看。

## 输入写法

- 行内：`$x^2+\alpha$`
- 块级：`$$` 独占一行包裹公式

普通 Markdown 预览器常用的 `\(...\)` 在这里不生效。

## 想要真排版怎么办

本方案给不了的，换路线：

| 需求 | 方案 |
| --- | --- |
| buffer 内真 LaTeX 排版图片 | `snacks.nvim` 的 `image` 模块（渲染 ` ```math ` 代码块，走 `pdflatex` + `magick` + Kitty 图形协议；需装 `texlive-latexextra` 补 `standalone.cls`） |
| buffer 内行内公式图片 | `techwizrd/render-latex.nvim`（声称兼容 `render-markdown`）、`Thiago4532/mdmath.nvim` |
| 字面意义的 KaTeX | `markdown-preview.nvim` 等浏览器预览，渲染在浏览器窗口而非 buffer |
