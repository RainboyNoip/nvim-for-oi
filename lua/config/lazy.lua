-- lazy.nvim bootstrap
-- 如果本机还没有安装 lazy.nvim，就通过 GitHub 代理自动 clone。
local gitproxy = "https://gh-proxy.com/"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = gitproxy .. "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Leader 必须在插件和快捷键加载前设置，否则 lazy.nvim 的 keys 可能绑定到旧 leader。
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
-- vim.o.timeout = true -- 启用 leader 键的延迟
-- vim.o.timeoutlen = 0 -- 设置 leader 键的延迟时间为 300 毫秒

-- lazy.nvim 主配置
require("lazy").setup({
  -- 个人 OJ 配置以稳定为主，不在启动时自动检查插件更新。
  checker = { enabled = false },

  -- 插件规格统一放在 lua/plugins/ 目录。
  spec = {
    { import = "plugins" },
  },

  -- Git 相关设置：统一走代理，避免插件安装/更新时网络不稳定。
  git = {
    log = { "-8" }, -- 显示最近8次提交
    timeout = 120,  -- 终止超过2分钟的进程
    url_format = gitproxy .. "https://github.com/%s.git",

    -- lazy.nvim 需要 git >=2.19.0。如果你想在旧版本中使用 lazy，
    -- 可以将下面设置为 false。这样应该可以工作，但不被支持并且会
    -- 大幅增加下载量。
    filter = true,

    -- 网络相关 git 操作 (clone, fetch, checkout) 的频率
    throttle = {
      enabled = false, -- 默认不启用
      -- 每5秒最多2个操作
      rate = 2,
      duration = 5 * 1000, -- 以毫秒为单位
    },

    -- 在为插件再次运行 fetch 之前等待的秒数。
    -- 重复的更新/检查操作将不会再次运行，直到这个
    -- 冷却期过去。
    cooldown = 0,
  },
})
