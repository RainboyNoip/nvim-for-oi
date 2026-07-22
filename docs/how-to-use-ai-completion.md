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
| `<M-l>` | 接受当前建议的一行 |
| `<M-]>` | 请求建议或切换到下一条建议 |
| `<M-[>` | 切换到上一条建议 |
| `<M-e>` | 取消当前建议 |
| `<Leader>at` | 切换当前 buffer 的自动 AI 补全 |

没有绑定“接受整个建议”，避免一次插入未经检查的多行代码。`<Tab>` 和
`<CR>` 仍由现有 LuaSnip 和 `nvim-cmp` 配置处理。

## 启停

平时打开 C++ 或 Python 文件时，Minuet 会自动加载。当前 buffer 可以执行：

```vim
:Minuet virtualtext toggle
```

参加不允许 AI 的比赛时，在启动 Neovim 前设置 `OI_AI=0`，插件将完全不加载：

```zsh
OI_AI=0 NVIM_APPNAME=rainboyNvim nvim main.cpp
```

恢复普通启动即可重新启用：

```zsh
NVIM_APPNAME=rainboyNvim nvim main.cpp
```

## 请求范围

- Provider：DeepSeek FIM API。
- 模型：`deepseek-v4-flash`。
- 每次只请求一个候选，最多生成 96 tokens。
- 上下文最多 8000 个字符。
- 输入停止 600ms 后才请求，两次请求至少间隔 1500ms。
- 补全菜单打开时隐藏 AI virtual text。

代码上下文会发送给 DeepSeek。不要在源码或注释里保存不希望发送的题面、
密钥或其他敏感信息。
