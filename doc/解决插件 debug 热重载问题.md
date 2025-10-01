你问到了点子上！这是所有 Neovim 插件开发者都会遇到的核心问题。每次修改后都重启 Neovim 极其低效。幸运的是，有多种非常成熟的方法可以实现插件的“热重载”(Hot Reload)，让你在不关闭 Neovim 的情况下立即看到代码改动效果。

### 问题的根源：Lua 的模块缓存

首先，你需要了解为什么需要“重载”。当你使用 `require("my.plugin")` 加载一个 Lua 模块时，Lua 会执行该文件，然后将其返回的内容（通常是一个 table）**缓存**在一个全局 table `package.loaded` 中。下次你再 `require("my.plugin")` 时，Lua 不会重新读取文件，而是直接从缓存中返回之前的结果。这就是为什么你修改了文件，Neovim 却毫无反应的原因。

因此，热重载的核心就是两个步骤：

1.  **清除缓存**：从 `package.loaded` 中移除你的插件模块。
2.  **重新加载**：再次 `require` 你的插件并执行初始化代码（例如 `setup()` 函数）。

### 方法 1：手动 DIY 重载命令 (理解原理)

我们可以基于上述原理，自己动手创建一个简单的重载命令。

假设你的插件主模块叫做 `my-awesome-plugin`。

1.  **清除缓存**：
    在 Neovim 命令模式下执行：

    ```vim
    :lua package.loaded['my-awesome-plugin'] = nil
    ```

2.  **重新加载并初始化**：

    ```vim
    :lua require('my-awesome-plugin').setup()
    ```

虽然可行，但每次都输入这两行命令还是很麻烦。我们可以把它们封装成一个自定义命令和快捷键。

```lua
-- 你可以把这段代码加到你的 init.lua 或其他配置文件中

-- 创建一个用户命令 :ReloadPlugin
vim.api.nvim_create_user_command('ReloadPlugin', function()
  -- 清除缓存
  package.loaded['my-awesome-plugin'] = nil
  -- 重新加载并设置
  require('my-awesome-plugin').setup()
  print("Plugin 'my-awesome-plugin' reloaded!")
end, {})

-- 绑定一个快捷键，比如 <Leader>rr (reload)
vim.keymap.set('n', '<leader>rr', '<cmd>ReloadPlugin<CR>', {
  noremap = true,
  silent = true,
  desc = "Reload my awesome plugin"
})
```

**缺点**：这个简单的方法只重载了主模块。如果你的插件有很多子模块（例如 `my-awesome-plugin.utils`, `my-awesome-plugin.config`），而你修改了子模块，这种方法不会重载它们，因为主模块引用的依然是缓存中的旧的子模块。

-----

### 方法 2：使用 `plenary.nvim` (社区标准方案 - 强烈推荐)

`plenary.nvim` 是一个非常流行的 Neovim 工具库，被大量插件所依赖。它提供了一个非常强大的 `reload_module` 函数，可以**智能地、递归地**重载一个模块及其所有子模块。这是目前解决这个问题的最佳实践。

1.  **安装 `plenary.nvim`**
    如果你的插件还没有依赖它，可以用 `lazy.nvim` 来安装：

    ```lua
    -- plugins/plenary.lua
    return { 'nvim-lua/plenary.nvim' }
    ```

2.  **创建更强大的重载命令**
    假设你的插件名为 `my-formatter`，它的 Lua 模块结构位于 `lua/my-formatter/`。

    ```lua
    -- 同样，把这个加到你的配置文件中
    local plugin_name = "my-formatter" -- <--- 在这里修改成你的插件主模块名

    local function reload_plugin()
      -- 使用 plenary 的强大重载功能
      -- 它会自动清除 'my-formatter' 和所有 'my-formatter.*' 的子模块缓存
      require('plenary.reload').reload_module(plugin_name)

      -- 重新调用 setup 函数
      -- pcall 可以在代码出错时不让你的 Neovim 崩溃
      local ok, plugin = pcall(require, plugin_name)
      if ok then
        -- 如果你的插件有 setup 函数
        if plugin.setup then
          plugin.setup() -- 在这里传入你的插件配置
        end
        vim.notify("Reloaded plugin: " .. plugin_name, vim.log.levels.INFO)
      else
        vim.notify("Failed to reload plugin: " .. plugin_name, vim.log.levels.ERROR)
      end
    end

    -- 创建命令
    vim.api.nvim_create_user_command('ReloadDevPlugin', reload_plugin, {})

    -- 绑定快捷键
    vim.keymap.set('n', '<leader>rr', '<cmd>ReloadDevPlugin<CR>', {
      noremap = true,
      silent = true,
      desc = "Reload dev plugin"
    })
    ```

现在，每当你修改了插件代码（无论是主文件还是任何子模块），只需要在普通模式下按下 `<leader>rr`，你的整个插件就会被完整、安全地重载。

-----

### 方法 3：使用 `neodev.nvim` 打造完整开发环境

如果你想非常严肃地进行插件开发，强烈推荐 `folke/neodev.nvim`。

它的主要功能是**为你的插件开发环境提供完整的 Neovim API 类型定义和自动补全**，让你可以像写 TypeScript 一样获得 `vim.fn.*`, `vim.api.*` 等所有函数的提示和文档。

虽然 `neodev.nvim` 本身不直接提供重载命令，但使用它的开发者通常都会结合**方法 2** 来创建一个极致流畅的开发工作流：

1.  **`neodev.nvim`** 提供完美的编码体验（代码补全、类型检查）。
2.  **`plenary.nvim`** 的重载命令提供快速的测试反馈。

### 总结与建议

| 方法 | 优点 | 缺点 |
| :--- | :--- | :--- |
| **1. 手动 DIY** | 简单，无需依赖，有助于理解原理 | 功能非常有限，无法重载子模块 |
| **2. 使用 plenary.nvim** | **功能强大，递归重载**，稳定可靠，社区标准 | 需要额外添加 `plenary.nvim` 依赖 |
| **3. neodev.nvim 工作流** | 提供完整的开发体验（编码+重载） | 配置稍复杂，适用于长期项目 |

**我的建议是**：直接采用**方法 2（使用 `plenary.nvim`）**。这是目前 Neovim 社区解决插件热重载问题的黄金标准，它能极大地提升你的开发效率和幸福感。