local macos_config = require("plugins.dap.macos")
local linux_config = require("plugins.dap.linux")

if vim.fn.has("macunix") == 1 then
    return macos_config
elseif vim.fn.has("unix") == 1 then
    return linux_config
else
    print("Unsupported operating system")
    return {}
end
