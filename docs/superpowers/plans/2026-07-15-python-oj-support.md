# Python OJ 支持实施计划

> 设计依据：`docs/superpowers/specs/2026-07-15-python-oj-support-design.md`

## 目标

在不改变现有 C++ OJ 工作流的前提下，为当前 Arch Linux 环境加入 Python 的 BasedPyright LSP、Treesitter、Pythonic LuaSnip、完整 OJ 模板和 debugpy 调试，并补齐可长期查阅的 `docs/how-to-use-in-python.md`。

## 实施原则

- 沿用 Neovim 0.12 原生 `vim.lsp.config` / `vim.lsp.enable`。
- 沿用现有 lazy.nvim、nvim-cmp、LuaSnip 和 nvim-dap，不引入 Mason 或 Python 专用封装插件。
- 每个阶段先增加一个会失败的可重复检查，再写最小配置使其通过。
- 每个阶段单独提交，便于定位回归。
- 所有 headless 命令显式设置 `NVIM_APPNAME=rainboy-nvim-for-oi`。
- 外部工具缺失不能阻止普通 Python buffer 编辑。

## 当前基线

开始实现前必须确认工作区只包含预期改动：

```bash
git status --short
```

当前已验证的回归基线：

```text
vim.lsp.config.clangd 存在
C++ LuaSnip 数量为 37
C++ DAP configuration 数量为 1
```

基线检查命令：

```bash
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless \
  '+lua assert(vim.lsp.config.clangd)' \
  '+lua assert(#require("luasnip").get_snippets("cpp") == 37)' \
  '+lua assert(#(require("dap").configurations.cpp or {}) == 1)' \
  '+qa'
```

## Task 1：准备外部依赖

**仓库文件：** 无。

### Step 1：记录安装前状态

```bash
command -v python3
command -v basedpyright-langserver || true
python3 -c 'import debugpy' || true
```

预期：`python3` 已存在；当前机器上的 BasedPyright 和 debugpy 可能缺失。

### Step 2：安装 BasedPyright

```bash
uv tool install basedpyright
uv tool update-shell
```

如果 `uv tool install` 提示已经安装，保持现有版本即可。`uv tool update-shell` 修改 PATH 后，需要新开 shell 或手工加载 shell 配置。

### Step 3：安装 debugpy

```bash
sudo pacman -S --needed python-debugpy
```

### Step 4：验证外部依赖

```bash
basedpyright --version
command -v basedpyright-langserver
python3 -c 'import debugpy; print(debugpy.__version__)'
```

预期：两个命令退出码均为 0。

### Step 5：安装 Python Treesitter parser

在 Neovim 中执行：

```vim
:TSInstall python
```

然后退出并重新进入 Neovim。该步骤不产生 Git 提交。

## Task 2：建立 headless 检查并加入 BasedPyright

**文件：**

- Create: `tests/headless/python_support.lua`
- Create: `tests/headless/python_lsp.lua`
- Create: `lua/lsp/basedpyright.lua`
- Modify: `lua/lsp.lua`

### Step 1：写结构检查的失败断言

创建 `tests/headless/python_support.lua`，先只检查：

- `vim.lsp.config.basedpyright` 已注册。
- 配置的 `cmd[1]` 是 `basedpyright-langserver`。
- `filetypes` 只包含 `python`。
- `settings.basedpyright.analysis.diagnosticMode` 是 `openFilesOnly`。
- `typeCheckingMode` 是 `basic`。
- 设计规格中的九个低价值诊断全部设为 `none`。
- clangd 配置仍存在。

测试脚本用 `xpcall` 包住断言；失败时执行 `vim.cmd("cquit 1")`，成功时打印 `python_support: ok`，保证 shell 能得到可靠退出码。

### Step 2：运行结构检查并确认失败

```bash
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless \
  '+lua dofile("tests/headless/python_support.lua")' \
  '+qa'
```

预期：因为 BasedPyright 尚未注册而退出非 0。

### Step 3：实现 BasedPyright 配置

在 `lua/lsp/basedpyright.lua` 返回独立配置表：

- `cmd = { "basedpyright-langserver", "--stdio" }`
- `filetypes = { "python" }`
- `root_markers` 依次包含 `pyproject.toml`、`basedpyrightconfig.json`、`pyrightconfig.json`、`.git`
- `settings.basedpyright.analysis.diagnosticMode = "openFilesOnly"`
- `settings.basedpyright.analysis.typeCheckingMode = "basic"`
- `diagnosticSeverityOverrides` 精确包含设计中的九个 `none`

