# Minuet AI 代码补全

本配置使用 Minuet 的 virtual-text 前端连接 DeepSeek FIM 接口。AI 补全与
`nvim-cmp`、clangd、BasedPyright 和 LuaSnip 相互独立，只在 C、C++ 和 Python
文件中自动触发。

## 准备 API Key

在 DeepSeek API 平台创建并充值 API Key，然后把它放在 shell 环境变量中。
不要把真实 Key 写进本仓库。

```zsh
export DEEPSEEK_API_KEY="你的 API Key"
```

把这行放入 shell 启动配置后，需要重新打开终端和 Neovim。可以只检查变量
是否存在，不要输出它的内容：

```zsh
[[ -n ${DEEPSEEK_API_KEY:-} ]] && echo ready
```

如果没有设置 Key，Minuet 会显示一次警告，并保持自动补全关闭。

## 补全按键

| 按键 | 作用 |
| --- | --- |
| `<M-a>` | 接受当前建议的所有行 |
| `<M-l>` | 接受当前建议的一行 |
| `<M-]>` | 请求建议或切换到下一条建议 |
| `<M-[>` | 切换到上一条建议 |
| `<M-e>` | 取消当前建议 |
| `<Leader>af` | 切换到 Fast 模式 |
| `<Leader>ac` | 切换到 Choice 模式 |
| `<Leader>at` | 切换当前 buffer 的自动 AI 补全 |

使用 `<M-a>` 前应先检查完整的 virtual text，避免一次插入未经检查的多行
代码。`<Tab>` 和 `<CR>` 仍由现有 LuaSnip 和 `nvim-cmp` 配置处理。

## Fast 与 Choice

启动时默认使用 Choice，适合需要比较多种实现的代码段。两种模式可以随时
切换，新的设置从下一次补全请求开始生效。

| 模式 | 候选数 | 上下文 | 每个候选最大输出 | debounce / throttle |
| --- | ---: | ---: | ---: | ---: |
| Fast | 1 | 4000 字符 | 48 tokens | 300ms / 800ms |
| Choice | 4 | 8000 字符 | 96 tokens | 600ms / 1500ms |

Fast 只有一个候选，因此 `<M-[>` / `<M-]>` 不会切换到其他内容。需要比较
候选时按 `<Leader>ac` 进入 Choice；完成后按 `<Leader>af` 返回 Fast。

也可以直接执行：

```vim
:Minuet change_preset fast
:Minuet change_preset choice
```

## 启停

平时打开 C++ 或 Python 文件时，Minuet 会自动加载。当前 buffer 可以执行：

```vim
:Minuet virtualtext toggle
```

参加不允许 AI 的比赛时，在启动 Neovim 前设置 `OI_AI=0`，插件将完全不加载：

```zsh
OI_AI=0 vi main.cpp
```

恢复普通启动即可重新启用：

```zsh
vi main.cpp
```

判断逻辑在 `lua/plugins/minuet.lua:6`：

```lua
enabled = vim.env.OI_AI ~= "0",
```

即环境变量**正好等于字符串 `0`** 时才关闭。`vim.env` 读到的永远是字符串，
未设置时是 `nil`，`nil ~= "0"` 成立，所以默认开启。

### 三个容易踩的坑

**必须 `export`。** 裸写只设当前 shell 的变量，nvim 的进程环境里看不到：

```zsh
export OI_AI=0    # 正确
OI_AI=0           # 错误：nvim 读不到
```

**必须是 `0`。** 判断是字符串比较，下列写法都会保持开启：

| 写法 | nvim 读到的值 | 结果 |
| --- | --- | --- |
| `OI_AI=0` | `"0"` | 关闭 |
| `OI_AI=false` | `"false"` | 仍然开启 |
| `OI_AI=no` | `"no"` | 仍然开启 |
| `OI_AI=` | `""` | 仍然开启 |
| `OI_AI=00` | `"00"` | 仍然开启 |
| 未设置 | `nil` | 仍然开启 |

**`.zshrc` 只对交互式 zsh 生效。** 从脚本、编辑器任务、agent 或非交互 shell
启动 nvim 时 `.zshrc` 不会被读取，需要用 `~/.zshenv` 才能覆盖所有场景。

### 想永久关闭

在 shell 启动配置里加一行：

```zsh
export OI_AI=0
```

代价是 AI 一直关着。比赛之外想用回来，临时覆盖即可：

```zsh
OI_AI=1 vi main.cpp
```

## 请求范围

- Provider：DeepSeek FIM API。
- 模型：`deepseek-v4-flash`。
- 默认 Choice 每轮请求四个候选；Fast 每轮只请求一个候选。
- Choice 使用最多 8000 字符上下文和 96 tokens 输出；Fast 使用 4000 字符
  上下文和 48 tokens 输出。
- 补全菜单打开时隐藏 AI virtual text。

代码上下文会发送给 DeepSeek。不要在源码或注释里保存不希望发送的题面、
密钥或其他敏感信息。
