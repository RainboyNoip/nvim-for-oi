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
    "uga-rosa/cmp-dictionary", -- 字典补全
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

    -- dictionary
    require("cmp_dictionary").setup({
      paths = { vim.fn.stdpath("config") .. '/dictionary/google-10000-english-no-swears.txt' },
      exact_length = 2,
    })


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
        { name = "lazydev" },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "dictionary", keyword_length = 2 }, -- 字典补全
      }, {
        { name = "buffer" ,keyword_length = 2},-- 缓冲区源的最小关键字长度
      }),
      -- [[ 主要改动点 5: 格式化与图标 ]]
      -- 使用 lspkind 替代 LazyVim.config.icons
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text",   -- 显示 图标 和 文本
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
            dictionary = "[Dict]",
          },
          menu = {
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[Snippet]",
            path = "[Path]",
            dictionary = "[Dict]",
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
