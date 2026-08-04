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
          accept_line = has_deepseek_key and "<M-l>" or nil,
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
      desc = "Toggle Minuet completion",
    })
    vim.keymap.set("n", "<leader>af", "<cmd>Minuet change_preset fast<cr>", {
      desc = "Minuet fast preset",
    })
    vim.keymap.set("n", "<leader>ac", "<cmd>Minuet change_preset choice<cr>", {
      desc = "Minuet choice preset",
    })

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
