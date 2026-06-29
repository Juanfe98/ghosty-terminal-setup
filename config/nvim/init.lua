-- ============================================================================
-- Neovim config (modular)
-- ============================================================================

-- Expose this Neovim instance to child terminals/tools like lazygit so commands
-- such as `nvr --remote-tab` open files in the current Neovim session.
vim.env.NVIM_LISTEN_ADDRESS = vim.env.NVIM_LISTEN_ADDRESS or vim.v.servername

require("config.mason-env")
require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.commands")
require("config.autocmds")