不要在该文件中写 DAP、formatting 或虚拟环境逻辑。

### Step 4：注册、启用并处理依赖缺失

修改 `lua/lsp.lua`：

1. 保留现有 clangd 注册和启用逻辑。
2. 注册 `vim.lsp.config.basedpyright`。
3. 当 `vim.fn.executable("basedpyright-langserver") == 1` 时启用 BasedPyright。
4. 工具缺失时，为 `python` FileType 注册一次性提示；提示包含 `uv tool install basedpyright` 和 `docs/how-to-use-in-python.md`。
5. 缺失工具时不调用 Python LSP，不影响 buffer 加载。

### Step 5：运行结构检查

```bash
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless \
  '+lua dofile("tests/headless/python_support.lua")' \
  '+qa'
```

预期：输出 `python_support: ok`，退出码为 0。

### Step 6：写 LSP 集成检查

创建 `tests/headless/python_lsp.lua`：

1. 等待当前 buffer 附加名为 `basedpyright` 的客户端，最长 10 秒。
2. 等待诊断到达，最长 10 秒。
3. 断言存在包含 `not_defined` 和 `not defined` 的诊断。
4. 断言不存在未使用 `os` import 的诊断。
5. 超时或断言失败时 `cquit 1`。

### Step 7：运行真实 LSP 检查

```bash
fixture="$(mktemp --tmpdir="$PWD" .python-lsp-XXXXXX.py)"
printf 'import os\nprint(not_defined)\n' > "$fixture"
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless "$fixture" \
  '+lua dofile("tests/headless/python_lsp.lua")' \
  '+qa'
status=$?
rm -f "$fixture"
exit "$status"
```

预期：BasedPyright 报未定义变量，不报告未使用 import，命令退出 0。

### Step 8：提交

```bash
git add tests/headless/python_support.lua tests/headless/python_lsp.lua \
  lua/lsp/basedpyright.lua lua/lsp.lua
git commit -m "feat: add Python LSP support"
```

## Task 3：加入 Python buffer 设置与安全 Treesitter 启动

**文件：**

- Create: `lua/plugins/lang-python.lua`
- Create: `lua/local/python-settings/lua/python-settings.lua`
- Modify: `lua/plugins/treesitter.lua`
- Modify: `tests/headless/python_support.lua`

### Step 1：扩展失败检查

在 `tests/headless/python_support.lua` 中创建一个临时 `.py` buffer，触发 `python` FileType 后断言：

- `tabstop`、`softtabstop`、`shiftwidth` 都是 4。
- `expandtab` 为 true。
- `commentstring` 为 `# %s`。
- 当前 window 的 `foldmarker` 为 `#oisnip_begin,#oisnip_end`。
- FileType 处理完成后没有 Lua 错误。

先运行检查，预期 fold marker 仍是 C++ 的 `//` 形式，因此失败。

### Step 2：实现 Python 局部模块

在 `lua/local/python-settings/lua/python-settings.lua` 提供 `setup()`：

- 使用 buffer-local 选项设置 4 空格、`expandtab` 和 `commentstring = "# %s"`。
- 使用 `vim.opt_local.foldmarker` 设置当前 window 的 Python marker fold。
- 不设置 Python 专用快捷键。
- 不执行自动折叠。

### Step 3：声明 lazy.nvim 本地插件

在 `lua/plugins/lang-python.lua` 中：

- `dir` 指向 `lua/local/python-settings`。
- `ft = { "python" }`。
- `config` 中调用 `require("python-settings").setup()`。
- 不增加不需要的依赖。

### Step 4：扩展 Treesitter filetype

修改 `lua/plugins/treesitter.lua`：

- 保留 `c`、`cpp`、`markdown`。
- 加入 `python`。
- 使用 `pcall(vim.treesitter.start, args.buf, lang)` 启动 parser。
- parser 缺失时直接返回，不产生阻断性错误。

### Step 5：运行检查

```bash
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless \
  '+lua dofile("tests/headless/python_support.lua")' \
  '+qa'
```

再验证 C++ buffer 没有继承 Python fold marker：

```bash
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless sample.cpp \
  '+lua assert(vim.bo.filetype == "cpp")' \
  '+lua assert(vim.wo.foldmarker == "//oisnip_begin,//oisnip_end")' \
  '+qa'
```

