-- ============================================================================
-- Theme sync: Neovim follows Ghostty's effective light/dark background
-- ============================================================================

local M = {}

local state = {
  auto = true,
  current = nil,
}

local light_scheme = "github_light_colorblind"
local dark_scheme = "github_dark_colorblind"

local function hex_luminance(hex)
  hex = (hex or ""):gsub("^#", "")
  if not hex:match("^%x%x%x%x%x%x$") then
    return 1
  end

  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255

  local function linear(c)
    if c <= 0.03928 then
      return c / 12.92
    end
    return ((c + 0.055) / 1.055) ^ 2.4
  end

  r, g, b = linear(r), linear(g), linear(b)
  return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

local function ghostty_background()
  if vim.fn.executable("ghostty") ~= 1 then
    return nil
  end

  local lines = vim.fn.systemlist({ "ghostty", "+show-config" })
  if vim.v.shell_error ~= 0 then
    return nil
  end

  for _, line in ipairs(lines) do
    local bg = line:match("^background%s*=%s*(#?%x%x%x%x%x%x)")
    if bg then
      return bg
    end
  end

  return nil
end

local function ghostty_is_dark()
  local bg = ghostty_background()
  if not bg then
    return vim.o.background == "dark"
  end
  return hex_luminance(bg) < 0.5
end

function M.apply(kind, opts)
  opts = opts or {}
  local is_dark = kind == "dark" or (kind == "sync" and ghostty_is_dark())
  local background = is_dark and "dark" or "light"
  local scheme = is_dark and dark_scheme or light_scheme

  if state.current == background and not opts.force then
    return
  end

  vim.o.background = background
  local ok, err = pcall(vim.cmd.colorscheme, scheme)
  if not ok then
    vim.notify("Could not load colorscheme " .. scheme .. ": " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  state.current = background

  -- Re-apply plugin UI integrations that cache colorscheme highlights.
  pcall(function()
    require("lualine").setup({ options = { theme = "auto" } })
  end)

  if opts.notify then
    vim.notify("Neovim theme: " .. scheme .. " (" .. background .. ")")
  end
end

function M.sync(opts)
  M.apply("sync", opts)
end

function M.set_auto(enabled)
  state.auto = enabled
  if enabled then
    M.sync({ notify = true, force = true })
  end
end

function M.setup()
  vim.api.nvim_create_user_command("ThemeSyncGhostty", function()
    M.set_auto(true)
  end, { desc = "Auto-sync Neovim theme with Ghostty" })

  vim.api.nvim_create_user_command("ThemeLight", function()
    state.auto = false
    M.apply("light", { notify = true, force = true })
  end, { desc = "Force Neovim light theme" })

  vim.api.nvim_create_user_command("ThemeDark", function()
    state.auto = false
    M.apply("dark", { notify = true, force = true })
  end, { desc = "Force Neovim dark theme" })

  vim.api.nvim_create_user_command("ThemeAuto", function()
    M.set_auto(true)
  end, { desc = "Alias for :ThemeSyncGhostty" })

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.defer_fn(function()
        M.sync({ force = true })
      end, 100)
    end,
  })

end

return M
