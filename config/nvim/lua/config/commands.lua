-- ==========================================================================
-- Custom commands / command-line aliases
-- ==========================================================================

vim.api.nvim_create_user_command("Ntr", function(opts)
  vim.cmd("NvimTreeResize " .. opts.args)
end, {
  nargs = 1,
  desc = "Resize NvimTree. Example: :Ntr 50",
})

-- User commands must start with an uppercase letter, so this makes :ntr 50
-- expand to :Ntr 50 only when `ntr` is used as the command name.
vim.cmd([[cnoreabbrev <expr> ntr getcmdtype() ==# ':' && getcmdline() ==# 'ntr' ? 'Ntr' : 'ntr']])