不要保留 `sample.cpp`；如果命令创建了空文件，测试后删除。

### Step 6：提交

```bash
git add lua/plugins/lang-python.lua \
  lua/local/python-settings/lua/python-settings.lua \
  lua/plugins/treesitter.lua tests/headless/python_support.lua
git commit -m "feat: add Python buffer settings"
```

## Task 4：加入 Pythonic OJ snippets

**文件：**

- Create: `lua/snippets/python.lua`
- Modify: `tests/headless/python_support.lua`

### Step 1：加入 trigger 集合的失败检查

扩展 `tests/headless/python_support.lua`：

- `require("luasnip").get_snippets("python")` 数量必须是 17。
- 收集每个 snippet 的 trigger，断言包含：
  `main`、`solve`、`fastin`、`ii`、`ints`、`listi`、`strin`、`f`、
  `fr`、`fri`、`rf`、`enum`、`tests`、`heap`、`bisect`、`deque`、`dbg`。
- 再次断言 C++ snippet 数量仍为 37。

运行检查，预期 Python snippet 数量为 0，测试失败。

### Step 2：实现骨架与输入 snippets

在 `lua/snippets/python.lua` 中先实现：

- `main`：`import sys`、buffer input、`solve()` 和 main guard。
- `solve`：函数骨架，光标落在函数体。
- `fastin`：导入 `sys` 并绑定 input。
- `ii`：`int(input())`。
- `ints`：可填写左侧变量名，右侧为 `map(int, input().split())`。
- `listi`：可填写变量名，右侧为整数列表读取。
- `strin`：可填写变量名，使用 `input().strip().decode()`。

所有多行 snippet 使用 `fmt`；可编辑字段使用 insert node，不把用户变量写死。

### Step 3：实现循环 snippets

实现：

- `f`：变量和上界可编辑，默认 `i` / `n`，展开为 `range(n)`。
- `fr`：变量、左边界、右边界可编辑，保持 Python 半开区间语义。
- `fri`：和 `fr` 相同，但右边界生成 `right + 1`。
- `rf`：生成 `range(n - 1, -1, -1)`。
- `enum`：索引、元素名和容器名可编辑。
- `tests`：生成 `for _ in range(int(input())):` 并调用 `solve()`。

同一变量重复出现时使用 mirror node，避免展开后手工改多个位置。

### Step 4：实现标准库与调试 snippets

实现：

- `heap`：`import heapq` 和一个可命名空列表。
- `bisect`：导入 `bisect_left`、`bisect_right`。
- `deque`：导入 `deque` 并初始化可命名队列。
- `dbg`：`print(..., file=sys.stderr)`，表达式位置可编辑。

这些 snippets 只生成标准库代码，不加入第三方依赖。

### Step 5：运行检查

```bash
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless \
  '+lua dofile("tests/headless/python_support.lua")' \
  '+qa'
```

在交互 Neovim 中打开临时 `.py` 文件，至少手工展开 `main`、`ints`、`fri` 和 `enum`，确认 `<C-L>` / `<C-J>` 跳转与 mirror node 同步正常。

### Step 6：提交

```bash
git add lua/snippets/python.lua tests/headless/python_support.lua
git commit -m "feat: add Python OJ snippets"
```

## Task 5：加入完整 Python OJ 模板

**文件：**

- Create: `oiSnippets/template/simple_template.py`

### Step 1：写模板

模板固定为：

```python
import sys

input = sys.stdin.buffer.readline


def solve():
    pass


if __name__ == "__main__":
    solve()
```

不要加入多测、类型标注、第三方包或提交平台判断。

### Step 2：验证语法

```bash
cache_dir="$(mktemp -d)"
PYTHONPYCACHEPREFIX="$cache_dir" python3 -m py_compile \
  oiSnippets/template/simple_template.py
status=$?
rm -rf "$cache_dir"
exit "$status"
```

预期：退出码为 0，仓库中不产生 `__pycache__`。

### Step 3：验证选择器可见

打开任意 Python buffer，执行 `<Leader>os` 或 `:OISnipChoose`，搜索 `simple_template.py`，确认选择器能找到并插入模板，且不加入 C++ 的 `//oisnip` marker。

### Step 4：提交

```bash
git add oiSnippets/template/simple_template.py
git commit -m "feat: add Python OJ template"
```

## Task 6：加入 Python debugpy DAP

**文件：**

