return {
  dir = vim.fn.stdpath("config") .. "/lua/local/python-settings",
  ft = { "python" },
  config = function()
    require("python-settings").setup()
  end,
}
