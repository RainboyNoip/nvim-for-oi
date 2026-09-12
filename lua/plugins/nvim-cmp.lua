-- ── OI 常用 token 词表（纯内存，不读任何文件） ─────────────────────────
-- 只放「英文词典 / LSP 都给不了」的词：带下划线的标准库名、缩写标识符、大写宏。
-- 想加词直接加一行。匹配是大小写敏感的（和 cmp 自身过滤一致），所以 INF 要打大写。
local OI_WORDS = {
  -- C++ 标准库（英文单词表里没有）
  "priority_queue",
  "unordered_map",
  "unordered_set",
  "lower_bound",
  "upper_bound",
  "push_back",
  "emplace_back",
  "memset",
  "sizeof",
  -- OI 惯用缩写 / 宏名（两种语言都常打）
  "INF",
  "dfs",
  "bfs",
  "lca",
  "ans",
  "cnt",
  "vis",
  "idx",
  "nxt",
  -- Python 竞赛常用（英文词典里没有的）
  "defaultdict",
  "popleft",
}

-- 在哪些 filetype 下启用。要扩展就改这一行（比如加 c = true, h = true）。
local OI_FILETYPES = { cpp = true, python = true }

local oi_source = {}

function oi_source.new()
  return setmetatable({}, { __index = oi_source })
end

local function oi_enabled(bufnr)
  return OI_FILETYPES[vim.bo[bufnr or 0].filetype] == true
end

function oi_source:is_available()
  return oi_enabled(0)
end

function oi_source:get_keyword_length()
  return 2 -- 打满 2 个字符才开始提示
end

function oi_source:complete(params, callback)
  local bufnr = params.context.bufnr
  if not oi_enabled(bufnr) then
    return callback({})
  end

  -- 取光标前面那一段标识符（字母/数字/下划线）
  local keyword = params.context.cursor_before_line:match("[%w_]+$") or ""
  if #keyword < 2 then
    return callback({})
  end

  local kind = require("cmp").lsp.CompletionItemKind.Text
  local items = {}
  for _, word in ipairs(OI_WORDS) do
    if word:sub(1, #keyword) == keyword then
      items[#items + 1] = { label = word, kind = kind }
    end
  end
  callback(items)
end

return {
  "hrsh7th/nvim-cmp",
  version = false, -- last release is way too old
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "onsails/lspkind.nvim" , -- 用于显示图标
    "saadparwaiz1/cmp_luasnip", -- 
  },
  -- Not all LSP servers add brackets when completing a function.
  -- To better deal with this, LazyVim adds a custom option to cmp,
  -- that you can configure. For example:
  --
  -- ```lua
  -- opts = {
  --   auto_brackets = { "python" }
  -- }
  -- ```
  opts = function()
    -- Register nvim-cmp lsp capabilities
    vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })

    vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    local cmp = require("cmp")
    local lspkind = require("lspkind")
    local defaults = require("cmp.config.default")()
    local auto_select = true
    local luasnip = require("luasnip")

    -- 注册内存版 OI 词表源（定义在文件顶部，零依赖、零文件 IO）
    cmp.register_source("oi_words", oi_source.new())

    return {
      auto_brackets = {}, -- configure any filetype to auto add brackets
      completion = {
        completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
      },
      preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),           -- 使用 Ctrl+E 关闭补全
        -- [[ 主要改动点 3: 智能的 Enter 键 ]]
        -- 如果有选中项，则确认。否则，执行默认回车行为（换行）
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        -- ["<CR>"] = LazyVim.cmp.confirm({ select = auto_select }),
        -- ["<C-y>"] = LazyVim.cmp.confirm({ select = true }),

        -- ["<S-CR>"] = LazyVim.cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

        ["<C-CR>"] = function(fallback)
          cmp.abort()
          fallback()
        end,

        -- ["<tab>"] = function(fallback)
        --   return LazyVim.cmp.map({ "snippet_forward", "ai_accept" }, fallback)()
        -- end,

        -- [[ 主要改动点 4: 智能的 Tab 键 ]]
          -- 1. 如果光标在代码片段的可跳转节点上，跳转到下一节点
          -- 2. 如果补全菜单可见，选择下一项
          -- 3. 否则，执行 fallback (插入 Tab 字符)
          ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif cmp.visible() then
              cmp.select_next_item()
            -- elseif luasnip.expand_or_jumpable() then
            --   luasnip.expand_or_jump()
            -- elseif has_words_before() then
            --   cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }), -- i: 插入模式, s: 选择模式

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = 'luasnip' },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "oi_words" }, -- OI 常用 token（内存表，见文件顶部 OI_WORDS）
      }, {
        { name = "buffer", keyword_length = 3 }, -- 缓冲区源的最小关键字长度（2 太激进，OI 单文件重复率高）
      }),
      -- [[ 主要改动点 5: 格式化与图标 ]]
      -- 使用 lspkind 替代 LazyVim.config.icons
      formatting = {
        format = lspkind.cmp_format({
          mode = "text", -- nvim-cmp 已用独立 icon 列显示 lspkind 图标。
          maxwidth = {
            -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            -- can also be a function to dynamically calculate max width such as
            -- menu = function() return math.floor(0.45 * vim.o.columns) end,
            menu = 50, -- leading text (labelDetails)
            abbr = 50, -- actual suggestion item
          },
          ellipsis_char = "...",
          -- 展示来源，对于调试很有用
          source_mapping = {
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            path = "[Path]",
            oi_words = "[OI]",
          },
          menu = {
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            path = "[Path]",
            oi_words = "[OI]",
          }
        }),
      },
      -- formatting = {
      --   format = function(entry, item)
      --     local icons = LazyVim.config.icons.kinds
      --     if icons[item.kind] then
      --       item.kind = icons[item.kind] .. item.kind
      --     end

      --     local widths = {
      --       abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
      --       menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
      --     }

      --     for key, width in pairs(widths) do
      --       if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
      --         item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
      --       end
      --     end

      --     return item
      --   end,
      -- },
      experimental = {
        -- only show ghost text when we show ai completions
        ghost_text = vim.g.ai_cmp and {
          hl_group = "CmpGhostText",
        } or false,
      },
      sorting = defaults.sorting,
    }
  end,
  -- main = "lazyvim.util.cmp",
}