- Create: `lua/plugins/dap/python.lua`
- Modify: `lua/plugins/dap/linux.lua`
- Modify: `tests/headless/python_support.lua`

### Step 1：加入 DAP 注册失败检查

扩展 `tests/headless/python_support.lua`：

- `require("dap").adapters.python` 存在且为函数。
- `dap.configurations.python` 恰好有一个配置。
- 配置名为 `Launch current Python file`。
- `type = "python"`、`request = "launch"`。
- `console = "integratedTerminal"`、`justMyCode = true`。
- C++ configuration 数量仍为 1。

运行检查，预期 Python adapter 尚未注册而失败。

### Step 2：实现 adapter 前置检查

在 `lua/plugins/dap/python.lua` 暴露 `setup(dap)`：

1. 注册函数形式的 `dap.adapters.python`。
2. 启动前检查 `python3` 是否可执行。
3. 用同一个 `python3` 执行 `-c "import debugpy"`。
4. 检查成功后回调 executable adapter：command 为 `python3`，args 为 `{ "-m", "debugpy.adapter" }`。
5. 检查失败时不回调 adapter，使用 `vim.notify` 显示安装命令和 `docs/how-to-use-in-python.md`。

debugpy 检查只在启动 Python 调试时发生，不能阻塞普通 Neovim 启动。

### Step 3：实现 launch configuration

注册唯一 Python configuration：

- 当前文件绝对路径为空时提示先保存，并取消启动。
- `cwd` 返回 `vim.fn.getcwd()`。
- `console = "integratedTerminal"`。
- `justMyCode = true`。
- 不添加文件输入重定向；标准输入由集成终端交互提供。

### Step 4：接入 Linux DAP 配置

在 `lua/plugins/dap/linux.lua` 的现有 `config` 中，在 C++ adapter/configuration 设置完成后调用：

```lua
require("plugins.dap.python").setup(dap)
```

不要改动现有 cppdbg 路径、C++ configuration 或共享 DAP 快捷键。

### Step 5：运行结构和回归检查

```bash
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless \
  '+lua dofile("tests/headless/python_support.lua")' \
  '+qa'
```

### Step 6：手工验证真实 DAP 会话

创建不提交的临时程序：

```python
value = int(input())
answer = value * 2
print(answer)
```

验证顺序：

1. 在 `answer` 行按 `<F6>` 设置断点。
2. 按 `<F5>` 启动。
3. 在集成终端输入 `21`。
4. 确认停在断点并能看到 `value == 21`。
5. 按 `<F8>` step over，确认 `answer == 42`。
6. 按 `<F4>` 结束。

### Step 7：验证缺失依赖提示

使用一个不能 import debugpy 的临时 Python 解释器路径或临时调整 PATH，触发 adapter 前置检查。确认提示包含 `sudo pacman -S python-debugpy`，并且没有创建半初始化 DAP session。测试后恢复环境。

### Step 8：提交

```bash
git add lua/plugins/dap/python.lua lua/plugins/dap/linux.lua \
  tests/headless/python_support.lua
git commit -m "feat: add Python debug support"
```

## Task 7：编写长期使用文档和速查表

**文件：**

- Create: `docs/how-to-use-in-python.md`
- Modify: `readme.md`
- Modify: `cheatsheet.md`

### Step 1：编写 Python 总入口文档

`docs/how-to-use-in-python.md` 按以下固定结构编写：

1. `功能边界`：列出支持与不支持内容。
2. `配置文件地图`：逐项解释 LSP、buffer 设置、Treesitter、LuaSnip、模板和 DAP 文件。
3. `首次安装`：BasedPyright、debugpy、Treesitter parser 命令及验证命令。
4. `开始写题`：创建 `.py`、确认 filetype、确认 LSP、插入模板。
5. `Python snippets`：17 个 trigger 的完整表格及 `<C-K>`、`<C-L>`、`<C-J>`、`<C-E>`。
6. `调试`：断点、启动、继续、step into/over、run to cursor、变量查看、结束。
7. `标准输入`：说明 DAP 集成终端交互输入，以及普通终端 `python3 sol.py < in`。
8. `故障排查`：按 LSP、Treesitter、snippet、debugpy 四类给出命令。
9. `仍在终端完成的工作`：运行、样例评测、输出比较和对拍。

文档内容必须描述最终配置，不写设计历史或备选方案。

### Step 2：更新 README

在 `readme.md` 中：

