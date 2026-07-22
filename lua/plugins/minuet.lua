local completion_filetypes = { "c", "cpp", "python" }

return {
  "milanglacier/minuet-ai.nvim",
  ft = completion_filetypes,
  enabled = vim.env.OI_AI ~= "0",
  config = function()
    local has_deepseek_key = vim.env.DEEPSEEK_API_KEY ~= nil and vim.env.DEEPSEEK_API_KEY ~= ""

    require("minuet").setup({
      provider = "openai_fim_compatible",
      n_completions = 1,
      context_window = 8000,
      throttle = 1500,
      debounce = 600,
      request_timeout = 3,
      notify = "warn",

      -- Keep AI suggestions separate from the existing nvim-cmp pipeline.
      cmp = {
        enable_auto_complete = false,
      },
      virtualtext = {
        auto_trigger_ft = has_deepseek_key and completion_filetypes or {},
        show_on_completion_menu = false,
        keymap = {
          accept = nil,
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
