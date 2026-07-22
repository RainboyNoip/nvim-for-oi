local function assert_equal(actual, expected, label)
  assert(vim.deep_equal(actual, expected), string.format(
    "%s: expected %s, got %s",
    label,
    vim.inspect(expected),
    vim.inspect(actual)
  ))
end

local function run()
  local original_api_key = vim.env.DEEPSEEK_API_KEY
  vim.env.DEEPSEEK_API_KEY = "rainboy-minuet-headless-test"
  require("lazy").load({ plugins = { "minuet-ai.nvim" } })
  vim.env.DEEPSEEK_API_KEY = original_api_key

  local config = require("minuet").config
  assert_equal(config.provider, "openai_fim_compatible", "provider")
  assert_equal(config.n_completions, 4, "completion count")
  assert_equal(config.context_window, 8000, "context window")
  assert_equal(config.throttle, 1500, "request throttle")
  assert_equal(config.debounce, 600, "request debounce")
  assert_equal(config.request_timeout, 3, "request timeout")
  assert_equal(config.cmp.enable_auto_complete, false, "nvim-cmp integration")

  local virtualtext = config.virtualtext
  assert_equal(virtualtext.auto_trigger_ft, { "c", "cpp", "python" }, "auto-trigger filetypes")
  assert_equal(virtualtext.show_on_completion_menu, false, "completion menu visibility")
  assert_equal(virtualtext.keymap.accept, "<M-a>", "whole-completion keymap")
  assert_equal(virtualtext.keymap.accept_line, "<M-l>", "line keymap")
  assert_equal(virtualtext.keymap.next, "<M-]>", "next keymap")
  assert_equal(virtualtext.keymap.prev, "<M-[>", "previous keymap")
  assert_equal(virtualtext.keymap.dismiss, "<M-e>", "dismiss keymap")

  for _, lhs in ipairs({ "<M-a>", "<M-l>", "<M-[>", "<M-]>", "<M-e>" }) do
    local mapping = vim.fn.maparg(lhs, "i", false, true)
    assert(not vim.tbl_isempty(mapping), "missing Minuet insert mapping: " .. lhs)
  end

  local provider = config.provider_options.openai_fim_compatible
  assert_equal(provider.api_key, "DEEPSEEK_API_KEY", "API key environment variable")
  assert_equal(provider.end_point, "https://api.deepseek.com/beta/completions", "DeepSeek endpoint")
  assert_equal(provider.model, "deepseek-v4-flash", "DeepSeek model")
  assert_equal(provider.optional.max_tokens, 96, "maximum completion tokens")

  local cmp = require("cmp")
  for _, source in ipairs(cmp.get_config().sources) do
    assert(source.name ~= "minuet", "Minuet must stay outside the nvim-cmp source list")
  end
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
  return
end

print("minuet_completion: ok")