- 将项目描述从“只为 C++”调整为“面向 C++ 与 Python OJ”。
- 特性列表加入 Python BasedPyright、Python snippets 和 debugpy。
- 依赖区加入 Arch Linux 安装命令。
- 加入 `docs/how-to-use-in-python.md` 的相对链接。
- 保留现有 C++ 安装与使用内容，不复制 Python 文档全文。

### Step 3：更新 cheat sheet

在 `cheatsheet.md` 中新增：

- `Python Buffer` 小节：注释、LSP symbols 和 DAP 共用键。
- `Python Snippets` 小节：17 个 trigger 及简短展开结果。
- `Python 调试` 小节：最常用的 `<F4>` 到 `<F9>`。

不要把依赖安装和故障排查塞进 cheat sheet。

### Step 4：做文档一致性检查

```bash
test -f docs/how-to-use-in-python.md
for trigger in main solve fastin ii ints listi strin f fr fri rf enum tests heap bisect deque dbg; do
  rg -q "\`$trigger\`" docs/how-to-use-in-python.md
  rg -q "\`$trigger\`" cheatsheet.md
done
rg -n 'basedpyright|debugpy|TSInstall python|simple_template.py' \
  docs/how-to-use-in-python.md readme.md cheatsheet.md
```

预期：所有命令退出 0，路径、命令和 trigger 与配置一致。

### Step 5：提交

```bash
git add docs/how-to-use-in-python.md readme.md cheatsheet.md
git commit -m "docs: document Python OJ workflow"
```

## Task 8：执行完整验收

**文件：** 不新增功能文件；只修复验收发现的本次变更问题。

### Step 1：检查格式和工作区

```bash
git diff --check HEAD~6..HEAD
git status --short
```

预期：没有空白错误；工作区干净。

### Step 2：运行 headless 总检查

```bash
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless \
  '+lua dofile("tests/headless/python_support.lua")' \
  '+qa'
```

预期：输出 `python_support: ok`。

### Step 3：重新运行真实 LSP 检查

```bash
fixture="$(mktemp --tmpdir="$PWD" .python-lsp-XXXXXX.py)"
printf 'import os\nprint(not_defined)\n' > "$fixture"
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless "$fixture" \
  '+lua dofile("tests/headless/python_lsp.lua")' \
  '+qa'
status=$?
rm -f "$fixture"
exit "$status"
```

### Step 4：重新运行模板检查

```bash
cache_dir="$(mktemp -d)"
PYTHONPYCACHEPREFIX="$cache_dir" python3 -m py_compile \
  oiSnippets/template/simple_template.py
status=$?
rm -rf "$cache_dir"
exit "$status"
```

### Step 5：运行 C++ 回归检查

```bash
NVIM_APPNAME=rainboy-nvim-for-oi nvim --headless \
  '+lua assert(vim.lsp.config.clangd)' \
  '+lua assert(#require("luasnip").get_snippets("cpp") == 37)' \
  '+lua assert(#(require("dap").configurations.cpp or {}) == 1)' \
  '+qa'
```

### Step 6：按用户文档走一遍真实工作流

严格按照 `docs/how-to-use-in-python.md`：

1. 新建 Python 文件。
2. 插入 `simple_template.py`。
3. 展开输入、循环和标准库 snippets。
4. 查看 document symbols。
5. 设置断点并完成一次带标准输入的 debugpy 调试。
6. 在终端执行 `python3 solution.py < in`。

任何与文档不一致的行为都应先修复配置或文档，再重跑相关检查。

### Step 7：最终检查

```bash
git status --short
git log --oneline -7
```

预期：工作区干净，Python 支持由六个职责清晰的提交组成，设计文档提交位于它们之前。

## 完成定义

- Python 文件自动获得 BasedPyright 补全、跳转和宽松诊断。
- Python Treesitter parser 可用时自动启动，缺失时不会破坏编辑。
- 17 个 Pythonic OJ snippets 可用，C++ snippets 数量和行为不变。
- `<Leader>os` 能找到并插入 `simple_template.py`。
- 当前 Python 文件可用现有 DAP 键调试，并从集成终端读取输入。
- 缺少 BasedPyright、python3、debugpy 或 parser 时有明确、非阻断的处理。
- `docs/how-to-use-in-python.md` 能独立指导安装、使用和排错。
- headless、LSP、模板、DAP 手工检查和 C++ 回归全部通过。
