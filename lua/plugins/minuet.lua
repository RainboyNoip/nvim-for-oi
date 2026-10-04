local completion_filetypes = { "c", "cpp", "python" }

return {
  "milanglacier/minuet-ai.nvim",
  ft = completion_filetypes,
  enabled = vim.env.OI_AI ~= "0",
  config = function()
    local has_deepseek_key = vim.env.DEEPSEEK_API_KEY ~= nil and vim.env.DEEPSEEK_API_KEY ~= ""

    require("minuet").setup({
      provider = "openai_fim_compatible",
      -- FIM providers issue one request per candidate; multiple candidates enable cycling.
      n_completions = 2,
      context_window = 8000,
      throttle = 1500,
      debounce = 600,
      request_timeout = 3,
      notify = "warn",
      presets = {
        fast = {
          n_completions = 1,
          context_window = 4000,
          throttle = 800,
          debounce = 300,
          request_timeout = 2,
          provider_options = {
            openai_fim_compatible = {
              optional = {
                max_tokens = 48,
              },
            },
          },
        },
        choice = {
          n_completions = 2,
          context_window = 8000,
          throttle = 1500,
          debounce = 600,
          request_timeout = 3,
          provider_options = {
            openai_fim_compatible = {
              optional = {
                max_tokens = 96,
              },
            },
          },
        },
      },

      -- Keep AI suggestions separate from the existing nvim-cmp pipeline.
      cmp = {
        enable_auto_complete = false,
      },
      virtualtext = {
        auto_trigger_ft = has_deepseek_key and completion_filetypes or {},
        show_on_completion_menu = false,
        keymap = {
          accept = has_deepseek_key and "<M-a>" or nil,
          accept_line = has_deepseek_key and "<M-n>" or nil,
          accept_n_lines = nil,
          prev = has_deepseek_key and "<M-[>" or nil,
          next = has_deepseek_key and "<M-]>" or nil,
          dismiss = has_deepseek_key and "<M-e>" or nil,
        },
      },
      provider_options = {
        openai_fim_compatible = {
          api_key = "DEEPSEEK_API_KEY",
          name = "DeepSeek",
          end_point = "https://api.deepseek.com/beta/completions",
          model = "deepseek-v4-flash",
          stream = true,
          optional = {
            max_tokens = 96,
            top_p = 0.9,
          },
        },
      },
    })

    vim.keymap.set("n", "<leader>at", "<cmd>Minuet virtualtext toggle<cr>", {
      desc = "切换 AI 补全 开/关",
    })
    vim.keymap.set("n", "<leader>ad", "<cmd>Minuet virtualtext disable<cr>", {
      desc = "关闭 AI 自动补全",
    })
    vim.keymap.set("n", "<leader>ae", "<cmd>Minuet virtualtext enable<cr>", {
      desc = "开启 AI 自动补全",
    })
    vim.keymap.set("n", "<leader>af", "<cmd>Minuet change_preset fast<cr>", {
      desc = "AI 补全切到 fast 预设 (快)",
    })
    vim.keymap.set("n", "<leader>ac", "<cmd>Minuet change_preset choice<cr>", {
      desc = "AI 补全切到 choice 预设 (多候选)",
    })

    -- DeepSeek 余额不足 / API 报错时，Minuet 会把服务端原始响应原样 notify
    -- 出来（一大坨英文 JSON）。这里包装 vim.notify，拦截并翻译成友好提示。
    -- 做法：匹配 DeepSeek 常见错误码（402 Insufficient Balance、401 无效 key 等）。
    local notify = vim.notify
    vim.notify = function(msg, level, opts)
      if type(msg) == "string" and msg:find("DeepSeek returns error", 1, true) then
        if msg:find("Insufficient Balance", 1, true) or msg:find("402", 1, true) then
          notify("AI 补全失败：DeepSeek 账户余额不足，请充值后重试", vim.log.levels.ERROR, { title = "Minuet / AI 补全" })
          return
        elseif msg:find("Authentication Fails", 1, true) or msg:find("401", 1, true) then
          notify("AI 补全失败：DEEPSEEK_API_KEY 无效或已过期", vim.log.levels.ERROR, { title = "Minuet / AI 补全" })
          return
        elseif msg:find("Not Found", 1, true) or msg:find("404", 1, true) then
          notify("AI 补全失败：模型或接口不存在（404）", vim.log.levels.ERROR, { title = "Minuet / AI 补全" })
          return
        end
      end
      notify(msg, level, opts)
    end

    if not has_deepseek_key then
      vim.schedule(function()
        vim.notify(
          "DEEPSEEK_API_KEY is not set; automatic AI completion is disabled.",
          vim.log.levels.WARN,
          { title = "Minuet" }
        )
      end)
    end
  end,
}
